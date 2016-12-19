//
//  MapViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 09/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import MapKit
import Crashlytics

class MapViewController: UIViewController, MKMapViewDelegate {

	@IBOutlet weak var mapView: MKMapView?

	var detailParkinglot: Parkinglot!
	var allParkinglots: [Parkinglot]!

	override func viewDidLoad() {
		super.viewDidLoad()

		mapView?.showsUserLocation = true
		
		if #available(iOS 9, *) {
			mapView?.showsTraffic = true
		}
		
		if let lot = detailParkinglot {
			Answers.logCustomEvent(withName: "View Map", customAttributes: ["selected lot": lot.lotID])
		}
		
		// Add annotations for all parking lots to the map
		for singleLot in allParkinglots {
			var subtitle = L10n.MAPSUBTITLE("\(singleLot.free)", singleLot.total).string
			if let state = singleLot.state {
				switch state {
				case .Closed:
					subtitle = L10n.CLOSED.string
				case .Nodata:
					subtitle = L10n.MAPSUBTITLE("?", singleLot.total).string
				case .Open, .Unknown:
					break
				}
			}
			let lotAnnotation = ParkinglotAnnotation(title: singleLot.name, subtitle: subtitle, parkinglot: singleLot)
			
			mapView?.addAnnotation(lotAnnotation)
			
			// Display the callout if this is the previously selected annotation
			if singleLot.name == detailParkinglot.name {
				mapView?.selectAnnotation(lotAnnotation, animated: true)
			}
		}
		
		// Set the map's region to a 1km region around the selected lot
		if let lat = detailParkinglot.coords?.lat, let lng = detailParkinglot.coords?.lng {
			let parkinglotRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: lat, longitude: lng), 1000, 1000)
			mapView?.setRegion(parkinglotRegion, animated: false)
		} else {
			NSLog("Came to map view with a selected lot that has no coordinates. We're now showing Germany. This is probably not ideal.")
		}
		
		// Display the forecast button if this lot has forecast data
		if let forecast = detailParkinglot.forecast, forecast {
			navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.FORECAST.string, style: .plain, target: self, action: "showForecastController")
		}
	}
	
	/**
	Transition to forecast controller
	*/
	func showForecastController() {
		let forecastController = ForecastViewController()
		forecastController.lot = detailParkinglot
		show(forecastController, sender: self)
	}

	// It's nice to show custom pin colors on the map denoting the current state of the parking lot they're referencing
	// green: open, unknown (if more than 0 free, otherwise red)
	// red: closed, nodata
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		// We don't care about the MKUserLocation here
		guard annotation.isKind(of: ParkinglotAnnotation.self) else { return nil }
		
		let annotation = annotation as? ParkinglotAnnotation
		let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "parkinglotAnnotation")

		if let state = annotation?.parkinglot.state {
			switch state {
			case .Closed:
				annotationView.pinColor = .red
			case .Open, .Unknown:
				annotationView.pinColor = annotation?.parkinglot.free != 0 ? .green : .red
			case .Nodata:
				annotationView.pinColor = .purple
			}
		}

		annotationView.canShowCallout = true

		return annotationView
	}

}
