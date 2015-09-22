//
//  Parkinglot.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 20/02/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

/**
*  Stores a single parkinglot
*/
struct Parkinglot {
	let name: String!
	let total: Int!
	let free: Int!
	let state: lotstate
	let lat: Double?
	let lng: Double?
	let address: String?
	let region: String?
	let type: String?
	let id: String!

	var distance: Double?
	var isFavorite: Bool!
}

/**
Enumerate the states a parkinglot can be in.
*/
enum lotstate: String {
	case open = "open"
	case closed = "closed"
	case nodata = "nodata"
	case unknown = "unknown"
}
