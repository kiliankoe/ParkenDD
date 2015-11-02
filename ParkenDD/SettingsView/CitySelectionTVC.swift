//
//  CitySelectionTVC.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 30/06/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class CitySelectionTVC: UITableViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - Table view data source

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let citiesCount = (UIApplication.sharedApplication().delegate as? AppDelegate)?.supportedCities?.count {
			return citiesCount
		}
		return 0
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("citySelectionCell", forIndexPath: indexPath)
		let supportedCities = (UIApplication.sharedApplication().delegate as? AppDelegate)?.supportedCities
		let citiesList = (UIApplication.sharedApplication().delegate as? AppDelegate)?.citiesList
		
		if let city = citiesList![supportedCities![indexPath.row]] { // FIXME: For the love of god, fix this!
			if city.activeSupport! {
				cell.textLabel?.text = city.name
				cell.textLabel?.textColor = UIColor.blackColor()
			} else {
				cell.textLabel?.text = city.name
				cell.textLabel?.textColor = UIColor.lightGrayColor()
			}
		}

		let selectedCity = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.selectedCity)!
		cell.accessoryType = supportedCities![indexPath.row] == selectedCity ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None

		return cell
	}

	// MARK: - Table view delegate

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		for row in 0..<tableView.numberOfRowsInSection(0) {
			tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0))?.accessoryType = UITableViewCellAccessoryType.None
		}
		tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		let selectedCityID = (UIApplication.sharedApplication().delegate as? AppDelegate)?.supportedCities![indexPath.row] // FIXME: For the love of god, fix this!
		let selectedCityName = (UIApplication.sharedApplication().delegate as? AppDelegate)?.citiesList[selectedCityID!]?.name
		NSUserDefaults.standardUserDefaults().setObject(selectedCityID, forKey: Defaults.selectedCity)
		NSUserDefaults.standardUserDefaults().setObject(selectedCityName!, forKey: Defaults.selectedCityName)
		NSUserDefaults.standardUserDefaults().synchronize()

		if let lotlistVC = UIApplication.sharedApplication().keyWindow?.rootViewController?.childViewControllers[0] as? LotlistViewController {
			lotlistVC.updateData()
		}

		navigationController?.popToRootViewControllerAnimated(true)
	}

}
