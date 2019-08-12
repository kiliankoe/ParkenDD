//
//  ParkError.swift
//  ParkKit
//
//  Created by Kilian Költzsch on 03/01/2017.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import Foundation

/// Possible errors encountered throughout ParkKit.
///
/// - request: The web request failed, a further error is included as a payload.
/// - server: The server failed providing a sensible response, a statusCode is included as a payload.
/// - invalidServerURL: The server URL is invalid.
/// - notFound: There was no data to be found.
/// - decoding: The data could not be decoded.
/// - unknown: Something very bad happened 😱
public enum ParkError: Error {
    case request(Error?)
    case server(statusCode: Int)
    case invalidServerURL
    case notFound
    case decoding
    case unknown
}
