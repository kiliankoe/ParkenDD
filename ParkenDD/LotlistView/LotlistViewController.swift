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
        navigationItem.title = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.selectedCity)

		// Set a table footer view so that separators aren't shown when no data is yet present
		self.tableView.tableFooterView = UIView(frame: CGRectZero)

		updateData()
		NSTimer.every(5.minutes, updateData)
	}

	override func viewWillAppear(animated: Bool) {
		sortLots()
		tableView.reloadData()

		// Start getting location updates if the user wants lots sorted by distance
		let sortingType = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.sortingType)!
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
        
        refreshControl?.endRefreshing()
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
        navigationItem.title = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.selectedCity)
        
        ServerController.updateDataForSavedCity { [unowned self] (result, error) -> Void in
            if let error = error {
                self.showUpdateError(error)
                self.stopRefreshUI()
            } else {
                guard let result = result else { NSLog("Neither got any results from the API or an error. This is odd. Very odd indeed. Houston?"); return }
                
                // Let's gather some statistics about which cities and sorting types users actually care about.
                let selectedCity = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.selectedCity)!
                let sortingType = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.sortingType)!
                Answers.logCustomEventWithName("View City", customAttributes: ["selected city": selectedCity, "sorting type": sortingType])
                
                self.stopRefreshUI()
                
                if let lots = result.parkinglotData.lots {
                    self.parkinglots = lots
                    self.defaultSortedParkinglots = lots
                }
                
                if let lastUpdated = result.parkinglotData.lastUpdated, lastDownloaded = result.parkinglotData.lastDownloaded {
                    self.timeUpdated = lastUpdated
                    self.timeDownloaded = lastDownloaded
                    
                    self.refreshControl?.attributedTitle = NSAttributedString(string: "\(lastUpdated)")
                    
                    // While we're at it we're also going to check if the current data is older than an hour and tell the user if it is.
                    let currentDate = NSDate()
//                    print("Current: \(currentDate)")
//                    print("Last:    \(lastUpdated)")
                    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                    let dateDifference = calendar.components(NSCalendarUnit.Minute, fromDate: lastUpdated, toDate: currentDate, options: NSCalendarOptions.WrapComponents)
                    
                    if dateDifference.minute >= 60 {
                        Drop.down(L10n.OUTDATEDDATAWARNING.string, blur: .Dark)
                    }
                }
                
                // TODO: I want a way to get the data url for the currently selected city to give that to the user somehow...
                
                self.sortLots()
                
                dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                })
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
        guard let sortingType = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.sortingType) else { return }
		switch sortingType {
		case "distance":
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
		if let currentUserLocation = locationManager.location {
			if lot1.name == "Parkhaus Mitte" && lot1.distance(from: currentUserLocation) <= 2000 {
				// FIXME: This is only temporary ಠ_ಠ
				return true
			}
			// TODO: Also check if state is either open or unknown, others should not be sorted
			if lot1.total != 0 && lot2.total != 0 {
				let occ1 = Double(lot1.total - lot1.free) / Double(lot1.total)
				let occ2 = Double(lot2.total - lot2.free) / Double(lot2.total)
				let sqrt1 = sqrt(pow(lot1.distance(from: currentUserLocation), 2.0) + pow(Double(occ1*1000), 2.0))
				let sqrt2 = sqrt(pow(lot2.distance(from: currentUserLocation), 2.0) + pow(Double(occ2*1000), 2.0))

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

		let thisLot = parkinglots[indexPath.row]
        cell.parkinglot = thisLot
		
        let customParkinglotlist = parkinglots
		
        // Set the cell's main title
        if let lotType = thisLot.lotType {
            cell.parkinglotNameLabel.text = "\(lotType) \(thisLot.name)"
        } else {
            cell.parkinglotNameLabel.text = thisLot.name
        }
        
        // Set the cell's number value
        cell.parkinglotLoadLabel.text = "\(thisLot.free)"
        
        // TODO: Have a look at the following line
//		cell.parkinglotLoadLabel.text = thisLot.state == .unknown ? "?" : "\(thisLot.free)"

		// check if location sorting is enabled, then we're displaying distance instead of address
		let sortingType = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.sortingType)!
		if sortingType == "distance" || sortingType == "euklid" {
			if let currentUserLocation = locationManager.location {
				let lotDistance = thisLot.distance(from: currentUserLocation)
                cell.parkinglotAddressLabel.text = lotDistance == 100000000.0 ? L10n.UNKNOWNADDRESS.string : "\((round(lotDistance/100))/10)km"
			} else {
                cell.parkinglotAddressLabel.text = L10n.WAITINGFORLOCATION.string
			}
		} else if thisLot.address == "" {
			cell.parkinglotAddressLabel.text = L10n.UNKNOWNADDRESS.string
		} else {
			cell.parkinglotAddressLabel.text = thisLot.address
		}
        
		// Set all labels to be white, 'cause it looks awesome
		cell.parkinglotNameLabel.textColor = UIColor.whiteColor()
		cell.parkinglotAddressLabel.textColor = UIColor.whiteColor()
		cell.parkinglotLoadLabel.textColor = UIColor.whiteColor()
		cell.parkinglotTendencyLabel.textColor = UIColor.whiteColor()

        // Set the cell's bg color dynamically based on the load percentage.
		var percentage = thisLot.total > 0 ? 1 - (Double(thisLot.free) / Double(thisLot.total)) : 0.99
		if percentage < 0.1 {
			percentage = 0.1
		} else if percentage > 0.99 {
			percentage = 0.99
		}
		cell.backgroundColor = Colors.colorBasedOnPercentage(percentage, emptyLots: thisLot.free)
        
        // TODO: Do all kinds of things with the cell according to the state of the lot
        if let lotState = thisLot.state {
            switch lotState {
            case .closed:
                cell.parkinglotTendencyLabel.text = L10n.CLOSED.string
            case .nodata:
                cell.parkinglotLoadLabel.text = "?"
                cell.parkinglotTendencyLabel.text = L10n.UNKNOWNLOAD.string
            case .open:
                cell.parkinglotTendencyLabel.text = "\(thisLot.loadPercentage)% \(L10n.OCCUPIED.string)"
            case .unknown:
                cell.parkinglotTendencyLabel.text = "THIS IS UNKNOWN, WHY?!"
            }
        }

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
//		for lot in parkinglots {
//			if lot.name == cellTitle && lot.lat! == 0.0 {
//				Drop.down(L10n.NOCOORDSWARNING.string, blur: .Dark)
//				tableView.deselectRowAtIndexPath(indexPath, animated: true)
//				return
//			}
//		}
		performSegueWithIdentifier("showParkinglotMap", sender: self)
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
