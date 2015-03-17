//
//  LotDetailViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 17/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import MessageUI

class LotDetailViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {

	var detailParkinglot: Parkinglot!
	var allParkinglots: [[Parkinglot]]!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func viewWillAppear(animated: Bool) {
		self.tableView.estimatedRowHeight = 44
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showParkinglotMap" {
			let mapVC: MapViewController = segue.destinationViewController as! MapViewController
			mapVC.detailParkinglot = detailParkinglot
			mapVC.allParkinglots = allParkinglots
		}
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// Name, Address, Times, Rate, Contact, Other
        return 6
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return 1
		case 2:
			return 1
		case 3:
			return 1
		case 4:
			return 4
		case 5:
			return 2
		default:
			return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		if let lotData = StaticData[detailParkinglot.name] {
			// Name, Address, Times, Rate, Contact, Other
			switch indexPath.section {
			case 0:
				if indexPath.row == 0 {
					let type = lotData["type"] as! String
					let name = detailParkinglot.name
					cell.textLabel?.text = "\(type) \(name)"
				}
			case 1:
				if indexPath.row == 0 {
					cell.textLabel?.text = lotData["address"] as? String
				} else if indexPath.row == 1 {
					cell.textLabel?.text = "Show on Map"
				}
			case 2:
				cell.textLabel?.text = lotData["times"] as? String
			case 3:
				cell.textLabel?.text = lotData["rate"] as? String
			case 4:
				println()
			case 5:
				if indexPath.row == 0 {
					cell.textLabel?.text = "Open Citymap"
				} else if indexPath.row == 1 {
					cell.textLabel?.text = "Report incorrect data"
				}
			default:
				println(indexPath.section)
			}
		}

        return cell
    }

	// MARK: - Table View Delegate

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		// FIXME: This is dirty, I don't like going by section and row :(
		if indexPath.section == 1 {
			performSegueWithIdentifier("showParkinglotMap", sender: self)
		}
		if indexPath.section == 5 && indexPath.row == 0 {
			if let lotData = StaticData[detailParkinglot.name] {
				if let urlString = lotData["map"] as? String {
					var alertController = UIAlertController(title: "Open Safari?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
					alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
					alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
						(alert: UIAlertAction!) in
						// Fuck this...
						let conformURLString = urlString.stringByReplacingOccurrencesOfString("|", withString: "%7C", options: NSStringCompareOptions.LiteralSearch, range: nil)
						UIApplication.sharedApplication().openURL(NSURL(string: conformURLString)!)
					}))
					self.presentViewController(alertController, animated: true, completion: nil)
				}
			}
		}
		if indexPath.section == 5 && indexPath.row == 1 {
			if MFMailComposeViewController.canSendMail() {
				let mailVC = MFMailComposeViewController()
				mailVC.mailComposeDelegate = self

				let version = (NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]) as! String
				mailVC.setSubject("[ParkenDD v\(version)] Problem mit \(detailParkinglot.name)")
				mailVC.setToRecipients(["parkendd@kilian.io"])

				self.presentViewController(mailVC, animated: true, completion: nil)
			}
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// MARK: - MFMailComposeController

	func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

}
