//
//  ServerController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 20/02/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum SCResult<S,F> {
	case Success(S)
	case Failure(F)
}

enum SCError {
	case Server
	case Request
	case IncompatibleAPI
	case Unknown
}

struct SCOptions {
	static let supportedAPIVersion = 1.0
	static let useStagingAPI = true
}

struct URL {
	static let apiBaseURL = "https://park-api.higgsboson.tk/"
	static let apiBaseURLStaging = "https://staging-park-api.higgsboson.tk/"
	static let nominatimURL = "https://nominatim.openstreetmap.org/"
}

class ServerController {

	/**
	GET the metadata (API version and list of supported cities) from server

	- parameter completion: handler that is provided with a list of supported cities or an error wrapped in an SCResult
	*/
	static func sendMetadataRequest(completion: (SCResult<[String: String], SCError>) -> Void) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		let metadataURL = SCOptions.useStagingAPI ? URL.apiBaseURLStaging : URL.apiBaseURL
		Alamofire.request(.GET, metadataURL).responseJSON { (_, response, result) -> Void in
			defer { UIApplication.sharedApplication().networkActivityIndicatorVisible = false }
			guard let response = response else { completion(.Failure(SCError.Request)); return }
			guard response.statusCode == 200 else { completion(.Failure(SCError.Server)); return }
			guard let data = result.value else { completion(.Failure(SCError.Server)); return }
			let jsonData = JSON(data)
			guard jsonData["api_version"].doubleValue == SCOptions.supportedAPIVersion else {
				let apiVersion = jsonData["api_version"].doubleValue
				NSLog("Error: Found API Version \(apiVersion). This version of ParkenDD can however only understand \(SCOptions.supportedAPIVersion)")
				completion(.Failure(SCError.IncompatibleAPI))
			}

			completion(.Success(jsonData["cities"].dictionaryObject as! [String: String]))
		}
	}

	struct ParkinglotDataResult {
		let parkinglotList: [Parkinglot]
		let timeUpdated: NSDate?
		let timeDownloaded: NSDate?
		let dataURL: String?
	}

	/**
	Get the current data for all parkinglots

	- parameter completion: handler that is provided with a list of parkinglots or an error wrapped in an SCResult
	*/
	static func sendParkinglotDataRequest(city: String, completion: SCResult<ParkinglotDataResult,SCError> -> Void) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		let parkinglotURL = SCOptions.useStagingAPI ? URL.apiBaseURLStaging + city : URL.apiBaseURL + city
		Alamofire.request(.GET, parkinglotURL).responseJSON { (_, response, result) -> Void in
			defer { UIApplication.sharedApplication().networkActivityIndicatorVisible = false }
			guard let response = response else { completion(.Failure(SCError.Request)); return }
			guard response.statusCode == 200 else { completion(.Failure(SCError.Server)); return }
			guard let data = result.value else { completion(.Failure(SCError.Server)); return }
			let jsonData = JSON(data)

			let UTCdateFormatter = NSDateFormatter()
			UTCdateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
			UTCdateFormatter.timeZone = NSTimeZone(name: "UTC")

			let timeUpdated = UTCdateFormatter.dateFromString(jsonData["last_updated"].stringValue)
			let timeDownloaded = UTCdateFormatter.dateFromString(jsonData["last_downloaded"].stringValue)

			let dataURL = jsonData["url"].stringValue

			var parkinglotList = [Parkinglot]()
			for lot in jsonData["lots"].arrayValue {
				let parkinglot = Parkinglot(name: lot["name"].stringValue,
					total: lot["total"].intValue,
					free: lot["free"].intValue,
					state: lotstate(rawValue: lot["state"].stringValue)!,
					lat: lot["coords"]["lat"].doubleValue,
					lng: lot["coords"]["lng"].doubleValue,
					address: lot["address"].stringValue,
					region: lot["region"].stringValue,
					type: lot["lot_type"].stringValue,
					id: lot["id"].stringValue,
					distance: nil,
					isFavorite: false)

				parkinglotList.append(parkinglot)
			}

			let resultData = ParkinglotDataResult(parkinglotList: parkinglotList, timeUpdated: timeUpdated, timeDownloaded: timeDownloaded, dataURL: dataURL)
			completion(.Success(resultData))
		}
	}

	/**
	Get forecast data for a specified parkinglot and date as CSV data

	- parameter lotID:      id of a parkinlgot
	- parameter fromDate:   date object when the data should start
	- parameter toDate:     date object when the data should end
	- parameter completion: handler
	*/
	static func sendForecastRequest(lotID: String, fromDate: NSDate, toDate: NSDate, completion: (data: [NSDate: Int]) -> ()) {

		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		let fromDateString = dateFormatter.stringFromDate(fromDate)
		let toDateString = dateFormatter.stringFromDate(toDate)

		let parameters = [
			"from": fromDateString,
			"to": toDateString
		]

		Alamofire.request(.GET, Const.apibaseURL + "/Dresden/\(lotID)/timespan", parameters: parameters).responseJSON { (_, res, jsonData, err) -> Void in
			if err == nil && res?.statusCode == 200 {

				let data = JSON(jsonData!)["data"].dictionaryValue
				var parsedData = [NSDate: Int]()

				for (date, load) in data {
					if let parsedDate = dateFormatter.dateFromString(date) {
						parsedData[parsedDate] = load.intValue
					}
				}
				
				completion(data: parsedData)

			} else if err != nil && res?.statusCode == 200 {
				NSLog("Error: \(err?.localizedDescription)")
			} else {
				println(res?.statusCode)
			}
		}
	}

	static func sendNominatimSearchRequest(searchString: String, completion: (lat: Double, lng: Double) -> ()) {
		let parameters: [String:AnyObject] = [
			"q": searchString,
			"format": "json",
			"accept-language": "de",
			"limit": 1,
			"addressdetails": 1
		]

		Alamofire.request(.GET, Const.nominatimURL + "search", parameters: parameters).validate().responseJSON { (_, res, jsonData, err) -> Void in
			let json = JSON(jsonData!)
			completion(lat: json[0]["lat"].doubleValue, lng: json[0]["lon"].doubleValue)
		}
	}

	static func sendNominatimReverseGeocodingRequest(lat: Double, lng: Double, completion: (address: String) -> ()) {
		let parameters: [String:AnyObject] = [
			"format": "json",
			"accept-language": "de",
			"lat": lat,
			"lon": lng,
			"addressdetails": 1
		]

		Alamofire.request(.GET, Const.nominatimURL + "reverse", parameters: parameters).validate().responseJSON { (_, res, jsonData, err) -> Void in
			let json = JSON(jsonData!)
			completion(address: json["address"]["road"].stringValue + " " + json["address"]["city"].stringValue)
		}
	}
}
