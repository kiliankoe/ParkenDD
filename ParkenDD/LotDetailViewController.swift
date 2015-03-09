//
//  LotDetailViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 18/02/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class LotDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!

	var detailParkinglot: Parkinglot!
	var allParkinglots: [[Parkinglot]]!

	override func viewWillAppear(animated: Bool) {
		self.tableView.estimatedRowHeight = 44
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.reloadData()
	}

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showParkinglotMap" {
			let mapVC: MapViewController = segue.destinationViewController as! MapViewController
			mapVC.detailParkinglot = detailParkinglot
			mapVC.allParkinglots = allParkinglots
		}
	}

	// MARK: - UITableViewDataSource

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// Address, Times, Rate, Contact, Other
		return 6
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case Section.Name.rawValue:
			return 1
		case Section.Address.rawValue:
			return 2
		case Section.Times.rawValue:
			return 1
		case Section.Rate.rawValue:
			return 1
		case Section.Contact.rawValue:
			var countContactOptions = 0
			if let lotData = StaticData[detailParkinglot.name] {
				if let phone: AnyObject? = lotData["phone"] {
					countContactOptions++
				}
				if let email: AnyObject? = lotData["email"] {
					countContactOptions++
				}
				if let website: AnyObject? = lotData["website"] {
					countContactOptions++
				}
				if let reservations: Bool = lotData["reservations"] as? Bool {
					if reservations {
						countContactOptions++
					}
				}
			}
			return countContactOptions
		case Section.Other.rawValue:
			return 3
		default:
			return 0
		}
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: DetailInfoCell = tableView.dequeueReusableCellWithIdentifier("detailInfoCell") as! DetailInfoCell

		if let lotData = StaticData[detailParkinglot.name] {
			// Address, Times, Rate, Contact, Other
			switch indexPath.section {
			case Section.Name.rawValue:
				if indexPath.row == 0 {
					let type = lotData["type"] as! String
					let name = detailParkinglot.name
					cell.mainLabel.text = "\(type) \(name)"
				}
			case Section.Address.rawValue:
				if indexPath.row == 0 {
					cell.mainLabel.text = lotData["address"] as? String
				} else if indexPath.row == 1 {
					cell.mainLabel.text = "Show on Map"
				}
			case Section.Times.rawValue:
				cell.mainLabel.text = lotData["times"] as? String
			case Section.Rate.rawValue:
				cell.mainLabel.text = lotData["rate"] as? String
			case Section.Contact.rawValue:
				cell.mainLabel.text = "Contact"
			case Section.Other.rawValue:
				cell.mainLabel.text = "Other"
			default:
				println("nope")
			}
		} else {
			cell.mainLabel.text = "Foobar"
		}

		return cell
	}

	// MARK: - UITableViewDelegate

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case Section.Name.rawValue:
			return "Name"
		case Section.Address.rawValue:
			return "Address"
		case Section.Times.rawValue:
			return "Times"
		case Section.Rate.rawValue:
			return "Rate"
		case Section.Contact.rawValue:
			return "Contact"
		case Section.Other.rawValue:
			return "Other"
		default:
			return "nope"
		}
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == Section.Address.rawValue && indexPath.row == 1 {
			performSegueWithIdentifier("showParkinglotMap", sender: self)
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// MARK: - Helpers

	enum Section: Int {
		case Name, Address, Times, Rate, Contact, Other
	}

}
