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
		}
	}

	func updateData() {
		server.sendRequest() {
			(secNames, plotList, updateError) in
			if let error = updateError {

				// Give the user a notification that new data can't be fetched
				var alertController = UIAlertController(title: "Connection Error", message: "Couldn't fetch data from server. Please try again later or reset the server in the system settings if you've changed it.", preferredStyle: UIAlertControllerStyle.Alert)
				alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(alertController, animated: true, completion: nil)

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
					formatter.dateFormat = "d. MMM, HH:mm"
					let title = "Last update: \(formatter.stringFromDate(NSDate()))"
					let attrsDict: [NSObject: AnyObject] = [NSForegroundColorAttributeName: UIColor.whiteColor()]
					let attributedTitle = NSAttributedString(string: title, attributes: attrsDict)
					self.refreshControl.attributedTitle = attributedTitle

					// Stop the UIRefreshControl
					self.refreshControl.endRefreshing()
				})
			}
		}
	}

	@IBAction func aboutButtonTapped(sender: UIBarButtonItem) {
		performSegueWithIdentifier("showAboutView", sender: self)
	}

	// MARK: - UITableViewDataSource

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if parkinglots.count == 0 {
			let messageLabel = UILabel(frame: CGRectMake(0, 0, view.bounds.width, view.bounds.height))
			messageLabel.text = "No data is currently available. Please pull to refresh."
			messageLabel.textColor = UIColor.blackColor()
			messageLabel.numberOfLines = 0
			messageLabel.textAlignment = NSTextAlignment.Center
			messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
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

		cell.parkinglotNameLabel.text = parkinglots[indexPath.section][indexPath.row].name
		cell.parkinglotLoadLabel.text = "\(parkinglots[indexPath.section][indexPath.row].free)"

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
		}

		return cell
	}

	// MARK: - UITableViewDelegate

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("showParkinglotDetail", sender: self)
	}

	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 25
	}

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sectionNames[section]
	}

}

