//
//  Colors.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 06/04/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

struct Colors {
	static let favYellow = UIColor(rgba: "#F9E510")
	static let unfavYellow = UIColor(rgba: "#F4E974")

	/**
	Return a color between green and red based on a percentage value

	- parameter percentage: value between 0 and 1
	- parameter emptyLots: number of empty lots

	- returns: UIColor
	*/
	static func colorBasedOnPercentage(percentage: Double, emptyLots: Int) -> UIColor {

		let hue = 1 - (percentage * 0.3 + 0.7) // I want to limit this to the colors between 0 and 0.3

		let useGrayscale = NSUserDefaults.standardUserDefaults().boolForKey(Defaults.grayscaleUI)
		if useGrayscale {
			if emptyLots <= 0 {
				return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
			}
			return UIColor(red: CGFloat(1 - (hue+0.2)), green: CGFloat(1 - (hue+0.2)), blue: CGFloat(1 - (hue+0.2)), alpha: 1.0)
		}

		if emptyLots <= 0 {
			return UIColor(hue: CGFloat(hue), saturation: 0.54, brightness: 0.7, alpha: 1.0)
		}
		return UIColor(hue: CGFloat(hue), saturation: 0.54, brightness: 0.8, alpha: 1.0)
	}
}

// Props to github.com/yeahdongcn/UIColor-Hex-Swift
extension UIColor {
	convenience init(rgba: String) {
		var red:   CGFloat = 0.0
		var green: CGFloat = 0.0
		var blue:  CGFloat = 0.0
		var alpha: CGFloat = 1.0

		if rgba.hasPrefix("#") {
			let index   = rgba.startIndex.advancedBy(1)
			let hex     = rgba.substringFromIndex(index)
			let scanner = NSScanner(string: hex)
			var hexValue: CUnsignedLongLong = 0
			if scanner.scanHexLongLong(&hexValue) {
				switch (hex.characters.count) {
				case 3:
					red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
					green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
					blue  = CGFloat(hexValue & 0x00F)              / 15.0
				case 4:
					red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
					green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
					blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
					alpha = CGFloat(hexValue & 0x000F)             / 15.0
				case 6:
					red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
					green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
					blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
				case 8:
					red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
					green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
					blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
					alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
				default:
					print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
				}
			} else {
				print("Scan hex error")
			}
		} else {
			print("Invalid RGB string, missing '#' as prefix", terminator: "")
		}
		self.init(red:red, green:green, blue:blue, alpha:alpha)
	}
}
