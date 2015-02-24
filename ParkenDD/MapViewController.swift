//
//  MapViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 18/02/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

	@IBOutlet weak var mapView: MKMapView!

	var detailParkinglot: Parkinglot!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
