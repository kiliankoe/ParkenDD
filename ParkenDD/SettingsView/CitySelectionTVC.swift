//
//  CitySelectionTVC.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 30/06/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class CitySelectionTVC: UITableViewController {

	var supportedCities = [String]()

	var citiesList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

		self.supportedCities = (UIApplication.sharedApplication().delegate as! AppDelegate).supportedCities
		for city in self.supportedCities {
			citiesList.append(city)
		}
		citiesList.sortInPlace(<)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supportedCities.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("citySelectionCell", forIndexPath: indexPath) 
		cell.textLabel?.text = citiesList[indexPath.row]

		let selectedCity = NSUserDefaults.standardUserDefaults().stringForKey("selectedCity")!
		cell.accessoryType = citiesList[indexPath.row] == selectedCity ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None

        return cell
    }

	// MARK: - Table view delegate

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		for row in 0..<citiesList.count {
			tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0))?.accessoryType = UITableViewCellAccessoryType.None
		}
		tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		let selectedCity = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
		NSUserDefaults.standardUserDefaults().setObject(selectedCity!, forKey: "selectedCity")
		NSUserDefaults.standardUserDefaults().synchronize()

		if let lotlistVC = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers[0] as? LotlistViewController {
			lotlistVC.updateData()
		}

		navigationController?.popToRootViewControllerAnimated(true)
	}

}
