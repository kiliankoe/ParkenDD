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
			return 2
		} else {
			return 3
		}
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

	// MARK: - Table View Delegate

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "Default" {
			tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
			userLocationSortingCell.accessoryType = UITableViewCellAccessoryType.None
		}

		if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "User Location" {
			tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
			defaultSortingCell.accessoryType = UITableViewCellAccessoryType.None
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
