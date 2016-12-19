//
//  NSDate+Comparable.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 26/10/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

//extension Date: Comparable {
//	
//}

//public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
//	return lhs === rhs || lhs.compare(rhs) == .OrderedSame
//}

public func ==(lhs: Date, rhs: Date) -> Bool {
	let interval = lhs.timeIntervalSince(rhs)
	return abs(interval) < 60.0
}

public func <(lhs: Date, rhs: Date) -> Bool {
	return lhs.compare(rhs) == .orderedAscending
}
