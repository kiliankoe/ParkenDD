//
//  LotDetailViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 18/02/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import MapKit

class LotDetailViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var titleLabel: UILabel!
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

        mapView.showsUserLocation = true

		// Add annotations for all parking lots to the map
		for region in allParkinglots {
			for singleLot in region {
				var lotAnnotation = MKPointAnnotation()
				if let currentLat = singleLot.lat, currentLon = singleLot.lon {
					lotAnnotation.coordinate = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLon)
					lotAnnotation.title = singleLot.name
					mapView.addAnnotation(lotAnnotation)
					if singleLot.name == detailParkinglot.name {
						// Have the selected lot's callout already displayed
						mapView.selectAnnotation(lotAnnotation, animated: true)
					}
				}
			}
		}

		// Set the map's region to a 1km region around the selected lot
		if let currentLat = detailParkinglot.lat, currentLon = detailParkinglot.lon {
			let parkinglotRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: currentLat, longitude: currentLon), 1000, 1000)
			mapView.setRegion(parkinglotRegion, animated: false)
		} else {
			// Just in case the selected lot comes with no coordinates, show a default view of Dresden
			let dresdenRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 51.051660, longitude: 13.739882), 4000, 4000)
			mapView.setRegion(dresdenRegion, animated: false)

			// Also give the user a notification that this is an unfortunate mishap
			var alertController = UIAlertController(title: NSLocalizedString("UNKNOWN_COORDINATES_TITLE", comment: "Data Error"), message: NSLocalizedString("UNKNOWN_COORDINATES_ERROR", comment: "Couldn't find coordinates for parking lot."), preferredStyle: UIAlertControllerStyle.Alert)
			alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alertController, animated: true, completion: nil)
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - MKMapViewDelegate

//	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
//		mapView.centerCoordinate = userLocation.location.coordinate
//	}

	// MARK: - UITableViewDataSource

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// Address, Times, Rate, Contact, Other
		return 5
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return 1
		case 2:
			return 1
		case 3:
			return 4
		case 4:
			return 2
		default:
			return 0
		}
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: DetailInfoCell = tableView.dequeueReusableCellWithIdentifier("detailInfoCell") as! DetailInfoCell

		if let lotData = StaticData[detailParkinglot.name] {
			// Address, Times, Rate, Contact, Other
			if indexPath.section == 0 {
				cell.mainLabel.text = lotData["address"] as? String
			} else if indexPath.section == 1 {
				cell.mainLabel.text = lotData["times"] as? String
			} else if indexPath.section == 2 {
				cell.mainLabel.text = lotData["rate"] as? String
			}
		} else {
			cell.mainLabel.text = "Foobar"
		}

		return cell
	}

	// MARK: - UITableViewDelegate

	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Address"
		case 1:
			return "Times"
		case 2:
			return "Rate"
		case 3:
			return "Contact"
		case 4:
			return "Other"
		default:
			return "nope"
		}
	}

}
