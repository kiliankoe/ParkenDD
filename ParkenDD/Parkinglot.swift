//
//  Parkinglot.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 20/02/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

struct Parkinglot {
	let section: String!
	let name: String!
	let count: Int!
	let free: Int!
	let state: lotstate
	let lat: Double?
	let lon: Double?
}

enum lotstate {
	case closed
	case few
	case full
	case many
	case nodata
}
