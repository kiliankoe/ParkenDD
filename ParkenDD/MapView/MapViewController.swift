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
	var allParkinglots: [Parkinglot]!

    override func viewDidLoad() {
        super.viewDidLoad()

		mapView.showsUserLocation = true
        
        if #available(iOS 9, *) {
            mapView.showsTraffic = true
        }

		// Add annotations for all parking lots to the map
        for singleLot in allParkinglots {
            let lotAnnotation = ParkinglotAnnotation(title: singleLot.name, subtitle: "\(L10n.MAPSUBTITLE(singleLot.free, singleLot.total))", parkinglot: singleLot)
            
            mapView.addAnnotation(lotAnnotation)
            
            // Display the callout if this is the previously selected annotation
            if singleLot.name == detailParkinglot.name {
                mapView.selectAnnotation(lotAnnotation, animated: true)
            }
        }
        
		// Set the map's region to a 1km region around the selected lot
        if let lat = detailParkinglot.coords?.lat, lng = detailParkinglot.coords?.lng {
            let parkinglotRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: lat, longitude: lng), 1000, 1000)
            mapView.setRegion(parkinglotRegion, animated: false)
        } else {
            NSLog("Came to map view with a selected lot that has no coordinates. We're now showing Germany. This is probably not ideal.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// It's nice to show custom pin colors on the map denoting the current state of the parking lot they're referencing
	// green: open
	// red: closed, nodata
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // We don't care about the MKUserLocation here
        guard annotation.isKindOfClass(ParkinglotAnnotation) else { return nil }
        
        let annotation = annotation as! ParkinglotAnnotation
		let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "parkinglotAnnotation")

        if let state = annotation.parkinglot.state {
            switch state {
            case .closed, .unknown:
                annotationView.pinColor = .Red
            case .open:
                annotationView.pinColor = .Green
            case .nodata:
                annotationView.pinColor = .Purple
            }
        }

		annotationView.canShowCallout = true

		return annotationView
	}

}
