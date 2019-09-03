import UIKit

extension UIColor {
    static func colorBasedOn(percentage: Double) -> UIColor {
        let hue = 1 - (percentage * 0.3 + 0.7)
        return UIColor(hue: CGFloat(hue), saturation: 0.54, brightness: 0.8, alpha: 1.0)
    }
}
