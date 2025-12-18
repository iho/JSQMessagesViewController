import UIKit

extension UIColor {

    // MARK: - Message bubble colors

    /**
     *  - Returns: A color object containing HSB values similar to the iOS 7 messages app green bubble color.
     */
    @objc public static func jsq_messageBubbleGreen() -> UIColor {
        return UIColor(hue: 130.0 / 360.0, saturation: 0.68, brightness: 0.84, alpha: 1.0)
    }

    /**
     *  - Returns: A color object containing HSB values similar to the iOS 7 messages app blue bubble color.
     */
    @objc public static func jsq_messageBubbleBlue() -> UIColor {
        return UIColor(hue: 210.0 / 360.0, saturation: 0.94, brightness: 1.0, alpha: 1.0)
    }

    /**
     *  - Returns: A color object containing HSB values similar to the iOS 7 red color.
     */
    @objc public static func jsq_messageBubbleRed() -> UIColor {
        return UIColor(hue: 0.0, saturation: 0.79, brightness: 1.0, alpha: 1.0)
    }

    /**
     *  - Returns: A color object containing HSB values similar to the iOS 7 messages app light gray bubble color.
     */
    @objc public static func jsq_messageBubbleLightGray() -> UIColor {
        return UIColor(hue: 240.0 / 360.0, saturation: 0.02, brightness: 0.92, alpha: 1.0)
    }

    // MARK: - Utilities

    /**
     *  Creates and returns a new color object whose brightness component is decreased by the given value, using the initial color values of the receiver.
     *
     *  - parameter value: A floating point value describing the amount by which to decrease the brightness of the receiver.
     *
     *  - returns: A new color object whose brightness is decreased by the given values. The other color values remain the same as the receiver.
     */
    @objc public func jsq_colorByDarkeningColor(withValue value: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(
                red: max(red - value, 0.0),
                green: max(green - value, 0.0),
                blue: max(blue - value, 0.0),
                alpha: alpha)
        } else {
            // Handle cases where getRed fails (e.g. pattern colors), currently return self or a fallback
            return self
        }
    }
}
