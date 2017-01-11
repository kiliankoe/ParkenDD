//
//  ParkinglotAnnotation.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 20/10/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import MapKit
import ParkKit

class ParkinglotAnnotation: NSObject, MKAnnotation {
	
	var title: String?
	var subtitle: String?
	var lot: Lot
	
	var coordinate: CLLocationCoordinate2D {
        return lot.coordinate ?? CLLocationCoordinate2D()
	}
	
	init(title: String, subtitle: String?, lot: Lot) {
		self.title = title
		self.subtitle = subtitle
		self.lot = lot
	}
}
