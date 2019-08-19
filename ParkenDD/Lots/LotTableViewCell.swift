import UIKit
import struct ParkKit.Lot

class LotTableViewCell: UITableViewCell {

    var lot: Lot? {
        didSet {
            self.nameLabel.text = lot?.name
            self.freeLabel.text = "\(lot?.free ?? 0)"
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var freeLabel: UILabel!
}
