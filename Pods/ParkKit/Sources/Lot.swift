//
//  Lot.swift
//  ParkKit
//
//  Created by Kilian Költzsch on 03/01/2017.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Marshal
import CoreLocation

/// A parking lot, e.g. 🚗 🅿️ 🚙
public struct Lot {
    /// Street address, if known.
    public let address: String?
    /// A specific coordinate, if known.
    public let coordinate: CLLocationCoordinate2D?
    /// True if forecast data is available for this lot. Can be fetched via ParkKit().fetchForecast
    public let hasForecast: Bool
    /// How many free parking spots are available.
    public let free: Int
    /// How many parking spots are available in total.
    public let total: Int
    /// Unique id for this lot. To be used in forecast requests.
    public let id: String
    /// Is this a structure or underground?
    public let type: String?
    /// Identifiable name.
    public let name: String
    /// Possibly a district or something similar.
    public let region: String?
    /// The state the lot is in.
    public let state: State

    /// States a lot can be in.
    ///
    /// - open: Open for business.
    /// - closed: Closed, new arrivals can't park here.
    /// - nodata: The source provides no information.
    /// - unknown: Unknown. Like wat.
    public enum State: String {
        case open
        case closed
        case nodata
        case unknown
    }

    /// Percentage value for how full the lot currently is
    public var loadPercentage: Double {
        if total > 0 {
            return 1 - Double(free) / Double(total)
        }
        return 0
    }

    /// Calculate the distance between this lot and a given location.
    ///
    /// - Parameter location: perhaps the user location?
    /// - Returns: distance in meters
    public func distance(from location: CLLocation) -> Double? {
        guard let coord = coordinate else { return nil }
        let lotLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        return location.distance(from: lotLocation)
    }

    /// Small helper returning `free` or 0 if the lot is closed
    public var freeRegardingClosed: Int {
        if state == .closed {
            return 0
        }
        return free
    }
}

extension Lot: Unmarshaling {
    public init(object: MarshaledObject) throws {
        address = try object <| "address"
        coordinate = try object <| "coords"
        hasForecast = try object <| "forecast"
        free = try object <| "free"
        total = try object <| "total"
        id = try object <| "id"
        type = try object <| "lot_type"
        name = try object <| "name"
        region = try object <| "region"
        state = try object <| "state"
    }
}
