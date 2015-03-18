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
		case "location":
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

	// MARK: - IBOutlets
	@IBOutlet weak var defaultSortingCell: UITableViewCell!
	@IBOutlet weak var userLocationSortingCell: UITableViewCell!

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
		if section == 0 {
			return 4
		} else {
			return 3
		}
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
				defaultsValue = "location"
			case 2:
				defaultsValue = "alphabetical"
			case 3:
				defaultsValue = "free"
			default:
				defaultsValue = "default"
			}

			NSUserDefaults.standardUserDefaults().setValue(defaultsValue, forKey: "SortingType")
		}

		if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "About" {
			performSegueWithIdentifier("showAboutView", sender: self)
		}

		if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "Share on Twitter" {
			if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
				let tweetsheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
				tweetsheet.setInitialText("Check out #ParkenDD, an iOS app for checking the availability of Dresden's public parking lots. https://itunes.apple.com/de/app/parkendd/id957165041")
				self.presentViewController(tweetsheet, animated: true, completion: nil)
			}
		}

		if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "Share on Facebook" {
			if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
				let fbsheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
				fbsheet.setInitialText("Check out ParkenDD, an iOS app for checking the availability of Dresden's public parking lots. https://itunes.apple.com/de/app/parkendd/id957165041")
				self.presentViewController(fbsheet, animated: true, completion: nil)
			}
		}

		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

}
