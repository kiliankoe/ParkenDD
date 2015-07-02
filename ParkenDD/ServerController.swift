//
//  ServerController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 20/02/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ServerController {

	enum UpdateError {
		case Server
		case Request
		case IncompatibleAPI
		case Unknown
	}

	/**
	GET the metadata (API version and list of supported cities) from server

	:param: completion handler that is provided with a list of supported cities and an optional error
	*/
	static func sendMetadataRequest(completion: (supportedCities: [String: String], updateError: UpdateError?) -> ()) {
		Alamofire.request(.GET, Const.apibaseURL, parameters: nil).responseJSON { (_, res, jsonData, err) -> Void in
			switch (err, res?.statusCode) {
			case (_, .Some(200)):
				let json = JSON(jsonData!)
				// Because getting "1.0" into a doubleValue returns nil - Why?
				if json["api_version"].string == "\(Const.supportedAPIVersion)" {
					completion(supportedCities: (json["cities"].dictionaryObject as! [String:String]), updateError: nil)
				} else {
					let apiversion = json["api_version"].string
					NSLog("Error: Found API Version \(apiversion). This app can however only understand \(Const.supportedAPIVersion)")
					completion(supportedCities: [String : String](), updateError: .IncompatibleAPI)
				}
			case (let err, .Some(400..<600)):
				NSLog("Error: \(err!.localizedDescription)")
				completion(supportedCities: [String:String](), updateError: .Server)
			case (let err, _):
				NSLog("Error: \(err!.localizedDescription)")
				completion(supportedCities: [String:String](), updateError: .Request)
			}
		}
	}

	/**
	Get the current data for all parkinglots by asking the happy PHP scraper and adding a "Pretty please with sugar on top" to the request

	:param: completion handler that is provided with a list of parkinglots and an optional error
	*/
	static func sendParkinglotDataRequest(city: String, completion: (parkinglotList: [Parkinglot], timeUpdated: NSDate?, timeDownloaded: NSDate?, dataSource: String?, updateError: UpdateError?) -> ()) {

		// TODO: Include timeouts?
//		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
//		sessionConfig.timeoutIntervalForRequest = 15.0
//		sessionConfig.timeoutIntervalForResource = 20.0
//		let alamofireManager = Alamofire.Manager(configuration: sessionConfig)
//		alamofireManager.request...
		Alamofire.request(.GET, Const.apibaseURL + city).responseJSON { (_, res, jsonData, err) -> Void in
			switch (err, res?.statusCode) {
			case (_, .Some(200)):
				let json = JSON(jsonData!)

				let UTCdateFormatter = NSDateFormatter()
				UTCdateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
				UTCdateFormatter.timeZone = NSTimeZone(name: "UTC")

				let timeUpdated = UTCdateFormatter.dateFromString(json["last_updated"].stringValue)
				let timeDownloaded = UTCdateFormatter.dateFromString(json["last_downloaded"].stringValue)

				let dataSource = json["data_source"].stringValue

				var parkinglotList = [Parkinglot]()
				for lot in json["lots"].arrayValue {

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
				completion(parkinglotList: parkinglotList, timeUpdated: timeUpdated, timeDownloaded: timeDownloaded, dataSource: dataSource, updateError: nil)
			case (_, .Some(400..<600)):
				completion(parkinglotList: [], timeUpdated: nil, timeDownloaded: nil, dataSource: nil, updateError: .Server)
			case (let err, _):
				NSLog("Error: \(err!.localizedDescription)")
				completion(parkinglotList: [], timeUpdated: nil, timeDownloaded: nil, dataSource: nil, updateError: .Request)
			default:
				NSLog("Error: Something unknown happened to the request 😨")
				completion(parkinglotList: [], timeUpdated: nil, timeDownloaded: nil, dataSource: nil, updateError: .Unknown)
			}
		}
	}

	/**
	Get forecast data for a specified parkinglot and date as CSV data

	:param: lotID      id of a parkinlgot
	:param: fromDate   date object when the data should start
	:param: toDate     date object when the data should end
	:param: completion handler
	*/
	static func sendForecastRequest(lotID: String, fromDate: NSDate, toDate: NSDate, completion: () -> ()) {

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
				println(jsonData)
			} else if err != nil && res?.statusCode == 200 {
				NSLog("Error: \(err?.localizedDescription)")
			} else {
				println(res?.statusCode)
			}
		}
	}
}
