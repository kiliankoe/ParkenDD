//
//  SettingsViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 17/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Social

class SettingsViewController: UITableViewController, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

	// FIXME: This doesn't really work anywhere outside of viewDidAppear(), but here it comes with a bit of an awkward loading time...
	override func viewDidAppear(animated: Bool) {
		let sortingtype = NSUserDefaults.standardUserDefaults().stringForKey("SortingType")

		switch sortingtype! {
		case "distance":
			tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.accessoryType = UITableViewCellAccessoryType.Checkmark
		case "alphabetical":
			tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))?.accessoryType = UITableViewCellAccessoryType.Checkmark
		case "free":
			tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))?.accessoryType = UITableViewCellAccessoryType.Checkmark
		default:
			tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType = UITableViewCellAccessoryType.Checkmark
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 4
		} else {
			return 4
		}
    }

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return NSLocalizedString("SORTING_OPTIONS", comment: "Sort by")
		} else {
			return NSLocalizedString("OTHER", comment: "Other")
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: UITableViewCell = UITableViewCell()

		if indexPath.section == 0 {
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_DEFAULT", comment: "Default")
			case 1:
				cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_LOCATION", comment: "Distance")
			case 2:
				cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_ALPHABETICAL", comment: "Alphabetical")
			case 3:
				cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_FREESPOTS", comment: "Free spots")
			default:
				cell.textLabel?.text = "Did you know that switch case statements have to exhaustive?"
			}
		} else if indexPath.section == 1 {
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = NSLocalizedString("EXPERIMENTAL_PROGNOSIS", comment: "Experimental: Prognosis") 
				cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
			case 1:
				cell.textLabel?.text = NSLocalizedString("ABOUT_BUTTON", comment: "About")
				cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
			case 2:
				cell.textLabel?.text = NSLocalizedString("SHARE_ON_TWITTER", comment: "Share on Twitter")
			case 3:
				cell.textLabel?.text = NSLocalizedString("SHARE_ON_FACEBOOK", comment: "Share on Facebook")
			default:
				cell.textLabel?.text = "Did you know that switch case statements have to exhaustive?"
			}
		}

		return cell

	}

	// MARK: - Table View Delegate

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		if indexPath.section == 0 {
			// Unselect all options
			for row in 0...3 {
				tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0))?.accessoryType = UITableViewCellAccessoryType.None
			}
			// mark the selected one
			tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark

			var defaultsValue: String
			switch indexPath.row {
			case 1:
				defaultsValue = "distance"
			case 2:
				defaultsValue = "alphabetical"
			case 3:
				defaultsValue = "free"
			default:
				defaultsValue = "default"
			}

			NSUserDefaults.standardUserDefaults().setValue(defaultsValue, forKey: "SortingType")
		}

		if indexPath.section == 1 {

			if indexPath.row == 0 {
				performSegueWithIdentifier("showPrognosisView", sender: self)
			}

			if indexPath.row == 1 {
				performSegueWithIdentifier("showAboutView", sender: self)
			}

			if indexPath.row == 2 {
				if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
					let tweetsheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
					tweetsheet.setInitialText(NSLocalizedString("TWEET_TEXT", comment: "Check out #ParkenDD..."))
					self.presentViewController(tweetsheet, animated: true, completion: nil)
				}
			}

			if indexPath.row == 3 {
				if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
					let fbsheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
					fbsheet.setInitialText(NSLocalizedString("FBPOST_TEXT", comment: "Check out ParkenDD..."))
					self.presentViewController(fbsheet, animated: true, completion: nil)
				}
			}
		}

		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

}
