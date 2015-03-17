//
//  AppDelegate.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 18/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	var inBackground = false

	var locationManager: CLLocationManager?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.

		// Request permission to get the user's location
		locationManager = CLLocationManager()
		locationManager?.requestWhenInUseAuthorization()

		// Update URLs from remote config
		ServerController.sendConfigDataRequest({
			(parkinglotURL, staticDataURL) in
			if let parkinglotURL = parkinglotURL, staticDataURL = staticDataURL {
				Constants.parkinglotURL = parkinglotURL
				Constants.staticDataURL = staticDataURL
			}
		})

		// we wants a precious light status bar!
		UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)

		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

		inBackground = true
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

		if inBackground {
			// FIXME: Going through childViewControllers like this feels unbelievably prone to errors...
			let mainVC = self.window?.rootViewController?.childViewControllers[0] as! ViewController
			mainVC.updateData()
			inBackground = false
		}
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

