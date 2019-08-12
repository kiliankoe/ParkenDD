//
//  City.swift
//  ParkKit
//
//  Created by Kilian Költzsch on 03/01/2017.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Marshal
import CoreLocation

/// Slightly bigger than a town, you get the idea.
public struct City {
    /// Name of the city, e.g. "Dresden"
    public let name: String
    /// Center coordinate
    public let coordinate: CLLocationCoordinate2D
    /// The data source where ParkAPI gathers the lot data. Could be a feed or HTML page.
    public let source: URL
    /// A url that can be used for linking to a city's data.
    public let url: URL
    /// Attribution information containing metadata, if known.
    public let attribution: Attribution?
    /// True if the city is being actively supported (updated rather quickly if things break).
    public let hasActiveSupport: Bool

    /// Attribution information
    public struct Attribution {
        /// Who owns or contributed the given data.
        let contributor: String
        /// What license is the data being provided under.
        let license: String
        /// URL to more legal information regarding the data.
        let url: URL
    }
}

extension City: Unmarshaling {
    public init(object: MarshaledObject) throws {
        name = try object <| "name"
        coordinate = try object <| "coords"
        source = try object <| "source"
        url = try object <| "url"
        attribution = try object <| "attribution"
        hasActiveSupport = try object <| "active_support"
    }
}

extension City.Attribution: Unmarshaling {
    public init(object: MarshaledObject) throws {
        contributor = try object <| "contributor"
        license = try object <| "license"
        url = try object <| "url"
    }
}
