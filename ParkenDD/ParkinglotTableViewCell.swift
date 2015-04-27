//
//  ParkplatzTableViewCell.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 19/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class ParkinglotTableViewCell: MCSwipeTableViewCell {

	@IBOutlet weak var parkinglotNameLabel: UILabel!
	@IBOutlet weak var parkinglotAddressLabel: UILabel!
	@IBOutlet weak var parkinglotLoadLabel: UILabel!
	@IBOutlet weak var parkinglotTendencyLabel: UILabel!

	var parkinglot: Parkinglot?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
