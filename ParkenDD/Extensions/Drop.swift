//
//  Drop.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 25/10/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import SwiftyDrop

func drop(_ message: String, state: DropState) {
	DispatchQueue.main.async { () -> Void in
		Drop.down(message, state: state)
	}
}
