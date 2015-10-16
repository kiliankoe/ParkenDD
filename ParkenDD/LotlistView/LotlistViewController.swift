//
//  ViewController.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 18/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyDrop
import SwiftyTimer
import Crashlytics

class LotlistViewController: UITableViewController, CLLocationManagerDelegate {

	let locationManager = CLLocationManager()

	var parkinglots: [Parkinglot] = []
	var defaultSortedParkinglots: [Parkinglot] = []

	var timeUpdated: NSDate?
	var timeDownloaded: NSDate?
	var dataURL: String?

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

		// pretty title
		let font = UIFont(name: "AvenirNext-Medium", size: 18.0)
		var attrsDict = [String: AnyObject]()
		attrsDict[NSFontAttributeName] = font
		navBar!.titleTextAttributes = attrsDict
        navigationItem.title = NSUserDefaults.standardUserDefaults().stringForKey("selectedCity")

		// Set a table footer view so that separators aren't shown when no data is yet present
		self.tableView.tableFooterView = UIView(frame: CGRectZero)

		updateData()
		NSTimer.every(5.minutes, updateData)
	}

	override func viewWillAppear(animated: Bool) {
		sortLots()
		tableView.reloadData()

		// Start getting location updates if the user wants lots sorted by distance
		let sortingType = NSUserDefaults.standardUserDefaults().stringForKey("SortingType")!
		if sortingType == "distance" || sortingType == "euklid" {
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
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
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
        navigationItem.title = NSUserDefaults.standardUserDefaults().stringForKey("selectedCity")

		ServerController.sendMetadataRequest { result in
			switch result {
			case .Failure(let err):
				self.showUpdateError(err)
				self.stopRefreshUI()
			case .Success(let supportedCitiesJSON):
				var supportedCities = [String]()
				for (city, _) in supportedCitiesJSON {
					supportedCities.append(city)
				}
				(UIApplication.sharedApplication().delegate as? AppDelegate)?.supportedCities = supportedCities
				let selectedCity = NSUserDefaults.standardUserDefaults().stringForKey("selectedCity")!
				ServerController.sendParkinglotDataRequest(selectedCity) { (result) in

					let sortingType = NSUserDefaults.standardUserDefaults().stringForKey("SortingType")
					if let sortingType = sortingType {
						Answers.logCustomEventWithName("View City", customAttributes: ["selected City": selectedCity, "sorting type": sortingType])
					}

					self.stopRefreshUI()

					switch result {
					case .Failure(let err):
						self.showUpdateError(err)
					case .Success(let data):

						self.parkinglots = data.parkinglotList
						self.defaultSortedParkinglots = data.parkinglotList

						if let timeUpdated = data.timeUpdated, timeDownloaded = data.timeDownloaded, dataURL = data.dataURL {
							self.timeUpdated = timeUpdated
							self.timeDownloaded = timeDownloaded
							self.dataURL = dataURL
						}

						// Check if date signifies that the data is possibly outdated and warn the user if that is the case
						if let timeUpdated = data.timeUpdated {
							let currentDate = NSDate()
							let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
							let dateDifference = calendar.components(NSCalendarUnit.Minute, fromDate: timeUpdated, toDate: currentDate, options: NSCalendarOptions.WrapComponents)

							if dateDifference.minute >= 60 {
								Drop.down(L10n.OUTDATEDDATAWARNING.string, blur: .Dark)
							}
						}

						if let currentUserLocation = self.locationManager.location {
							for index in 0..<self.parkinglots.count {
								if let lat = self.parkinglots[index].lat, lng = self.parkinglots[index].lng, currentUserLocation = self.locationManager.location {
									let lotLocation = CLLocation(latitude: lat, longitude: lng)
									let distance = currentUserLocation.distanceFromLocation(lotLocation)
									self.parkinglots[index].distance = round(distance)
								}
							}
						}

						self.sortLots()

						// Reload the tableView on the main thread, otherwise it will only update once the user interacts with it
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
						})
					}
				}
			}
		}
	}

	/**
	Called by the request to the API in case of failure and handed the error to display to the user.
	*/
	func showUpdateError(err: ServerController.SCError) {
		switch err {
		case .Server, .IncompatibleAPI:
			Drop.down(L10n.SERVERERROR.string, state: .Error)
		case .Request:
			Drop.down(L10n.REQUESTERROR.string, state: .Error)
		case .Unknown:
			Drop.down(L10n.UNKNOWNERROR.string, state: .Error)
		}
	}

	/**
	Sort the parkingslots array based on what is currently saved for SortingType in NSUserDefaults.
	*/
	func sortLots() {
        guard let sortingType = NSUserDefaults.standardUserDefaults().stringForKey("SortingType") else {
            
            return
        }
		switch sortingType {
		case "distance":
			parkinglots.sortInPlace({
				(lot1: Parkinglot, lot2: Parkinglot) -> Bool in
				if let firstDistance = lot1.distance, secondDistance = lot2.distance {
					if lot1.name == "Parkhaus Mitte" && firstDistance <= 2000 {
						// FIXME: This is only temporary ಠ_ಠ
						return true
					}
					return firstDistance < secondDistance
				}
				return lot1.name < lot2.name
			})
		case "alphabetical":
			parkinglots.sortInPlace({
				$0.name < $1.name
			})
		case "free":
			parkinglots.sortInPlace({
				$0.free > $1.free
			})
		case "euklid":
			self.parkinglots.sortInPlace(sortEuclidian)
		default:
			parkinglots = defaultSortedParkinglots
		}
	}

	func sortEuclidian(lot1: Parkinglot, lot2: Parkinglot) -> Bool {
		if let distance1 = lot1.distance, distance2 = lot2.distance {
			if lot1.name == "Parkhaus Mitte" && distance1 <= 2000 {
				// FIXME: This is only temporary ಠ_ಠ
				return true
			}
			// TODO: Also check if state is either open or unknown, others should not be sorted
			if lot1.total != 0 && lot2.total != 0 {
                let occ1 = Double(lot1.total - lot1.free) / Double(lot1.total)
				let occ2 = Double(lot2.total - lot2.free) / Double(lot2.total)
                
                // This factor gives a penalty for very crowded parking spaces
                // so they are ranked down the list, even if they are very close
                let smoothingfactor1 = 1.0 / Double(2.0*(1.0-occ1))
                let smoothingfactor2 = 1.0 / Double(2.0*(1.0-occ2))
                
				let sqrt1 = sqrt(pow(distance1, 2.0) + smoothingfactor1 * pow(Double(occ1*1000), 2.0))
				let sqrt2 = sqrt(pow(distance2, 2.0) + smoothingfactor2 * pow(Double(occ2*1000), 2.0))

				return sqrt1 < sqrt2
			}
		}
		return lot1.free > lot2.free
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - IBActions
	// /////////////////////////////////////////////////////////////////////////

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
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			self.showReloadButton()
			self.refreshControl!.endRefreshing()
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
		// adding 1 for timeUpdated
		return parkinglots.count + 1
	}

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.row < parkinglots.count {
			return 60
		}
		return 30
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: ParkinglotTableViewCell = tableView.dequeueReusableCellWithIdentifier("parkinglotCell") as! ParkinglotTableViewCell

		// Don't display any separators if the list is still empty
		if parkinglots.count == 0 {
			tableView.separatorStyle = UITableViewCellSeparatorStyle.None
		} else {
			tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
		}

		// Handle the TimestampCell
		if indexPath.row >= parkinglots.count {
			let timecell: TimestampCell = tableView.dequeueReusableCellWithIdentifier("timestampCell") as! TimestampCell
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateStyle = .MediumStyle
			dateFormatter.timeStyle = .ShortStyle

			if let timeUpdated = timeUpdated {
                timecell.timestampLabel.text = L10n.LASTUPDATED(dateFormatter.stringFromDate(timeUpdated)).string
			}
			return timecell
		}

		var thisLot = parkinglots[indexPath.row]
		let customParkinglotlist = parkinglots

		cell.parkinglot = thisLot
		cell.parkinglotNameLabel.text = thisLot.name
		cell.parkinglotLoadLabel.text = thisLot.state == .unknown ? "?" : "\(thisLot.free)"

		// check if location sorting is enabled, then we're displaying distance instead of address
		let sortingType = NSUserDefaults.standardUserDefaults().stringForKey("SortingType")!
		if sortingType == "distance" || sortingType == "euklid" {
			if let currentUserLocation = locationManager.location, lat = thisLot.lat, lng = thisLot.lng where lat != 0.0 && lng != 0.0 {
				let lotLocation = CLLocation(latitude: lat, longitude: lng)
				thisLot.distance = currentUserLocation.distanceFromLocation(lotLocation)
				cell.parkinglotAddressLabel.text = "\((round(thisLot.distance!/100))/10)km"
			} else {
				if let distance = thisLot.distance {
					cell.parkinglotAddressLabel.text = NSLocalizedString("UNKNOWN_LOCATION", comment: "unknown location")
				} else {
					cell.parkinglotAddressLabel.text = L10n.WAITINGFORLOCATION.string
				}
			}
		} else if thisLot.address == "" {
			cell.parkinglotAddressLabel.text = L10n.UNKNOWNADDRESS.string
		} else {
			cell.parkinglotAddressLabel.text = thisLot.address
		}

		// I kinda feel bad for writing this...
		var load = thisLot.total > 0 ? Int(round(100 - (Double(thisLot.free) / Double(thisLot.total) * 100))) : 100
		load = load < 0 ? 0 : load
		load = thisLot.state == lotstate.closed ? 100 : load

		// Maybe a future version of the scraper will be able to read the tendency as well
		if thisLot.state == lotstate.unknown {
			cell.parkinglotTendencyLabel.text = L10n.UNKNOWNLOAD.string
		} else if thisLot.state == lotstate.closed {
			cell.parkinglotTendencyLabel.text = L10n.CLOSED.string
		} else {
			cell.parkinglotTendencyLabel.text = "\(load)% \(L10n.OCCUPIED.string)"
		}

		// Set all labels to be white, 'cause it looks awesome
		cell.parkinglotNameLabel.textColor = UIColor.whiteColor()
		cell.parkinglotAddressLabel.textColor = UIColor.whiteColor()
		cell.parkinglotLoadLabel.textColor = UIColor.whiteColor()
		cell.parkinglotTendencyLabel.textColor = UIColor.whiteColor()

		var percentage = thisLot.total > 0 ? 1 - (Double(thisLot.free) / Double(thisLot.total)) : 0.99
		if percentage < 0.1 {
			percentage = 0.1
		} else if percentage > 0.99 {
			percentage = 0.99
		}
		cell.backgroundColor = Colors.colorBasedOnPercentage(percentage, emptyLots: thisLot.free)

		return cell
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - UITableViewDelegate
	// /////////////////////////////////////////////////////////////////////////

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		// Open link to datasource in Safari if TimestampCell was selected
		if indexPath.row >= parkinglots.count {
			if let dataURL = dataURL {
				if let dataURL = NSURL(string: dataURL) {
					UIApplication.sharedApplication().openURL(dataURL)
					tableView.deselectRowAtIndexPath(indexPath, animated: true)
				} else {
					NSLog("Looks like the datasource \(dataURL) isn't a valid URL.")
				}
			}
			return
		}

		// Every other cell goes to the mapview
		let cellTitle = (tableView.cellForRowAtIndexPath(indexPath) as! ParkinglotTableViewCell).parkinglotNameLabel.text!
		for lot in parkinglots {
			if lot.name == cellTitle && lot.lat! == 0.0 {
				Drop.down(L10n.NOCOORDSWARNING.string, blur: .Dark)
				tableView.deselectRowAtIndexPath(indexPath, animated: true)
				return
			}
		}
		performSegueWithIdentifier("showParkinglotMap", sender: self)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - CLLocationManagerDelegate
	// /////////////////////////////////////////////////////////////////////////
	var lastLocation: CLLocation?
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let currentUserLocation = locationManager.location
		// Cycle through all lots to assign their respective distances from the user
		for index in 0..<parkinglots.count {
			if let lat = parkinglots[index].lat, lng = parkinglots[index].lng {
				let lotLocation = CLLocation(latitude: lat, longitude: lng)
				let distance = currentUserLocation!.distanceFromLocation(lotLocation)
				parkinglots[index].distance = round(distance)
			}
		}

		// The idea here is to check the location on each update from the locationManager and only resort
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
		}
	}

	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		// TODO: Implement me to hopefully fix #41
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
