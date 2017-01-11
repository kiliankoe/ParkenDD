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
    var parkingLots = [Lot]()
    var defaultSortedLots = [Lot]()

    func set(lots: [Lot]) {
        defaultSortedLots = lots
        parkingLots = UserDefaults.bool(for: .skipNodataLots) ? lots.filter { $0.state != .nodata } : lots
    }

    func sortLots() {
        let sortingType = UserDefaults.string(for: .sortingType) ?? ""
        switch sortingType {
        case Sorting.distance:
            break
        case Sorting.alphabetical:
            parkingLots.sort { $0.name < $1.name }
        case Sorting.free:
            parkingLots.sort { $0.freeRegardingClosed > $1.freeRegardingClosed }
        case Sorting.euclid:
            break
        default:
            parkingLots = defaultSortedLots
        }
    }

//    func sortLots() {
//        guard let sortingType = UserDefaults.standard.string(forKey: Defaults.sortingType) else { return }
//        switch sortingType {
//        case Sorting.distance:
//            parkinglots.sort {
//                if let currentUserLocation = locationManager.location,
//                    let dist1 = $0.distance(from: currentUserLocation),
//                    let dist2 = $1.distance(from: currentUserLocation) {
//                    return dist1 < dist2
//                }
//                return $0.name < $1.name
//            }
//        case Sorting.alphabetical:
//            parkinglots.sort { $0.name < $1.name }
//        case Sorting.free:
//            parkinglots.sort { $0.freeRegardingClosed > $1.freeRegardingClosed }
//        case Sorting.euclid:
//            self.parkinglots.sort {
//                guard let currentUserLocation = locationManager.location else { return $0.free > $1.free }
//                // TODO: Also check if state is either open or unknown, others should not be sorted
//                if $0.total != 0 && $1.total != 0 {
//                    let occ1 = Double($0.total - $0.free) / Double($0.total)
//                    let occ2 = Double($1.total - $1.free) / Double($1.total)
//
//                    // This factor gives a penalty for very crowded parking spaces
//                    // so they are ranked down the list, even if they are very close
//                    let smoothingfactor1 = 1.0 / Double(2.0*(1.0-occ1))
//                    let smoothingfactor2 = 1.0 / Double(2.0*(1.0-occ2))
//
//                    let sqrt1 = sqrt(pow($0.distance(from: currentUserLocation) ?? 0, 2.0) + smoothingfactor1 * pow(Double(occ1*1000), 2.0))
//                    let sqrt2 = sqrt(pow($1.distance(from: currentUserLocation) ?? 0, 2.0) + smoothingfactor2 * pow(Double(occ2*1000), 2.0))
//
//                    return sqrt1 < sqrt2
//                }
//                return $0.free > $1.free
//            }
//        default:
//            parkinglots = defaultSortedParkinglots
//        }
//    }

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
