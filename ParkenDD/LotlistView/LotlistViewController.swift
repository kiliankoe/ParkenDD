//
//  ViewController.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 18/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyTimer
import Crashlytics

class LotlistViewController: UITableViewController, CLLocationManagerDelegate, UIViewControllerPreviewingDelegate {

	let locationManager = CLLocationManager()

	var parkinglots: [Parkinglot] = []
	var defaultSortedParkinglots: [Parkinglot] = []

	var timeUpdated: NSDate?
	var timeDownloaded: NSDate?
	var dataURL: String?
	
	@IBOutlet weak var titleButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()

		// set CLLocationManager delegate
		locationManager.delegate = self

		// display the standard reload button
		showReloadButton()

		// pretty navbar with black buttons
		let navBar = self.navigationController?.navigationBar
		navBar!.translucent = false
		navBar!.tintColor = UIColor.blackColor()

		// Set title to selected city
		updateTitle(withCity: nil)

		// Set a table footer view so that separators aren't shown when no data is yet present
		self.tableView.tableFooterView = UIView(frame: CGRectZero)
		
		if #available(iOS 9.0, *) {
			registerForPreviewingWithDelegate(self, sourceView: tableView)
		}

		updateData()
		NSTimer.every(5.minutes, updateData)
	}

	override func viewWillAppear(animated: Bool) {
		tableView.reloadData()

		// Start getting location updates if the user wants lots sorted by distance
		if let sortingType = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.sortingType) where sortingType == Sorting.distance || sortingType == Sorting.euclid {
			if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
				locationManager.startUpdatingLocation()
			} else {
				let alertController = UIAlertController(title: L10n.LOCATIONDATAERRORTITLE.string, message: L10n.LOCATIONDATAERROR.string, preferredStyle: UIAlertControllerStyle.Alert)
				alertController.addAction(UIAlertAction(title: L10n.CANCEL.string, style: UIAlertActionStyle.Cancel, handler: nil))
				alertController.addAction(UIAlertAction(title: L10n.SETTINGS.string, style: UIAlertActionStyle.Default, handler: {
					(action) in
					UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
				}))
				presentViewController(alertController, animated: true, completion: nil)
			}
		} else {
			locationManager.stopUpdatingLocation()
		}
		
		sortLots()
		
		refreshControl?.endRefreshing()
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showParkinglotMap" {
			let indexPath = tableView.indexPathForSelectedRow

			let selectedParkinglot = parkinglots[indexPath!.row]

			let mapVC = segue.destinationViewController as? MapViewController
			mapVC?.detailParkinglot = selectedParkinglot
			mapVC?.allParkinglots = parkinglots
		}
	}

	/**
	Call ServerController to update all local data, catch possible errors and handle the UI based on the refresh (e.g. UIRefreshControl and the UIBarButtonItem).
	*/
	func updateData() {
		showActivityIndicator()
		
		// Set title to selected city
		updateTitle(withCity: nil)
		
		ServerController.updateDataForSavedCity { [unowned self] (result, error) -> Void in
			if let error = error {
				self.handleUpdateError(error)
				self.stopRefreshUI()
			} else {
				guard let result = result else { NSLog("Neither got any results from the API or an error. This is odd. Very odd indeed. Houston?"); return }
				
				// Let's gather some statistics about which cities and sorting types users actually care about.
				let selectedCity = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.selectedCity)!
				let sortingType = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.sortingType)!
				Answers.logCustomEventWithName("View City", customAttributes: ["selected city": selectedCity, "sorting type": sortingType])
				
				self.stopRefreshUI()
				
				var citiesList = [String: City]()
				if NSUserDefaults.standardUserDefaults().boolForKey(Defaults.showExperimentalCities) {
					citiesList = result.metadata.cities!
				} else {
					for (id, city) in result.metadata.cities! {
						if let supported = city.activeSupport where supported == true {
							citiesList[id] = city
						}
					}
				}
				
				(UIApplication.sharedApplication().delegate as? AppDelegate)?.citiesList = citiesList
				
				if let lots = result.parkinglotData.lots {
					
					// Filter out nodata lots if the user has the setting enabled
					let filteredLots: [Parkinglot]
					if NSUserDefaults.standardUserDefaults().boolForKey(Defaults.skipNodataLots) {
						filteredLots = lots.filter({ (lot) -> Bool in
							if let state = lot.state {
								return state != .nodata
							}
							return true
						})
					} else {
						filteredLots = lots
					}
					
					self.parkinglots = filteredLots
					self.defaultSortedParkinglots = filteredLots
				}
				
				if let lastUpdated = result.parkinglotData.lastUpdated, lastDownloaded = result.parkinglotData.lastDownloaded {
					self.timeUpdated = lastUpdated
					self.timeDownloaded = lastDownloaded
					
					// While we're at it we're also going to check if the current data is older than an hour and tell the user if it is.
					let currentDate = NSDate()
//                    print("Current: \(currentDate)")
//                    print("Last:    \(lastUpdated)")
					let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
					let dateDifference = calendar.components(NSCalendarUnit.Minute, fromDate: lastUpdated, toDate: currentDate, options: NSCalendarOptions.WrapComponents)
					
					var attrs = [String: AnyObject]()
					
					if dateDifference.minute >= 60 {
						attrs = [NSForegroundColorAttributeName: UIColor.redColor()]
						drop(L10n.OUTDATEDDATAWARNING.string, blur: .Dark)
						NSLog("Data in \(selectedCity) seems to be outdated.")
					}
					
					let dateFormatter = NSDateFormatter(dateFormat: "dd.MM.yyyy HH:mm", timezone: nil)
					
					self.refreshControl?.attributedTitle = NSAttributedString(string: "\(L10n.LASTUPDATED(dateFormatter.stringFromDate(lastUpdated)))", attributes: attrs)
				}
				
				// TODO: I want a way to get the data url for the currently selected city to give that to the user somehow...
				
				self.sortLots()
				
				dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
					self.tableView.reloadData()
				})
			}
		}
	}

	/**
	Called by the request to the API in case of failure and handed the error to display to the user.
	*/
	func handleUpdateError(err: ServerController.SCError) {
		switch err {
		case .Server, .IncompatibleAPI:
			drop(L10n.SERVERERROR.string, state: .Error)
		case .Request:
			drop(L10n.REQUESTERROR.string, state: .Error)
		case .NotFound:
			NSUserDefaults.standardUserDefaults().setObject("Dresden", forKey: Defaults.selectedCity)
			NSUserDefaults.standardUserDefaults().setObject("Dresden", forKey: Defaults.selectedCityName)
			NSUserDefaults.standardUserDefaults().synchronize()
			updateData()
			updateTitle(withCity: "Dresden")
		default:
			drop(L10n.UNKNOWNERROR.string, state: .Error)
		}
	}
	
	func updateTitle(withCity city: String?) {
		if let city = city {
			titleButton.setTitle(city, forState: .Normal)
		} else {
			let selectedCity = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.selectedCityName)
			titleButton.setTitle(selectedCity, forState: .Normal)
		}
	}

	/**
	Sort the parkingslots array based on what is currently saved for SortingType in NSUserDefaults.
	*/
	func sortLots() {
		guard let sortingType = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.sortingType) else { return }
		switch sortingType {
		case Sorting.distance:
			parkinglots.sortInPlace({
				(lot1: Parkinglot, lot2: Parkinglot) -> Bool in
				if let currentUserLocation = locationManager.location {
					if lot1.name == "Parkhaus Mitte" && lot1.distance(from: currentUserLocation) <= 2000 {
						// FIXME: This is only temporary ಠ_ಠ
						return true
					}
					return lot1.distance(from: currentUserLocation) < lot2.distance(from: currentUserLocation)
				}
				return lot1.name < lot2.name
			})
		case Sorting.alphabetical:
			parkinglots.sortInPlace({
				$0.name < $1.name
			})
		case Sorting.free:
			parkinglots.sortInPlace({
				$0.getFree() > $1.getFree()
			})
		case Sorting.euclid:
			self.parkinglots.sortInPlace(sortEuclidian)
		default:
			parkinglots = defaultSortedParkinglots
		}
	}

	func sortEuclidian(lot1: Parkinglot, lot2: Parkinglot) -> Bool {
		if let currentUserLocation = locationManager.location {
			if lot1.name == "Parkhaus Mitte" && lot1.distance(from: currentUserLocation) <= 2000 {
				// FIXME: This is only temporary ಠ_ಠ
				return true
			}
			// TODO: Also check if state is either open or unknown, others should not be sorted
			if lot1.total != 0 && lot2.total != 0 {
				let occ1 = Double(lot1.total - lot1.getFree()) / Double(lot1.total)
				let occ2 = Double(lot2.total - lot2.getFree()) / Double(lot2.total)
				
				// This factor gives a penalty for very crowded parking spaces
				// so they are ranked down the list, even if they are very close
				let smoothingfactor1 = 1.0 / Double(2.0*(1.0-occ1))
				let smoothingfactor2 = 1.0 / Double(2.0*(1.0-occ2))
				
				let sqrt1 = sqrt(pow(lot1.distance(from: currentUserLocation), 2.0) + smoothingfactor1 * pow(Double(occ1*1000), 2.0))
				let sqrt2 = sqrt(pow(lot2.distance(from: currentUserLocation), 2.0) + smoothingfactor2 * pow(Double(occ2*1000), 2.0))

				return sqrt1 < sqrt2
			}
		}
		return lot1.free > lot2.free
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - IBActions
	// /////////////////////////////////////////////////////////////////////////

	@IBAction func titleButtonTapped(sender: UIButton) {
		let settingsStoryBoard = UIStoryboard(name: "Settings", bundle: NSBundle.mainBundle())
		let citySelectionVC = settingsStoryBoard.instantiateViewControllerWithIdentifier("City SelectionTVC")
		showViewController(citySelectionVC, sender: self)
	}
	
	@IBAction func settingsButtonTapped(sender: UIBarButtonItem) {
		let settingsStoryBoard = UIStoryboard(name: "Settings", bundle: NSBundle.mainBundle())
		let settingsVC = settingsStoryBoard.instantiateInitialViewController()!
		navigationController?.presentViewController(settingsVC, animated: true, completion: nil)
	}
	
	// /////////////////////////////////////////////////////////////////////////
	// MARK: - Reload Button Stuff
	// /////////////////////////////////////////////////////////////////////////

	/**
	Remove all UI that has to do with refreshing data.
	*/
	func stopRefreshUI() {
		dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
			self.showReloadButton()
			self.refreshControl?.beginRefreshing() // leaving this here to fix a slight offset bug with the refresh control's attributed title
			self.refreshControl?.endRefreshing()
		})
	}

	/**
	Replace the right UIBarButtonItem with the reload button.
	*/
	func showReloadButton() {
		let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "updateData")
		navigationItem.rightBarButtonItem = refreshButton
	}

	/**
	Replace the right UIBarButtonItem with a UIActivityIndicatorView.
	*/
	func showActivityIndicator() {
		let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
		activityIndicator.color = UIColor.blackColor()
		activityIndicator.startAnimating()
		let activityItem = UIBarButtonItem(customView: activityIndicator)
		navigationItem.rightBarButtonItem = activityItem
	}

	@IBAction func refreshControlValueChanged(sender: UIRefreshControl) {
		updateData()
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - UITableViewDataSource
	// /////////////////////////////////////////////////////////////////////////

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return parkinglots.count
	}

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.row < parkinglots.count {
			return 60
		}
		return 30
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: ParkinglotTableViewCell = tableView.dequeueReusableCellWithIdentifier("parkinglotCell") as! ParkinglotTableViewCell
		
		let thisLot = parkinglots[indexPath.row]
		cell.setParkinglot(thisLot)
		
		// Since we've got the locationManager available here it's kinda tricky telling the cell what the current distance
		// from the lot is, so we're passing that along and setting the label in the cell class to keep it separate.
		let sortingType = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.sortingType)!
		if sortingType == Sorting.distance || sortingType == Sorting.euclid {
			if let userLocation = locationManager.location {
				cell.distance = thisLot.distance(from: userLocation)
			} else {
				cell.distance = Const.dummyDistance
			}
		}

		// Don't display any separators if the list is still empty
		if parkinglots.count == 0 {
			tableView.separatorStyle = UITableViewCellSeparatorStyle.None
		} else {
			tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
		}

		return cell
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - UITableViewDelegate
	// /////////////////////////////////////////////////////////////////////////

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let _ = (tableView.cellForRowAtIndexPath(indexPath) as! ParkinglotTableViewCell).parkinglot?.coords {
			performSegueWithIdentifier("showParkinglotMap", sender: self)
		} else {
			drop(L10n.NOCOORDSWARNING.string, blur: .Dark)
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - CLLocationManagerDelegate
	// /////////////////////////////////////////////////////////////////////////
	var lastLocation: CLLocation?
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let currentUserLocation = locationManager.location

		// The idea here is to check the location on each update from the locationManager and only re-sort
		// the lots and update the tableView if the user has moved more than 100 meters. Doing both every
		// second is aggravating and really not necessary.
		if let lastLoc = lastLocation {
			let distance = currentUserLocation!.distanceFromLocation(lastLoc)
			if distance > 100 {
				sortLots()
				tableView.reloadData()
				lastLocation = locations.last
			}
		} else {
			// we need to set lastLocation at least once somewhere
			lastLocation = locations.last
			tableView.reloadData()
		}
	}

	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		// TODO: Implement me to hopefully fix #41
	}
	
	// /////////////////////////////////////////////////////////////////////////
	// MARK: - UIViewControllerPreviewingDelegate
	// /////////////////////////////////////////////////////////////////////////
	
	func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
		let fullForecastVC = ForecastViewController()
		fullForecastVC.lot = (viewControllerToCommit as? MiniForecastViewController)?.lot
		showViewController(fullForecastVC, sender: nil)
	}
	
	func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		if let indexPath = tableView.indexPathForRowAtPoint(location) {
			guard (tableView.cellForRowAtIndexPath(indexPath) as? ParkinglotTableViewCell)!.parkinglot!.forecast! else { return nil }
			
			if #available(iOS 9.0, *) {
			    previewingContext.sourceRect = tableView.rectForRowAtIndexPath(indexPath)
			}
			let forecastVC = MiniForecastViewController()
			forecastVC.lot = parkinglots[indexPath.row]
			return forecastVC
		}
		return nil
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - Helpers
	// /////////////////////////////////////////////////////////////////////////

	func viewWithImageName(imageName: String) -> UIImageView {
		let image = UIImage(named: imageName)
		let imageView = UIImageView(image: image)
		imageView.contentMode = UIViewContentMode.Center
		return imageView
	}
}
