//
//  ViewController.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 18/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import CoreLocation
//import MCSwipeTableViewCell
import SwiftyDrop
import SwiftyTimer
import Crashlytics

// Removing MCSwipeTableViewCellDelegate here temporarily
class LotlistViewController: UITableViewController, CLLocationManagerDelegate {

	let locationManager = CLLocationManager()

	var parkinglots: [Parkinglot] = []
	var defaultSortedParkinglots: [Parkinglot] = []

	var timeUpdated: NSDate?
	var timeDownloaded: NSDate?
	var dataSource: String?

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
		var attrsDict = [NSObject: AnyObject]()
		attrsDict[NSFontAttributeName] = font
		navBar!.titleTextAttributes = attrsDict

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
				let alertController = UIAlertController(title: NSLocalizedString("LOCATION_DATA_ERROR_TITLE", comment: "Location Data Error"), message: NSLocalizedString("LOCATION_DATA_ERROR", comment: "Please allow location data..."), preferredStyle: UIAlertControllerStyle.Alert)
				alertController.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: UIAlertActionStyle.Cancel, handler: nil))
				alertController.addAction(UIAlertAction(title: NSLocalizedString("SETTINGS", comment: "Settings"), style: UIAlertActionStyle.Default, handler: {
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

			let mapVC: MapViewController = segue.destinationViewController as! MapViewController
			mapVC.detailParkinglot = selectedParkinglot
			mapVC.allParkinglots = parkinglots
		}
	}

	/**
	Call ServerController to update all local data, catch possible errors and handle the UI based on the refresh (e.g. UIRefreshControl and the UIBarButtonItem).
	*/
	func updateData() {
		showActivityIndicator()

		ServerController.sendMetadataRequest { (supportedCities, updateError) -> () in
			switch updateError {
			case .Some(let err):
				self.showUpdateError(err)
				self.stopRefreshUI()
			case .None:
				(UIApplication.sharedApplication().delegate as! AppDelegate).supportedCities = supportedCities
				let selectedCity = NSUserDefaults.standardUserDefaults().stringForKey("selectedCity")!
				let selectedCityID = supportedCities[selectedCity]!
				ServerController.sendParkinglotDataRequest(selectedCityID) {
					(lotList, timeUpdated, timeDownloaded, dataSource, updateError) in

					let sortingType = NSUserDefaults.standardUserDefaults().stringForKey("SortingType")
					if let sortingType = sortingType {
						Answers.logCustomEventWithName("View City", customAttributes: ["selected City": selectedCity, "sorting type": sortingType])
					}

					self.stopRefreshUI()

					switch updateError {
					case .Some(let err):
						self.showUpdateError(err)
					case .None:

						self.parkinglots = lotList
						self.defaultSortedParkinglots = lotList

						if let timeUpdated = timeUpdated, timeDownloaded = timeDownloaded, dataSource = dataSource {
							self.timeUpdated = timeUpdated
							self.timeDownloaded = timeDownloaded
							self.dataSource = dataSource
						}

						// Check if date signifies that the data is possibly outdated and warn the user if that is the case
						if let timeUpdated = timeUpdated {
							let currentDate = NSDate()
							let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
							let dateDifference = calendar.components(NSCalendarUnit.Minute, fromDate: timeUpdated, toDate: currentDate, options: NSCalendarOptions.WrapComponents)

							if dateDifference.minute >= 60 {
								Drop.down(NSLocalizedString("OUTDATED_DATA_WARNING", comment: "The server indicates that the displayed data might be outdated. It was last updated more than an hour ago"), blur: .Dark)
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
	func showUpdateError(err: ServerController.UpdateError) {
		switch err {
		case .Server, .IncompatibleAPI:
			Drop.down(NSLocalizedString("SERVER_ERROR", comment: "Couldn't read data from server. Please try again in a few moments."), state: .Error)
		case .Request:
			Drop.down(NSLocalizedString("REQUEST_ERROR", comment: "Couldn't fetch data. You appear to be disconnected from the internet."), state: .Error)
		case .Unknown:
			Drop.down(NSLocalizedString("UNKNOWN_ERROR", comment: "An unknown error occurred. Please try again in a few moments."), state: .Error)
		}
	}

	/**
	Sort the parkingslots array based on what is currently saved for SortingType in NSUserDefaults.
	*/
	func sortLots() {
		let sortingType = NSUserDefaults.standardUserDefaults().stringForKey("SortingType")
		switch sortingType! {
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
				let sqrt1 = sqrt(pow(distance1, 2.0) + pow(Double(occ1*1000), 2.0))
				let sqrt2 = sqrt(pow(distance2, 2.0) + pow(Double(occ2*1000), 2.0))

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
		let settingsVC = settingsStoryBoard.instantiateInitialViewController() as! UIViewController
		self.navigationController?.presentViewController(settingsVC, animated: true, completion: nil)
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - Reload Button Stuff
	// /////////////////////////////////////////////////////////////////////////

	/**
	Remove all UI that has to do with refreshing data.
	*/
	func stopRefreshUI() {
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			self.showReloadButton()
			self.refreshControl!.endRefreshing()
		})
	}

	/**
	Replace the right UIBarButtonItem with the reload button.
	*/
	func showReloadButton() {
		let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "updateData")
		self.navigationItem.rightBarButtonItem = refreshButton
	}

	/**
	Replace the right UIBarButtonItem with a UIActivityIndicatorView.
	*/
	func showActivityIndicator() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
		activityIndicator.color = UIColor.blackColor()
		activityIndicator.startAnimating()
		let activityItem = UIBarButtonItem(customView: activityIndicator)
		self.navigationItem.rightBarButtonItem = activityItem
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
			self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
		} else {
			self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
		}

		// Handle the TimestampCell
		if indexPath.row >= parkinglots.count {
			let timecell: TimestampCell = tableView.dequeueReusableCellWithIdentifier("timestampCell") as! TimestampCell
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateStyle = .MediumStyle
			dateFormatter.timeStyle = .ShortStyle

			if let timeUpdated = timeUpdated {
				let lastUpdatedString = NSLocalizedString("LAST_UPDATED", comment: "Updated:") + " " + dateFormatter.stringFromDate(timeUpdated) + " " + NSLocalizedString("TIME_SUFFIX", comment: "German: Uhr")
				timecell.timestampLabel.text = lastUpdatedString
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
					cell.parkinglotAddressLabel.text = NSLocalizedString("WAITING_FOR_LOCATION", comment: "waiting for location")
				}
			}
		} else if thisLot.address == "" {
			cell.parkinglotAddressLabel.text = NSLocalizedString("UNKNOWN_ADDRESS", comment: "unknown address")
		} else {
			cell.parkinglotAddressLabel.text = thisLot.address
		}

		// I kinda feel bad for writing this...
		var load = thisLot.total > 0 ? Int(round(100 - (Double(thisLot.free) / Double(thisLot.total) * 100))) : 100
		load = load < 0 ? 0 : load
		load = thisLot.state == lotstate.closed ? 100 : load

		// Maybe a future version of the scraper will be able to read the tendency as well
		if thisLot.state == lotstate.unknown {
			cell.parkinglotTendencyLabel.text = NSLocalizedString("UNKNOWN_LOAD", comment: "unknown")
		} else if thisLot.state == lotstate.closed {
			cell.parkinglotTendencyLabel.text = NSLocalizedString("CLOSED", comment: "closed")
		} else {
			let localizedOccupied = NSLocalizedString("OCCUPIED", comment: "occupied")
			cell.parkinglotTendencyLabel.text = "\(load)% \(localizedOccupied)"
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

//        // Configure MCSwipeTableViewCell stuff
//
//		// Create view with a star image to be displayed in swiped 'backview'
//		let favView = self.viewWithImageName("favStar")
//		let unfavView = self.viewWithImageName("unfavStar")
//		let favColor = Colors.favYellow
//		let unfavColor = Colors.unfavYellow
//
//        cell.separatorInset = UIEdgeInsetsZero
//        cell.selectionStyle = UITableViewCellSelectionStyle.Gray
//
//		var favoriteLots = NSUserDefaults.standardUserDefaults().arrayForKey("favoriteLots") as! [String]
//		if contains(favoriteLots, thisLot.name) {
//			// Lot is already faved
//
//			cell.favTriangle.image = UIImage(named: "favTriangle")
//
//			cell.setSwipeGestureWithView(unfavView, color: unfavColor, mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State1) { (cell, state, mode) -> Void in
//				let index = find(favoriteLots, thisLot.name)
//				favoriteLots.removeAtIndex(index!)
//				NSLog("removed \(thisLot.name) from favorites")
//				NSUserDefaults.standardUserDefaults().setObject(favoriteLots, forKey: "favoriteLots")
//				NSUserDefaults.standardUserDefaults().synchronize()
//
//				// remove favtriangle from cell
//				(cell as! ParkinglotTableViewCell).favTriangle.image = nil
//
//				self.tableView.reloadData()
//			}
//		} else {
//			// Lot is not faved
//
//			cell.favTriangle.image = nil
//
//			cell.setSwipeGestureWithView(favView, color: favColor, mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State1) { (cell, state, mode) -> Void in
//				favoriteLots.append(thisLot.name)
//				NSLog("added \(thisLot.name) to favorites")
//				NSUserDefaults.standardUserDefaults().setObject(favoriteLots, forKey: "favoriteLots")
//				NSUserDefaults.standardUserDefaults().synchronize()
//
//				// add favtriangle to cell
//				(cell as! ParkinglotTableViewCell).favTriangle.image = UIImage(named: "favTriangle")
//
//				self.tableView.reloadData()
//			}
//		}

		return cell
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - UITableViewDelegate
	// /////////////////////////////////////////////////////////////////////////

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		// Open link to datasource in Safari if TimestampCell was selected
		if indexPath.row >= parkinglots.count {
			if let dataSource = dataSource {
				if let dataSourceURL = NSURL(string: dataSource) {
					UIApplication.sharedApplication().openURL(dataSourceURL)
					tableView.deselectRowAtIndexPath(indexPath, animated: true)
				} else {
					NSLog("Looks like the datasource \(dataSource) isn't a valid URL.")
				}
			}
			return
		}

		// Every other cell goes to the mapview
		let cellTitle = (tableView.cellForRowAtIndexPath(indexPath) as! ParkinglotTableViewCell).parkinglotNameLabel.text!
		for lot in parkinglots {
			if lot.name == cellTitle && lot.lat! == 0.0 {
				Drop.down(NSLocalizedString("NO_COORDS_WARNING", comment: "Don't have no coords, ain't showing no nothin'!"), blur: .Dark)
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
				let distance = currentUserLocation.distanceFromLocation(lotLocation)
				parkinglots[index].distance = round(distance)
			}
		}

		// The idea here is to check the location on each update from the locationManager and only resort
		// the lots and update the tableView if the user has moved more than 100 meters. Doing both every
		// second is aggravating and really not necessary.
		if let lastLoc = lastLocation {
			let distance = currentUserLocation.distanceFromLocation(lastLoc)
			if distance > 100 {
				sortLots()
				tableView.reloadData()
				lastLocation = locations.last as? CLLocation
			}
		} else {
			// we need to set lastLocation at least once somewhere
			lastLocation = locations.last as? CLLocation
		}
	}

	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		// TODO: Implement me to hopefully fix #41
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - MCSwipeTableViewCellDelegate
	// /////////////////////////////////////////////////////////////////////////

//	func swipeTableViewCellDidEndSwiping(cell: MCSwipeTableViewCell!) {
//		var favorites = NSUserDefaults.standardUserDefaults().arrayForKey("favoriteLots")!
//		favorites.append((cell as! ParkinglotTableViewCell).parkinglotNameLabel.text!)
//		println(favorites)
//		NSUserDefaults.standardUserDefaults().setObject(favorites, forKey: "favoriteLots")
//	}

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
