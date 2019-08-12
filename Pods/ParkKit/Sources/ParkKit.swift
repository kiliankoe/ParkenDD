//
//  ParkError.swift
//  ParkKit
//
//  Created by Kilian Költzsch on 03/01/2017.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import Foundation

/// All methods to fetch data from the server are built into this type.
public struct ParkKit {
    internal let serverURL: URL

    /// Initialize a new client with a server URL. Defaults to server at parkendd.de if no URL is provided.
    ///
    /// - Parameter url: optional custom server URL
    public init(withURL url: URL = URL(string: "https://api.parkendd.de")!) {
        self.serverURL = url
    }

    /// Fetch all cities known to the server.
    ///
    /// - Parameters:
    ///   - onFailure: failure handler, is handed a `ParkError`
    ///   - onSuccess: success handler, is handed a `MetaResponse` containing further information
    public func fetchCities(onFailure: @escaping (ParkError) -> Void, onSuccess: @escaping (MetaResponse) -> Void) {
        fetchJSON(url: serverURL, onFailure: onFailure) { json in
            let apiVersion = (json["api_version"] as? String) ?? ""
            let serverVersion = (json["server_version"] as? String) ?? ""
            let reference = (json["reference"] as? String) ?? ""

            guard let citiesDict = json["cities"] as? [String: Any] else {
                onFailure(.decoding)
                return
            }

            var cities = [City]()
            for (_, details) in citiesDict {
                guard let details = details as? NSDictionary else { continue }
                guard let city = City.from(details) else { continue }
                cities.append(city)
            }

            cities.sort { $0.name < $1.name }

            let response = MetaResponse(apiVersion: apiVersion, serverVersion: serverVersion, reference: reference, cities: cities)
            onSuccess(response)
        }
    }

    /// Fetch all known lots for a given city.
    ///
    /// - Parameters:
    ///   - city: city name
    ///   - onFailure: failure handler, is handed a `ParkError`
    ///   - onSuccess: success handler, is handed a `LotResponse` containing further information
    public func fetchLots(forCity city: String, onFailure: @escaping (ParkError) -> Void, onSuccess: @escaping (LotResponse) -> Void) {
        guard let url = URL(string: city, relativeTo: serverURL) else {
            onFailure(.invalidServerURL)
            return
        }
        fetchJSON(url: url, onFailure: onFailure) { json in
            let lastDownloadedStr = (json["last_downloaded"] as? String) ?? ""
            let lastUpdatedStr = (json["last_updated"] as? String) ?? ""

            let iso = DateFormatter.iso()
            let lastDownloaded = iso.date(from: lastDownloadedStr) ?? Date()
            let lastUpdated = iso.date(from: lastUpdatedStr) ?? Date()

            guard let lotsArr = json["lots"] as? [[String: Any]] else {
                onFailure(.decoding)
                return
            }

            var lots = [Lot]()
            for singleLot in lotsArr {
                guard let lot = Lot.from(singleLot as NSDictionary) else { continue }
                lots.append(lot)
            }

            let response = LotResponse(lastDownloaded: lastDownloaded, lastUpdated: lastUpdated, lots: lots)
            onSuccess(response)
        }
    }

    /// Fetch forecast data for a given lot and city.
    ///
    /// - Parameters:
    ///   - lot: lot identifier
    ///   - city: city name
    ///   - start: starting date
    ///   - end: ending date
    ///   - onFailure: failure handler, is handed a `ParkError`
    ///   - onSuccess: success handler, is handed a `ForecastResponse` containing further information
    public func fetchForecast(forLot lot: String, inCity city: String, startingAt start: Date, endingAt end: Date, onFailure: @escaping (ParkError) -> Void, onSuccess: @escaping (ForecastResponse) -> Void) {
        let iso = DateFormatter.iso()
        guard let url = URL(string: "\(city)/\(lot)/timespan?from=\(iso.string(from: start))&to=\(iso.string(from: end))", relativeTo: serverURL) else {
            onFailure(.invalidServerURL)
            return
        }

        fetchJSON(url: url, onFailure: onFailure) { json in
            guard let version = (json["version"] as? Double) else {
                onFailure(.decoding)
                return
            }

            guard let data = json["data"] as? [String: String] else {
                onFailure(.decoding)
                return
            }

            var forecast = [(Date, Int)]()
            for (key, val) in data {
                guard let date = iso.date(from: key) else { continue }
                guard let load = Int(val) else { continue }

                forecast.append((date, load))
            }

            // The fact that these were stored in a dictionary throws off sorting, but it's definitely nice to have here.
            forecast.sort { (first, second) in
                first.0 < second.0
            }

            let response = ForecastResponse(version: version, forecast: forecast)
            onSuccess(response)
        }
    }

    internal func fetchJSON(url: URL, onFailure fail: @escaping (ParkError) -> Void, onSuccess succeed: @escaping ([String: Any]) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                fail(.request(error))
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                fail(.request(nil))
                return
            }

            switch statusCode / 100 {
            case 4:
                fail(.notFound)
                return
            case 5:
                fail(.server(statusCode: statusCode))
                return
            default:
                break
            }

            guard let data = data else {
                fail(.unknown)
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                fail(.decoding)
                return
            }

            succeed(json!)
        }.resume()
    }
}
