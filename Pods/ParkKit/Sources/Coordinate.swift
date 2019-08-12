//
//  Coordinate.swift
//  ParkKit
//
//  Created by Kilian Költzsch on 03/01/2017.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Marshal
import CoreLocation

extension CLLocationCoordinate2D: Unmarshaling {
    public init(object: MarshaledObject) throws {
        latitude = try object <| "lat"
        longitude = try object <| "lng"
    }
}
