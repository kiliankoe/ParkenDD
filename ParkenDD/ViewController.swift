//
//  ViewController.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 18/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!

	let server = ServerController()

	// Store the single parking lots once they're retrieved from the server
	// a single subarray for each section
	var parkinglots: [[Parkinglot]] = []
	var sectionNames: [String] = []

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// hand over the selected parkinglot to the MapViewController
		if segue.identifier == "showParkinglotDetail" {
			let mapVC: MapViewController = segue.destinationViewController as! MapViewController
			let indexPath = tableView.indexPathForSelectedRow()
			let selectedParkinglot = parkinglots[indexPath!.section][indexPath!.row]
			mapVC.detailParkinglot = selectedParkinglot
		}
	}

	func updateData() {
		server.sendRequest() {
			(secNames, plotList) in
			self.sectionNames = secNames
			self.parkinglots = plotList
			self.tableView.reloadData()
		}
	}

	@IBAction func refreshButtonTapped(sender: UIBarButtonItem) {
		// TODO: Replace me with a pull-to-refresh
		updateData()
	}

	@IBAction func aboutButtonTapped(sender: UIBarButtonItem) {
		performSegueWithIdentifier("showAboutView", sender: self)
	}

	// MARK: - UITableViewDataSource

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		println(parkinglots.count) // FIXME: WAT?
		return parkinglots.count
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return parkinglots[section].count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: ParkinglotTableViewCell = tableView.dequeueReusableCellWithIdentifier("parkinglotCell") as! ParkinglotTableViewCell

		cell.parkinglotNameLabel.text = parkinglots[indexPath.section][indexPath.row].name
		cell.parkinglotLoadLabel.text = "\(parkinglots[indexPath.section][indexPath.row].free)/\(parkinglots[indexPath.section][indexPath.row].count)"

		switch parkinglots[indexPath.section][indexPath.row].state {
		case lotstate.many:
			cell.parkinglotStateImage.image = UIImage(named: "parkinglotStateMany")
		case lotstate.few:
			cell.parkinglotStateImage.image = UIImage(named: "parkinglotStateFew")
		case lotstate.full:
			cell.parkinglotStateImage.image = UIImage(named: "parkinglotStateFull")
		case lotstate.closed:
			cell.parkinglotStateImage.image = UIImage(named: "parkinglotStateClosed")
		default:
			cell.parkinglotStateImage.image = UIImage(named: "parkinglotStateNodata")
		}

		return cell
	}

	// MARK: - UITableViewDelegate

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("showParkinglotDetail", sender: self)
	}

	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 25
	}

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		let sectionNames = ["Innere Altstadt", "Ring West", "Prager Straße", "Ring Süd", "Ring Ost", "Neustadt", "Sonstige", "Park + Ride", "Busparkplätze"]
		return sectionNames[section]
	}

}

