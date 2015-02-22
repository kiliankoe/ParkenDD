//
//  ServerController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 20/02/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

class ServerController {

	var serverURL: String!

	// FIXME: Yay for the string? error...
	func sendRequest(callback: (sectionNames: [String]?, parkinglotList: [[Parkinglot]]?, updateError: String?) -> ()) {
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

		var URL = NSURL(string: serverURL)
		let request = NSMutableURLRequest(URL: URL!)
		request.HTTPMethod = "GET"

		let task = session.dataTaskWithRequest(request, completionHandler: { (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void in
			if (error == nil) {
				// Success
				if let output = (NSString(data: data, encoding: NSUTF8StringEncoding)) {
					var parseError: NSError?
					let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)

					// Response consists of an Array of sections, e.g. Innere Altstadt, Ring West, etc.
					if let sectionList = parsedObject as? NSArray {

						var sectionNames: [String] = []
						var parkinglotList: [[Parkinglot]] = []

						for section in sectionList {
							if let sectionName: String = section["name"] as? String, lots = section["lots"] as? NSArray {

								// save the section name
								sectionNames.append(sectionName)

								// a temporary array for storing the list of processed Parkinglots
								var lotList: [Parkinglot] = []

								for lot in lots {

									// check for the main parameters
									if let lotName = lot["name"] as? String, lotCount = (lot["count"] as? String)?.toInt(), lotStateString = lot["state"] as? String {

										// the API sometimes returns the amount of free spots as an empty string if the parkinglot is closed, yay
										// but I'm still going to assume that it always exists before making this more complicated
										var lotFree: Int!
										if (lot["free"] as? String) == "" {
											lotFree = 0
										} else {
											lotFree = (lot["free"] as! String).toInt()!
										}

										// "convert" the state into the appropriate enum
										let lotState: lotstate!
										switch lotStateString {
										case "many":
											lotState = lotstate.many
										case "few":
											lotState = lotstate.few
										case "full":
											lotState = lotstate.full
										case "closed":
											lotState = lotstate.closed
										default:
											lotState = lotstate.nodata
										}

										// hehe, lotLat is an awesome name for a variable
										if let lotLat = (lot["lat"] as? NSString)?.doubleValue, lotLon = (lot["lon"] as? NSString)?.doubleValue {
											let parkingLot = Parkinglot(section: sectionName, name: lotName, count: lotCount, free: lotFree, state: lotState, lat: lotLat, lon: lotLon)
											lotList.append(parkingLot)
										} else {
											// apparently this lot doesn't have coordinates, which is also kind of weird
											let parkingLot = Parkinglot(section: sectionName, name: lotName, count: lotCount, free: lotFree, state: lotState, lat: nil, lon: nil)
											lotList.append(parkingLot)
										}
									}
								}
								parkinglotList.append(lotList)
							}
						}
						callback(sectionNames: sectionNames, parkinglotList: parkinglotList, updateError: nil)
					} else {
						callback(sectionNames: nil, parkinglotList: nil, updateError: "serverError")
					}
				} else {
					callback(sectionNames: nil, parkinglotList: nil, updateError: "serverError")
				}
			}
			else {
				// Failure
				println("HTTP Request Failure: %@", error.localizedDescription);
				callback(sectionNames: nil, parkinglotList: nil, updateError: "requestError")
			}
		})
		task.resume()
	}
	
}
