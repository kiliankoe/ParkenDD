//
//  Default.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 11/01/2017.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import Foundation

enum Default: String {
    case selectedCity
    case selectedCityName
    case sortingType
    case supportedCities
    case grayscaleUI
    case skipNodataLots
    case favoriteLots
    case showExperimentalCities

    static func `default`() -> [Default: Any] {
        return [
            .selectedCity: "Dresden",
            .selectedCityName: "Dresden",
            .sortingType: "standard",
            .supportedCities: ["Dresden"],
            .grayscaleUI: false,
            .skipNodataLots: false,
            .favoriteLots: [],
            .showExperimentalCities: false,
        ]
    }
}
