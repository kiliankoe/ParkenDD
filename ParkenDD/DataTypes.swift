//
//  DataTypes.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 05/10/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper


/**
*  Coords - Stores a latitude and longitude coordinate
*/
struct Coords: Mappable {
    var lat: Double
    var lng: Double
    
    init?(_ map: Map) {
        lat = map["lat"].valueOrFail()
        lng = map["lng"].valueOrFail()
    }
    
    mutating func mapping(map: Map) {
        
    }
}


/**
*  City - Stores name, coords, source URL and data URL.
*/
struct City: Mappable {
    var name: String
    var coords: Coords?
    var source: NSURL?
    var url: NSURL?
    
    init?(_ map: Map) {
        name = map["name"].valueOrFail()
    }
    
    mutating func mapping(map: Map) {
        coords <- map["coords"]
        source <- (map["source"], URLTransform())
        url    <- (map["url"], URLTransform())
    }
}


/**
*  Metadata - Stores cities list, version of API and server software and reference URL.
*/
struct Metadata: Mappable {
    var apiVersion: String
    var serverVersion: String?
    var reference: NSURL?
    var cities: [String: City]?
    
    init?(_ map: Map) {
        apiVersion = map["api_version"].valueOrFail()
    }
    
    mutating func mapping(map: Map) {
        serverVersion <- map["server_version"]
        reference     <- (map["reference"], URLTransform())
        cities        <- map["cities"]
    }
}


/**
*  Parkinglot - Stores all data for a single parking lot.
*/
struct Parkinglot: Mappable {
    var address: String?
    var coords: Coords?
    var forecast: Bool?
    var free: Int
    var id: String
    var lotType: String?
    var name: String
    var region: String?
    var state: Lotstate?
    var total: Int
    
    var loadPercentage: Int {
        get {
            var load = 100
            if total > 0 {
                load = Int(round(100 - (Double(free) / Double(total) * 100)))
            }
            load = load < 0 ? 0 : load
            return load
        }
    }
    
    func distance(from userLocation: CLLocation) -> Double {
        guard let lat = coords?.lat, lng = coords?.lng else { return Const.dummyDistance }
        let lotLocation = CLLocation(latitude: lat, longitude: lng)
        return userLocation.distanceFromLocation(lotLocation)
    }
    
    init?(_ map: Map) {
        free  = map["free"].valueOrFail()
        id    = map["id"].valueOrFail()
        name  = map["name"].valueOrFail()
        total = map["total"].valueOrFail()
    }
    
    mutating func mapping(map: Map) {
        address  <- map["address"]
        coords   <- map["coords"]
        forecast <- map["forecast"]
        lotType  <- map["type"]
        region   <- map["region"]
        state    <- (map["state"], EnumTransform<Lotstate>())
    }
}


/**
Lotstate enum

- open:    lot is open and ready for business
- closed:  lot is closed and can't be used
- nodata:  no data is available for lot
- unknown: lot state is explicitly unknown
*/
enum Lotstate: String {
    case open = "open"
    case closed = "closed"
    case nodata = "nodata"
    case unknown = "unknown"
}


/**
*  ParkinglotData - Collection of lots and when they were downloaded and last updated.
*/
struct ParkinglotData: Mappable {
    var lots: [Parkinglot]?
    var lastDownloaded: NSDate?
    var lastUpdated: NSDate?
    
    init?(_ map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        lots           <- map["lots"]
        lastDownloaded <- (map["last_downloaded"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss"))
        lastUpdated    <- (map["last_updated"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss"))
    }
}


/**
*  A result type to be returned from the API.
*/
struct APIResult {
    let metadata: Metadata
    let parkinglotData: ParkinglotData
}
