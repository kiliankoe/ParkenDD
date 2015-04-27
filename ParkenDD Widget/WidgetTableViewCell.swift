//
//  WidgetTableViewCell.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 27/04/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class WidgetTableViewCell: UITableViewCell {

	@IBOutlet weak var lotNameLabel: UILabel!
	@IBOutlet weak var lotFreeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
