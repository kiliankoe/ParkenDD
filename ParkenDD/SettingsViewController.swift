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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 4
		} else if section == 1 {
			return 2
		} else {
			return 4
		}
    }

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return NSLocalizedString("SORTING_OPTIONS", comment: "Sort by")
		} else if section == 1 {
			return NSLocalizedString("DISPLAY_OPTIONS", comment: "Display")
		} else {
			return NSLocalizedString("OTHER", comment: "Other")
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: UITableViewCell = UITableViewCell()

		// /////////////////////////////////
		// Sorting Options
		// /////////////////////////////////
		let sortingType = NSUserDefaults.standardUserDefaults().stringForKey("SortingType")
		if indexPath.section == 0 {
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_DEFAULT", comment: "Default")
				if sortingType == "default" {
					cell.accessoryType = UITableViewCellAccessoryType.Checkmark
				}
			case 1:
				cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_LOCATION", comment: "Distance")
				if sortingType == "distance" {
					cell.accessoryType = UITableViewCellAccessoryType.Checkmark
				}
			case 2:
				cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_ALPHABETICAL", comment: "Alphabetical")
				if sortingType == "alphabetical" {
					cell.accessoryType = UITableViewCellAccessoryType.Checkmark
				}
			case 3:
				cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_FREESPOTS", comment: "Free spots")
				if sortingType == "free" {
					cell.accessoryType = UITableViewCellAccessoryType.Checkmark
				}
			default:
				break
			}
		}

		// /////////////////////////////////
		// Display Options
		// /////////////////////////////////
		else if indexPath.section == 1 {
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = NSLocalizedString("HIDE_NODATA_LOTS", comment: "Hide lots without data")
				let doHideLots = NSUserDefaults.standardUserDefaults().boolForKey("SkipNodataLots")
				if doHideLots {
					cell.accessoryType = UITableViewCellAccessoryType.Checkmark
				}
			case 1:
				cell.textLabel?.text = NSLocalizedString("USE_GRAYSCALE_COLORS", comment: "Use grayscale colors")
				let useGrayscale = NSUserDefaults.standardUserDefaults().boolForKey("grayscaleColors")
				if useGrayscale {
					cell.accessoryType = UITableViewCellAccessoryType.Checkmark
				}
			default:
				break
			}
		}

		// /////////////////////////////////
		// Other Options
		// /////////////////////////////////
		else if indexPath.section == 2 {
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
				break
			}
		}

		cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
		return cell

	}

	// MARK: - Table View Delegate

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		// /////////////////////////////////
		// Sorting Options
		// /////////////////////////////////
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

		// /////////////////////////////////
		// Display Options
		// /////////////////////////////////
		if indexPath.section == 1 {
			switch indexPath.row {
			case 0:
				let doHideLots = NSUserDefaults.standardUserDefaults().boolForKey("SkipNodataLots")
				if doHideLots {
					NSUserDefaults.standardUserDefaults().setBool(false, forKey: "SkipNodataLots")
					tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
				} else {
					NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SkipNodataLots")
					tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
				}

				let window = UIApplication.sharedApplication().windows.last as! UIWindow
				TSMessage.showNotificationInViewController(window.rootViewController, title: NSLocalizedString("NOTE_TITLE", comment: "Note"), subtitle: NSLocalizedString("LIST_UPDATE_ON_REFRESH", comment: "List will be updated on next refresh"), type: TSMessageNotificationType.Message)
			case 1:
				let useGrayscale = NSUserDefaults.standardUserDefaults().boolForKey("grayscaleColors")
				if useGrayscale {
					NSUserDefaults.standardUserDefaults().setBool(false, forKey: "grayscaleColors")
					tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
				} else {
					NSUserDefaults.standardUserDefaults().setBool(true, forKey: "grayscaleColors")
					tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
				}

			default:
				break
			}
		}

		// /////////////////////////////////
		// Other options
		// /////////////////////////////////
		if indexPath.section == 2 {

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
