//
//  SnapshotHelper.swift
//  Example
//
//  Created by Felix Krause on 10/8/15.
//  Copyright © 2015 Felix Krause. All rights reserved.
//

import Foundation
import XCTest

var deviceLanguage = ""

@available(iOS 9.0, *)
func setLanguage(_ app: XCUIApplication)
{
    Snapshot.setLanguage(app)
}

@available(iOS 9.0, *)
func snapshot(_ name: String, waitForLoadingIndicator: Bool = true)
{
    Snapshot.snapshot(name, waitForLoadingIndicator: waitForLoadingIndicator)
}



@objc class Snapshot: NSObject
{
    class func setLanguage(_ app: XCUIApplication)
    {
        let path = "/tmp/language.txt"
        
        do {
            let locale = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
            deviceLanguage = locale.substring(to: locale.characters.index(locale.startIndex, offsetBy: 2, limitedBy:locale.endIndex)!)
            app.launchArguments = ["-AppleLanguages", "(\(deviceLanguage))", "-AppleLocale", "\"\(locale)\"","-ui_testing"]
        } catch {
            print("Couldn't detect/set language...")
        }
    }
    
    class func snapshot(_ name: String, waitForLoadingIndicator: Bool = false)
    {
        if (waitForLoadingIndicator)
        {
            waitForLoadingIndicatorToDisappear()
        }
        print("snapshot: \(name)") // more information about this, check out https://github.com/krausefx/snapshot
        
        let view = XCUIApplication()
        let start = view.coordinate(withNormalizedOffset: CGVector(dx: 32.10, dy: 30000))
        let finish = view.coordinate(withNormalizedOffset: CGVector(dx: 31, dy: 30000))
        start.press(forDuration: 0, thenDragTo: finish)
        sleep(1)
    }
    
    class func waitForLoadingIndicatorToDisappear()
    {
        let query = XCUIApplication().statusBars.children(matching: .other).element(boundBy: 1).children(matching: .other)
        
        while (query.count > 4) {
            sleep(1)
            print("Number of Elements in Status Bar: \(query.count)... waiting for status bar to disappear")
        }
    }
}
