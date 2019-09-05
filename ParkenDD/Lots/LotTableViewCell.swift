import UIKit
import struct ParkKit.Lot

class LotTableViewCell: UITableViewCell {

    static var distanceFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.roundingMode = .halfUp
        return nf
    }()

    var lot: Lot? {
        didSet {
            guard let lot = lot else { return }
            self.nameLabel.text = lot.name
            self.freeLabel.text = L10n.Lots.Cell.freeLabel(lot.free, lot.total)

            let randomDistance = Int.random(in: 0...5)
            self.infoLabel.text = "\(randomDistance)km"

            self.lotGauge.percentage = lot.loadPercentage
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var freeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var lotGauge: LotGauge!
}
