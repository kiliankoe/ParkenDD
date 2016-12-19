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

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let citiesCount = (UIApplication.shared.delegate as? AppDelegate)?.supportedCities?.count {
			return citiesCount
		}
		return 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "citySelectionCell", for: indexPath)
		let supportedCities = (UIApplication.shared.delegate as? AppDelegate)?.supportedCities
		let citiesList = (UIApplication.shared.delegate as? AppDelegate)?.citiesList
		
		if let city = citiesList![supportedCities![indexPath.row]] { // FIXME: For the love of god, fix this!
			if city.activeSupport! {
				cell.textLabel?.text = city.name
				cell.textLabel?.textColor = UIColor.black
			} else {
				cell.textLabel?.text = city.name
				cell.textLabel?.textColor = UIColor.lightGray
			}
		}

		let selectedCity = UserDefaults.standard.string(forKey: Defaults.selectedCity)!
		cell.accessoryType = supportedCities![indexPath.row] == selectedCity ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none

		return cell
	}

	// MARK: - Table view delegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		for row in 0..<tableView.numberOfRows(inSection: 0) {
			tableView.cellForRow(at: IndexPath(row: row, section: 0))?.accessoryType = UITableViewCellAccessoryType.none
		}
		tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
		tableView.deselectRow(at: indexPath, animated: true)

		let selectedCityID = (UIApplication.shared.delegate as? AppDelegate)?.supportedCities![indexPath.row] // FIXME: For the love of god, fix this!
		let selectedCityName = (UIApplication.shared.delegate as? AppDelegate)?.citiesList[selectedCityID!]?.name
		UserDefaults.standard.set(selectedCityID, forKey: Defaults.selectedCity)
		UserDefaults.standard.set(selectedCityName!, forKey: Defaults.selectedCityName)
		UserDefaults.standard.synchronize()

		if let lotlistVC = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers[0] as? LotlistViewController {
			lotlistVC.updateData()
		}

		navigationController?.popToRootViewController(animated: true)
	}

}
