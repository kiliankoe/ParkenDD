//
//  ViewController.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 18/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!

	// FIXME: This is definitely not the right way of doing this...
	let refreshControl = UIRefreshControl()

	let server = ServerController()
	let kDefaultServerURL = "http://jkliemann.de/offenesdresden.de/json.php"

	// Bool that can be set by the user in the system settings to reset the server URL back to the default
	var resetServer: Bool!

	// Store the single parking lots once they're retrieved from the server
	// a single subarray for each section
	var parkinglots: [[Parkinglot]] = []
	var sectionNames: [String] = []

	override func viewDidLoad() {
		super.viewDidLoad()

		// Call this here to prevent the UIRefreshControl sometimes looking messed up when waking the app
		self.refreshControl.endRefreshing()

		// FIXME: For some reason the UI freezes up when it tries to update itself on start with a failing internet connection
		// Maybe because it tries to fire an alert on a ViewController that isn't ready yet?
		updateData()

		refreshControl.backgroundColor = UIColor(hue: 0.58, saturation: 1.0, brightness: 0.43, alpha: 1.0)
		refreshControl.tintColor = UIColor.whiteColor()
		refreshControl.addTarget(self, action: "updateData", forControlEvents: UIControlEvents.ValueChanged)
		tableView.addSubview(refreshControl)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// hand over the selected parkinglot to the MapViewController
		if segue.identifier == "showParkinglotDetail" {
			let mapVC: MapViewController = segue.destinationViewController as! MapViewController
			let indexPath = tableView.indexPathForSelectedRow()
			let selectedParkinglot = parkinglots[indexPath!.section][indexPath!.row]
			mapVC.detailParkinglot = selectedParkinglot
			mapVC.allParkinglots = parkinglots
		}
	}

	func refreshUserDefaults() {
		// Load the NSUserDefaults
		server.serverURL = NSUserDefaults.standardUserDefaults().stringForKey("ServerURL")!
		resetServer = NSUserDefaults.standardUserDefaults().boolForKey("ResetServerOnStartup")

		// Reset the server URL if the user wants to
		if (resetServer == true) {
			server.serverURL = kDefaultServerURL
			NSUserDefaults.standardUserDefaults().setObject(kDefaultServerURL, forKey: "ServerURL")

			// Change the bool switch back to being false
			resetServer = false
			NSUserDefaults.standardUserDefaults().setObject(false, forKey: "ResetServerOnStartup")
		}
	}

	func updateData() {
		refreshUserDefaults()
		server.sendRequest() {
			(secNames, plotList, updateError) in
			if let error = updateError {

				if error == "requestError" {
					// Give the user a notification that new data can't be fetched
					var alertController = UIAlertController(title: NSLocalizedString("REQUEST_ERROR_TITLE", comment: "Connection Error"), message: NSLocalizedString("REQUEST_ERROR", comment: "Couldn't fetch data from server. Please try again in a few moments."), preferredStyle: UIAlertControllerStyle.Alert)
					alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
					self.presentViewController(alertController, animated: true, completion: nil)
				} else if error == "serverError" {
					// Give the user a notification that data from the server can't be read
					var alertController = UIAlertController(title: NSLocalizedString("SERVER_ERROR_TITLE", comment: "Server Error"), message: NSLocalizedString("SERVER_ERROR", comment: "Couldn't read data from server. Please try again in a few moments or reset the server if you've changed it."), preferredStyle: UIAlertControllerStyle.Alert)
					alertController.addAction(UIAlertAction(title: NSLocalizedString("SERVER_ERROR_RESET", comment: "Reset"), style: UIAlertActionStyle.Destructive, handler: {
						(alert: UIAlertAction!) in
						self.server.serverURL = self.kDefaultServerURL
						NSUserDefaults.standardUserDefaults().setObject(self.kDefaultServerURL, forKey: "ServerURL")
						self.updateData()
					}))
					alertController.addAction(UIAlertAction(title: NSLocalizedString("SERVER_ERROR_CANCEL", comment: "Cancel"), style: UIAlertActionStyle.Cancel, handler: nil))
					self.presentViewController(alertController, animated: true, completion: nil)
				}

				// Stop the UIRefreshControl without updating the date
				self.refreshControl.endRefreshing()

			} else if let secNames = secNames, plotList = plotList {
				self.sectionNames = secNames
				self.parkinglots = plotList

				// Reload the tableView on the main thread, otherwise it will only update once the user interacts with it
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.tableView.reloadData()

					// Update the displayed "Last update: " time in the UIRefreshControl
					let formatter = NSDateFormatter()
					formatter.dateFormat = "dd.MM. HH:mm"
					let updateString = NSLocalizedString("LAST_UPDATE", comment: "Last update:")
					let title = "\(updateString) \(formatter.stringFromDate(NSDate()))"
					let attrsDict: [NSObject: AnyObject] = [NSForegroundColorAttributeName: UIColor.whiteColor()]
					let attributedTitle = NSAttributedString(string: title, attributes: attrsDict)
					self.refreshControl.attributedTitle = attributedTitle

					// Stop the UIRefreshControl
					self.refreshControl.endRefreshing()
				})
			}
		}
	}

	// MARK: - IBActions

	@IBAction func refreshButtonTapped(sender: UIBarButtonItem) {
		updateData()
	}

	@IBAction func aboutButtonTapped(sender: UIBarButtonItem) {
		performSegueWithIdentifier("showAboutView", sender: self)
	}

	// MARK: - UITableViewDataSource

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if parkinglots.count == 0 {
			let messageLabel = UILabel(frame: CGRectMake(0, 0, view.bounds.width, view.bounds.height))
			messageLabel.text = NSLocalizedString("NO_DATA", comment: "Refreshing...")
			messageLabel.textColor = UIColor.blackColor()
			messageLabel.numberOfLines = 0
			messageLabel.textAlignment = NSTextAlignment.Center
			messageLabel.font = UIFont(name: "HelveticaNeue-LightItalic", size: 20)
			messageLabel.sizeToFit()

			tableView.backgroundView = messageLabel
			tableView.separatorStyle = UITableViewCellSeparatorStyle.None
			return 0
		}
		// TODO: tableView.backgroundView is still set to messageLabel... Can be seen if dragged down far enough. Damn.
		tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
		return parkinglots.count
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return parkinglots[section].count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: ParkinglotTableViewCell = tableView.dequeueReusableCellWithIdentifier("parkinglotCell") as! ParkinglotTableViewCell

		let thisLot = parkinglots[indexPath.section][indexPath.row]

		cell.parkinglotNameLabel.text = thisLot.name
		cell.parkinglotLoadLabel.text = "\(thisLot.free)"

		if let thisLotAddress = parkinglotData[thisLot.name] {
			cell.parkinglotAddressLabel.text = thisLotAddress
		} else {
			cell.parkinglotAddressLabel.text = NSLocalizedString("UNKNOWN_ADDRESS", comment: "unknown address")
		}

		var load: Int = Int(round(100 - (Double(thisLot.free) / Double(thisLot.count) * 100)))
		if load < 0 {
			// Apparently there can be 52 empty spots on a 50 spot parking lot...
			load = 0
		}

		// Maybe a future version of the scraper will be able to read the tendency as well
		if thisLot.state == lotstate.nodata && thisLot.free == 0 {
			cell.parkinglotTendencyLabel.text = NSLocalizedString("UNKNOWN_LOAD", comment: "unknown")
		} else if thisLot.state == lotstate.closed {
			cell.parkinglotTendencyLabel.text = NSLocalizedString("CLOSED", comment: "closed")
		} else {
			let localizedOccupied = NSLocalizedString("OCCUPIED", comment: "occupied")
			cell.parkinglotTendencyLabel.text = "\(load)% \(localizedOccupied)"
		}

		// Normalize all label colors to black, otherwise weird things happen with placeholder cells
		cell.parkinglotNameLabel.textColor = UIColor.blackColor()
		cell.parkinglotAddressLabel.textColor = UIColor.blackColor()
		cell.parkinglotLoadLabel.textColor = UIColor.blackColor()
		cell.parkinglotTendencyLabel.textColor = UIColor.blackColor()

		switch parkinglots[indexPath.section][indexPath.row].state {
		case lotstate.many:
			cell.parkinglotStateImage.image = UIImage(named: "parkinglotStateMany")
		case lotstate.few:
			cell.parkinglotStateImage.image = UIImage(named: "parkinglotStateFew")
		case lotstate.full:
			cell.parkinglotStateImage.image = UIImage(named: "parkinglotStateFull")
		case lotstate.closed:
			cell.parkinglotStateImage.image = UIImage(named: "parkinglotStateClosed")
		default:
			cell.parkinglotStateImage.image = UIImage(named: "parkinglotStateNodata")
			cell.parkinglotNameLabel.textColor = UIColor.grayColor()
			cell.parkinglotAddressLabel.textColor = UIColor.grayColor()
			cell.parkinglotLoadLabel.textColor = UIColor.grayColor()
			cell.parkinglotTendencyLabel.textColor = UIColor.grayColor()
		}

		return cell
	}

	// MARK: - UITableViewDelegate

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("showParkinglotDetail", sender: self)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 25
	}

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sectionNames[section]
	}

}

