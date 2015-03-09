//
//  StaticData.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 08/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

// Due to the nature of how this data is downloaded I don't want to integrate it directly with the parking lots for now.
// It's better off declared as a separate dictionary, at least for now.

// Altmarkt is declared here for reference. The others are added on the GET request.

let StaticData: [String:[String:AnyObject?]] = [
	"Altmarkt": [
		"type": "Tiefgarage",
		"address": "Wilsdruffer Straße, 01067 Dresden",
		"latitude": 51.0502683537,
		"longitude": 13.7378780267,
		"times": "Täglich von 0 bis 24 Uhr",
		"times_m": "0-24",
		"rate": "Erste und zweite angefangene Stunde je 1,50 Euro. Dritte angefangene Stunde 2,00 Euro. Jede weitere angefangene Stunde 2,50 Euro. Tageshöchstsatz 17,00 Euro",
		"reservations": false,
		"map": nil,
		"parkleitsystem": true,
		"thumbnail": "http://www.dresden.de/img/parken/standorte/TG16.jpg"
	]
]
