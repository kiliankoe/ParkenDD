//
//  Result.swift
//  ParkKit
//
//  Created by Kilian Költzsch on 19.05.17.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(Error)

    init(success value: Value) {
        self = .success(value)
    }

    init(failure error: Error) {
        self = .failure(error)
    }

    public func get() throws -> Value {
        switch self {
        case let .success(x): return x
        case let .failure(e): throw e
        }
    }

    public var success: Value? {
        switch self {
        case let .success(x): return x
        case .failure: return nil
        }
    }

    public var failure: Error? {
        switch self {
        case .success: return nil
        case let .failure(e): return e
        }
    }
}

public func ?? <T>(result: Result<T>, defaultValue: @autoclosure () -> T) -> T {
    switch result {
    case let .success(x): return x
    case .failure: return defaultValue()
    }
}
