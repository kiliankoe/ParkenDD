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

	var parkplaetze: [[String]] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		let refreshControl = UIRefreshControl()
		refreshControl.backgroundColor = UIColor.purpleColor()
		refreshControl.tintColor = UIColor.whiteColor()
		refreshControl.addTarget(self, action: nil, forControlEvents: nil)

		tableView.reloadData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showParkplatzDetail" {

		}
	}

	@IBAction func refreshButtonTapped(sender: UIBarButtonItem) {

	}

	@IBAction func aboutButtonTapped(sender: UIBarButtonItem) {
		performSegueWithIdentifier("showAboutView", sender: self)
	}

	// MARK: - UITableViewDataSource

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// hardcoded for now
		// Innere Altstadt, Ring West, Prager Straße, Ring Süd, Ring Ost, Neustadt, Sonstige, Park + Ride, Busparkplätze
		return 9
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: ParkplatzTableViewCell = tableView.dequeueReusableCellWithIdentifier("parkplatzCell") as! ParkplatzTableViewCell

		cell.parkplatzNameLabel.text = "An der Frauenkirche"
		cell.parkplatzLoadLabel.text = "81/120"

		return cell
	}

	// MARK: - UITableViewDelegate

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("showParkplatzDetail", sender: self)
	}

	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 25
	}

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sectionNames = [ "Innere Altstadt", "Ring West", "Prager Straße", "Ring Süd", "Ring Ost", "Neustadt", "Sonstige", "Park + Ride", "Busparkplätze" ]
		return sectionNames[section]
	}

}

