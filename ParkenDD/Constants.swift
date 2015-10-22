//
//  Constants.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 08/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

/**
*  Stores global constants
*/
struct Const {
    static let dummyDistance = 100000000.0
}

/**
*  NSUserDefaults keys
*/
struct Defaults {
    static let selectedCity     = "selectedCity"
    static let selectedCityName = "selectedCityName"
    static let sortingType      = "sortingType"
    static let supportedCities  = "supportedCities"
    static let grayscaleUI      = "grayscaleUI"
    static let skipNodataLots   = "skipNodataLots"
    static let favoriteLots     = "favoriteLots"
}

/**
*  Lot table view sorting types
*/
struct Sorting {
    static let standard     = "standard"
    static let distance     = "distance"
    static let alphabetical = "alphabetical"
    static let free         = "free"
    static let euclid       = "euclid"
}
