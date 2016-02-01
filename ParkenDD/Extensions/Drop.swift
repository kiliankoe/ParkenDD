//
//  Drop.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 25/10/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import SwiftyDrop

func drop(message: String, state: DropState) {
	dispatch_async(dispatch_get_main_queue()) { () -> Void in
		Drop.down(message, state: state)
	}
}
