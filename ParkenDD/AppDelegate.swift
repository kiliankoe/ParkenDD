//
//  AppDelegate.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 18/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import ParkKit
import Fabric
import Crashlytics

let park = ParkKit()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	var inBackground = false

	var supportedCities: [String]?
	var citiesList = [City]() {
		didSet {
            supportedCities = citiesList.map{ $0.name }.sorted()
		}
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		Fabric.with([Crashlytics()])

        Location.manager.requestWhenInUseAuthorization()

        UserDefaults.register(Default.default())

		supportedCities = UserDefaults.standard.array(forKey: Defaults.supportedCities) as? [String]

		// apply custom font to UIBarButtonItems (mainly the back button) as well
		let font = UIFont(name: "AvenirNext-Medium", size: 18.0)
		var attrsDict = [String: AnyObject]()
		attrsDict[NSFontAttributeName] = font
		UIBarButtonItem.appearance().setTitleTextAttributes(attrsDict, for: UIControlState())

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

		inBackground = true
		UserDefaults.standard.set(supportedCities, forKey: Defaults.supportedCities)
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

		if inBackground {
			// FIXME: Going through childViewControllers like this feels unbelievably prone to errors...
			let mainVC = self.window?.rootViewController?.childViewControllers[0] as? LotlistViewController
			mainVC?.updateData()
			inBackground = false
		}
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	@available(iOS 9.0, *)
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		var cityName = ""
		var cityId = ""
		switch shortcutItem.type {
		case "io.kilian.parkendd.ingolstadt":
			cityName = "Ingolstadt"
			cityId = "Ingolstadt"
		case "io.kilian.parkendd.zuerich":
			cityName = "Zürich"
			cityId = "Zuerich"
		default:
			cityName = "Dresden"
			cityId = "Dresden"
		}
		UserDefaults.standard.set(cityId, forKey: Defaults.selectedCity)
		UserDefaults.standard.set(cityName, forKey: Defaults.selectedCityName)
		UserDefaults.standard.synchronize()
	}


}
