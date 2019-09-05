import UIKit

final class LotGauge: UIView {
    var percentage: Double = 0.0 {
        didSet {
            DispatchQueue.main.async {
                self.draw(self.frame)
                self.setNeedsDisplay()
            }
        }
    }

    static var percentageFormatter: NumberFormatter = {
        let nF = NumberFormatter()
        nF.numberStyle = .percent
        return nF
    }()

    override func draw(_ rect: CGRect) {
        let angle = CGFloat(percentage * 360)
        let color = UIColor.colorBasedOn(percentage: self.percentage)
        let percentageNumber = NSNumber(value: self.percentage)
        let text = LotGauge.percentageFormatter.string(from: percentageNumber)!
        StyleKit.drawLotGauge(resizing: .aspectFit, angle: angle, color: color, text: text)
    }
}
