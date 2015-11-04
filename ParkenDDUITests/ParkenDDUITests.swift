//
//  ParkenDDUITests.swift
//  ParkenDDUITests
//
//  Created by Kilian Költzsch on 03/11/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import XCTest

class ParkenDDUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
		
		continueAfterFailure = false
		
		let app = XCUIApplication()
//		setLanguage(app)
		app.launch()
    }
    
    func testExample() {
		let app = XCUIApplication()
		
		snapshot("01LotList")
		
		app.tables.staticTexts["Altmarkt"].tap()
		snapshot("02MapView")
		
		let parkenddMapviewNavigationBar = app.navigationBars["ParkenDD.MapView"]
		parkenddMapviewNavigationBar.buttons["Prognose"].tap()
		snapshot("03Forecast")
    }
    
}
