//
//  ParkinglotAnnotation.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 20/10/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import MapKit

class ParkinglotAnnotation: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var parkinglot: Parkinglot
    
    var coordinate: CLLocationCoordinate2D {
        get {
            if let lat = parkinglot.coords?.lat, lng = parkinglot.coords?.lng {
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
            return CLLocationCoordinate2D()
        }
    }
    
    init(title: String, subtitle: String?, parkinglot: Parkinglot) {
        self.title = title
        self.subtitle = subtitle
        self.parkinglot = parkinglot
    }
}
