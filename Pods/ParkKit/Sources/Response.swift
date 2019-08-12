//
//  Response.swift
//  ParkKit
//
//  Created by Kilian Költzsch on 03/01/2017.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import Foundation

/// Meta response value containing a list of all supported cities supported by this server.
public struct MetaResponse {
    /// Current API version.
    public let apiVersion: String
    /// Current server software version, e.g. the version of ParkAPI running on the server.
    public let serverVersion: String
    /// A reference to the instance running on the server. Possibly a project URL.
    public let reference: String

    /// The actual list of cities and their data.
    public let cities: [City]
}

/// Lot response value containing a list of all lots for a given city and timestamps for when the data was last updated.
public struct LotResponse {
    /// Timestamp when the data was downloaded from the city's server. Should never be more than ~5 minutes ago.
    public let lastDownloaded: Date
    /// Timestamp when the data was presumably last updated on the city's server.
    public let lastUpdated: Date

    /// The actual list of lots and their data.
    public let lots: [Lot]
}

/// Forecast response value containing a list of forecast values.
public struct ForecastResponse {
    /// Version of the forecast data.
    public let version: Double
    /// The actual forecast data as a list of dates and load values.
    public let forecast: [(Date, Int)]
}
