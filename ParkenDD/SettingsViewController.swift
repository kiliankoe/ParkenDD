//
//  SettingsViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 17/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Social
import TSMessages
import MessageUI

enum Sections: Int {
	case sortingOptions = 0
	case displayOptions
	case otherOptions
}

class SettingsViewController: UITableViewController, UITableViewDelegate, MFMailComposeViewControllerDelegate {

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
		let sec = Sections(rawValue: section)!
		switch sec {
		case .sortingOptions:
			return 4
		case .displayOptions:
			return 2
		case .otherOptions:
			return 6
		}
    }

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sec = Sections(rawValue: section)!
		switch sec {
		case .sortingOptions:
			return NSLocalizedString("SORTING_OPTIONS", comment: "Sort by")
		case .displayOptions:
			return NSLocalizedString("DISPLAY_OPTIONS", comment: "Display")
		case .otherOptions:
			return NSLocalizedString("OTHER_OPTIONS", comment: "Other")
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let sec = Sections(rawValue: indexPath.section)!
		let cell: UITableViewCell = UITableViewCell()

		let sortingType = NSUserDefaults.standardUserDefaults().stringForKey("SortingType")
		let doHideLots = NSUserDefaults.standardUserDefaults().boolForKey("SkipNodataLots")
		let useGrayscale = NSUserDefaults.standardUserDefaults().boolForKey("grayscaleColors")

		switch (sec, indexPath.row) {
		// SORTING OPTIONS
		case (.sortingOptions, 0):
			cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_DEFAULT", comment: "Default")
			cell.accessoryType = sortingType == "default" ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
		case (.sortingOptions, 1):
			cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_LOCATION", comment: "Distance")
			cell.accessoryType = sortingType == "distance" ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
		case (.sortingOptions, 2):
			cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_ALPHABETICAL", comment: "Alphabetical")
			cell.accessoryType = sortingType == "alphabetical" ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
		case (.sortingOptions, 3):
			cell.textLabel?.text = NSLocalizedString("SORTINGTYPE_FREESPOTS", comment: "Free spots")
			cell.accessoryType = sortingType == "free" ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None

		// DISPLAY OPTIONS
		case (.displayOptions, 0):
			cell.textLabel?.text = NSLocalizedString("HIDE_NODATA_LOTS", comment: "Hide lots without data")
			cell.accessoryType = doHideLots ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
		case (.displayOptions, 1):
			cell.textLabel?.text = NSLocalizedString("USE_GRAYSCALE_COLORS", comment: "Use grayscale colors")
			cell.accessoryType = useGrayscale ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None

		// OTHER OPTIONS
		case (.otherOptions, 0):
			cell.textLabel?.text = NSLocalizedString("EXPERIMENTAL_PROGNOSIS", comment: "Experimental: Prognosis")
			cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		case (.otherOptions, 1):
			cell.textLabel?.text = NSLocalizedString("ABOUT_BUTTON", comment: "About")
			cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		case (.otherOptions, 2):
			cell.textLabel?.text = NSLocalizedString("RESET_NOTIFICATIONS", comment: "Reset Notifications")
		case (.otherOptions, 3):
			cell.textLabel?.text = NSLocalizedString("SHARE_ON_TWITTER", comment: "Share on Twitter")
			cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		case (.otherOptions, 4):
			cell.textLabel?.text = NSLocalizedString("SHARE_ON_FACEBOOK", comment: "Share on Facebook")
			cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		case (.otherOptions, 5):
			cell.textLabel?.text = NSLocalizedString("SEND_FEEDBACK", comment: "Feedback / Report Problem")
			cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

		default:
			break
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
				NSUserDefaults.standardUserDefaults().setObject([], forKey: "seenNotifications")
				NSUserDefaults.standardUserDefaults().synchronize()
			}

			if indexPath.row == 3 {
				if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
					let tweetsheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
					tweetsheet.setInitialText(NSLocalizedString("TWEET_TEXT", comment: "Check out #ParkenDD..."))
					self.presentViewController(tweetsheet, animated: true, completion: nil)
				}
			}

			if indexPath.row == 4 {
				if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
					let fbsheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
					fbsheet.setInitialText(NSLocalizedString("FBPOST_TEXT", comment: "Check out ParkenDD..."))
					self.presentViewController(fbsheet, animated: true, completion: nil)
				}
			}

			if indexPath.row == 5 {
				if MFMailComposeViewController.canSendMail() {
					let mail = MFMailComposeViewController()
					mail.mailComposeDelegate = self

					let versionNumber: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
					mail.setSubject("[ParkenDD v\(versionNumber)] Feedback")
					mail.setToRecipients(["parkendd@kilian.io"])

					self.presentViewController(mail, animated: true, completion: nil)
				}
			}
		}

		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// MARK: - MFMailComposeViewControllerDelegate

	func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

}
