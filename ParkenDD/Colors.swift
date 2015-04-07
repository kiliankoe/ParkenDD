//
//  Colors.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 06/04/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

struct Colors {
	// These come from flatuicolors.com, thanks for the site @ahmetsulek!
	static let turquoise = UIColor(red: 26.0/255.0, green: 188.0/255.0, blue: 156.0/255.0, alpha: 1.0)
	static let greenSea = UIColor(red: 22.0/255.0, green: 160.0/255.0, blue: 133.0/255.0, alpha: 1.0)
	static let sunFlower = UIColor(red: 241.0/255.0, green: 196.0/255.0, blue: 15.0/255.0, alpha: 1.0)
	static let orange = UIColor(red: 243.0/255.0, green: 156.0/255.0, blue: 18.0/255.0, alpha: 1.0)
	static let emerald = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0)
	static let nephritis = UIColor(red: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255.0, alpha: 1.0)
	static let carrot = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1.0)
	static let pumpkin = UIColor(red: 211.0/255.0, green: 84.0/255.0, blue: 0.0/255.0, alpha: 1.0)
	static let peterRiver = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
	static let belizeHole = UIColor(red: 41.0/255.0, green: 128.0/255.0, blue: 185.0/255.0, alpha: 1.0)
	static let alizarin = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
	static let pomegranate = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1.0)
	static let amethyst = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0)
	static let wisteria = UIColor(red: 142.0/255.0, green: 68.0/255.0, blue: 173.0/255.0, alpha: 1.0)
	static let clouds = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
	static let silver = UIColor(red: 189.0/255.0, green: 195.0/255.0, blue: 199.0/255.0, alpha: 1.0)
	static let wetAsphalt = UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 1.0)
	static let midnightBlue = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1.0)
	static let concrete = UIColor(red: 149.0/255.0, green: 165.0/255.0, blue: 166.0/255.0, alpha: 1.0)
	static let asbestos = UIColor(red: 127.0/255.0, green: 140.0/255.0, blue: 141.0/255.0, alpha: 1.0)

	// Stolen from the app Departure 2
	static let flatGreen = UIColor(red: 142.0/255.0, green: 211.0/255.0, blue: 95.0/255.0, alpha: 1.0)
	static let flatOrange = UIColor(red: 240.0/255.0, green: 168.0/255.0, blue: 83.0/255.0, alpha: 1.0)
	static let flatRed = UIColor(red: 239.0/255.0, green: 83.0/255.0, blue: 84.0/255.0, alpha: 1.0)

	/**
	Return a color between green and red based on a percentage value

	:param: percentage value between 0 and 1
	:param: emptyLots number of empty lots

	:returns: UIColor
	*/
	static func colorBasedOnPercentage(percentage: Double, emptyLots: Int) -> UIColor {

		let hue = 1 - (percentage * 0.3 + 0.7) // I want to limit this to the colors between 0 and 0.3

		let useGrayscale = NSUserDefaults.standardUserDefaults().boolForKey("grayscaleColors")
		if useGrayscale {
			if emptyLots <= 0 {
				return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
			}
			return UIColor(red: CGFloat(hue+0.2), green: CGFloat(hue+0.2), blue: CGFloat(hue+0.2), alpha: 1.0)
		}

		if emptyLots <= 0 {
			return UIColor(hue: CGFloat(hue), saturation: 0.54, brightness: 0.7, alpha: 1.0)
		}
		return UIColor(hue: CGFloat(hue), saturation: 0.54, brightness: 0.8, alpha: 1.0)
	}
}
