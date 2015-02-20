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

	// Store the single parking lots once they're retrieved from the server
	// a single subarray for each section
	var parkinglots: [[Parkinglot]] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.reloadData()

		// some demo content, delete me please
		var innereAltstadt: [Parkinglot] = []
		innereAltstadt.append(Parkinglot(section: "Innere Altstadt", name: "Altmarkt", count: 400, free: 367, state: lotstate.many, lat: 51.05031, lon: 13.73754))
		innereAltstadt.append(Parkinglot(section: "Innere Altstadt", name: "An der Frauenkirche", count: 120, free: 111, state: lotstate.many, lat: 51.05165, lon: 13.7439))
		parkinglots.append(innereAltstadt)

		var ringWest: [Parkinglot] = []
		ringWest.append(Parkinglot(section: "Ring West", name: "Kongresszentrum", count: 250, free: 241, state: lotstate.many, lat: 51.05922, lon: 13.7305))
		parkinglots.append(ringWest)

		var pragerStrasse: [Parkinglot] = []
		pragerStrasse.append(Parkinglot(section: "Prager Straße", name: "Centrum-Galerie", count: 480, free: 0, state: lotstate.closed, lat: 51.04951, lon: 13.73407))
		parkinglots.append(pragerStrasse)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// hand over the selected parkinglot to the MapViewController
		if segue.identifier == "showParkplatzDetail" {

		}
	}

	@IBAction func refreshButtonTapped(sender: UIBarButtonItem) {
		// TODO: Replace me with a pull-to-refresh
	}

	@IBAction func aboutButtonTapped(sender: UIBarButtonItem) {
		performSegueWithIdentifier("showAboutView", sender: self)
	}

	// MARK: - UITableViewDataSource

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// hardcoded for now
		// Innere Altstadt, Ring West, Prager Straße, Ring Süd, Ring Ost, Neustadt, Sonstige, Park + Ride, Busparkplätze
		return parkinglots.count
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return parkinglots[section].count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: ParkinglotTableViewCell = tableView.dequeueReusableCellWithIdentifier("parkinglotCell") as! ParkinglotTableViewCell

		cell.parkinglotNameLabel.text = parkinglots[indexPath.section][indexPath.row].name
		cell.parkinglotLoadLabel.text = "\(parkinglots[indexPath.section][indexPath.row].free)/\(parkinglots[indexPath.section][indexPath.row].count)"

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
		let sectionNames = [ "Innere Altstadt", "Ring West", "Prager Straße", "Ring Süd", "Ring Ost", "Neustadt", "Sonstige", "Park + Ride", "Busparkplätze" ]
		return sectionNames[section]
	}

}

