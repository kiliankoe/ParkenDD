//
//  NSDate+Comparable.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 26/10/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

extension NSDate: Comparable {
	
}

//public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
//	return lhs === rhs || lhs.compare(rhs) == .OrderedSame
//}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
	let interval = lhs.timeIntervalSinceDate(rhs)
	return abs(interval) < 60.0
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
	return lhs.compare(rhs) == .OrderedAscending
}
