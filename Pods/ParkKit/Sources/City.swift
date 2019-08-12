//
//  City.swift
//  ParkKit
//
//  Created by Kilian Költzsch on 03/01/2017.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Mapper
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

extension City: Mappable {
    public init(map: Mapper) throws {
        try name = map.from("name")
        try coordinate = map.from("coords")
        try source = map.from("source")
        try url = map.from("url")
        attribution = map.optionalFrom("attribution")
        try hasActiveSupport = map.from("active_support")
    }
}

extension City.Attribution: Mappable {
    public init(map: Mapper) throws {
        try contributor = map.from("contributor")
        try license = map.from("license")
        try url = map.from("url")
    }
}
