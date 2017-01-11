//
//  LotlistDataSource.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 11/01/2017.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import ParkKit

class LotlistDataSource: NSObject, UITableViewDataSource {
    var parkingLots = [Lot]() {
        didSet {
            if UserDefaults.bool(for: .skipNodataLots) {
                // Not sure if it's better to remove them here or filter them in the datasource delegate methods below...
                // The problem is that I'm unsure how to not return a cell for those lots in the list I then want to skip.
                parkingLots = parkingLots.filter { $0.state != .nodata }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingLots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Don't display separators if the list is still empty.
        tableView.separatorStyle = parkingLots.count > 0 ? .singleLine : .none

        let cell = (tableView.dequeueReusableCell(withIdentifier: String(describing: LotCell.self)) as? LotCell) ?? LotCell()

        cell.setParkinglot(parkingLots[indexPath.row])

        return cell
    }
}
