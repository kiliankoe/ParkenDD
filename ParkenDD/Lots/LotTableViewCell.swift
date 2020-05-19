import UIKit
import struct ParkKit.Lot

class LotTableViewCell: UITableViewCell {

    static var distanceFormatter: MeasurementFormatter = {
        let f = MeasurementFormatter()
        f.unitOptions = .providedUnit
        f.unitStyle = .short
        f.locale = .current
        return f
    }()

    var lot: Lot? {
        didSet {
            guard let lot = lot else { return }
            self.nameLabel.text = lot.name
            self.freeLabel.text = L10n.Lots.Cell.freeLabel(lot.free, lot.total)

            let randomDistance = Int.random(in: 0...5)
            let distanceMeasurement = Measurement(value: Double(randomDistance), unit: UnitLength.kilometers)
            self.infoLabel.text = LotTableViewCell.distanceFormatter.string(from: distanceMeasurement)

            self.lotGauge.percentage = lot.loadPercentage
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var freeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var lotGauge: LotGauge!
}
