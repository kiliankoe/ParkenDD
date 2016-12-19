//
//  Dictionary+TupleInit.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 22/09/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

extension Dictionary {
	init(_ pairs: [Element]) {
		self.init()
		for (k, v) in pairs {
			self[k] = v
		}
	}

	func mapPairs<OutKey: Hashable, OutValue>(_ transform: (Element) throws -> (OutKey, OutValue)) rethrows -> [OutKey: OutValue] {
		return Dictionary<OutKey, OutValue>(try map(transform))
	}

	func filterPairs(_ includeElement: (Element) throws -> Bool) rethrows -> [Key: Value] {
		return Dictionary(try filter(includeElement))
	}
}
