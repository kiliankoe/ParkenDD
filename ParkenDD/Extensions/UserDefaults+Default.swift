//
//  UserDefaults+Default.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 11/01/2017.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import Foundation

extension UserDefaults {
    static func bool(for key: Default) -> Bool {
        return standard.value(forKey: key.rawValue) as? Bool ?? false
    }

    static func string(for key: Default) -> String? {
        return standard.value(forKey: key.rawValue) as? String
    }

    static func array(for key: Default) -> [Any]? {
        return standard.value(forKey: key.rawValue) as? [Any]
    }


    static func set(value: Any, forKey key: Default) {
        standard.set(value, forKey: key.rawValue)
        standard.synchronize()
    }


    static func register(_ defaults: [Default: Any]) {
        for (key, val) in defaults {
            standard.register(defaults: [key.rawValue: val])
        }
    }
}
