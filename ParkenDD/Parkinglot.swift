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
	let count: Int!
	let free: Int!
	let state: lotstate
	let lat: Double?
	let lon: Double?
	var distance: Double?
    var isFavorite: Bool!
}

/**
Enumerate the state a parkinglot can be in.

- closed: Closed and unavailable, 0 empty spots
- few:    Open, but only a small number of spots remaining
- full:   Open, but no or just very few spots remaining
- many:   Open, many empty spots remaining
- nodata: State unknown, probably not part of Dresden's Parkleitsystem
*/
enum lotstate {
	case closed
	case few
	case full
	case many
	case nodata
}
