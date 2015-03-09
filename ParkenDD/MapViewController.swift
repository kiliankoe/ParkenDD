//
//  MapViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 09/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

	@IBOutlet weak var mapView: MKMapView!

	var detailParkinglot: Parkinglot!
	var allParkinglots: [[Parkinglot]]!

    override func viewDidLoad() {
        super.viewDidLoad()

		mapView.showsUserLocation = true

		// Add annotations for all parking lots to the map
		for region in allParkinglots {
			for singleLot in region {
				var lotAnnotation = MKPointAnnotation()
				if let currentLat = singleLot.lat, currentLon = singleLot.lon {
					lotAnnotation.coordinate = CLLocationCoordinate2D(latitude: currentLat, longitude: currentLon)
					lotAnnotation.title = "\(singleLot.name): \(singleLot.free)"
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

}
