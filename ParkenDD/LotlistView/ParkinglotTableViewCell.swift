//
//  ParkplatzTableViewCell.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 19/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

//class ParkinglotTableViewCell: MCSwipeTableViewCell {
class ParkinglotTableViewCell: UITableViewCell {

	@IBOutlet weak var parkinglotNameLabel: UILabel?
	@IBOutlet weak var parkinglotAddressLabel: UILabel?
	@IBOutlet weak var parkinglotLoadLabel: UILabel?
	@IBOutlet weak var parkinglotTendencyLabel: UILabel?
	@IBOutlet weak var forecastIndicator: UIImageView?
	@IBOutlet weak var favTriangle: UIImageView?

	var parkinglot: Parkinglot?
	
	var distance: Double = 0.0 {
		didSet {
			guard distance != Const.dummyDistance else {
				parkinglotAddressLabel?.text = L10n.UNKNOWNADDRESS.string
				return
			}
			parkinglotAddressLabel?.text = "\((round(distance/100))/10)km"
		}
	}
	
	func setParkinglot(lot: Parkinglot) {
		parkinglot = lot
		
		// Quickfix for issue #103
		let sanitizedLotName = lot.name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		
		if let lotType = lot.lotType where lotType != "" {
			parkinglotNameLabel?.text = "\(lotType) \(sanitizedLotName)"
		} else {
			parkinglotNameLabel?.text = sanitizedLotName
		}
		
		parkinglotLoadLabel?.text = "\(lot.free)"
		
		// check if location sorting is enabled, then we're displaying distance instead of address
		let sortingType = NSUserDefaults.standardUserDefaults().stringForKey(Defaults.sortingType)!
		if sortingType == Sorting.standard || sortingType == Sorting.alphabetical || sortingType == Sorting.free {
			if lot.address == "" {
				parkinglotAddressLabel?.text = L10n.UNKNOWNADDRESS.string
			} else {
				parkinglotAddressLabel?.text = lot.address
			}
		} else {
			parkinglotAddressLabel?.text = L10n.WAITINGFORLOCATION.string
		}
		
		// Set all labels to be white, 'cause it looks awesome
		parkinglotNameLabel?.textColor = UIColor.whiteColor()
		parkinglotAddressLabel?.textColor = UIColor.whiteColor()
		parkinglotLoadLabel?.textColor = UIColor.whiteColor()
		parkinglotTendencyLabel?.textColor = UIColor.whiteColor()
		
		// Set the cell's bg color dynamically based on the load percentage.
		var percentage = lot.total > 0 ? 1 - (Double(lot.free) / Double(lot.total)) : 0.99
		if percentage < 0.1 {
			percentage = 0.1
		} else if percentage > 0.99 {
			percentage = 0.99
		}
		backgroundColor = Colors.colorBasedOnPercentage(percentage, emptyLots: lot.free)
		
		// Show the forecast indicator if that data is available
		if let forecastAvailable = lot.forecast where forecastAvailable {
			forecastIndicator?.image = UIImage(named: "graphArrow")
		} else {
			forecastIndicator?.image = nil
		}
		forecastIndicator?.alpha = 0.6
		forecastIndicator?.tintColor = UIColor.whiteColor()
		
		// TODO: Do all kinds of things with the cell according to the state of the lot
		if let lotState = lot.state {
			switch lotState {
			case .closed:
				parkinglotTendencyLabel?.text = L10n.CLOSED.string
				backgroundColor = UIColor.grayColor()
				parkinglotLoadLabel?.text = "X"
//                parkinglotLoadLabel?.attributedText = NSAttributedString(string: "\(lot.free)", attributes: [NSStrikethroughStyleAttributeName: 1])
			case .nodata:
				parkinglotLoadLabel?.text = "?"
				parkinglotTendencyLabel?.text = L10n.UNKNOWNLOAD.string
				backgroundColor = UIColor.lightGrayColor()
			case .open:
				parkinglotTendencyLabel?.text = "\(lot.loadPercentage)% \(L10n.OCCUPIED.string)"
			case .unknown:
				parkinglotTendencyLabel?.text = "\(lot.loadPercentage)% \(L10n.OCCUPIED.string)"
			}
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}
