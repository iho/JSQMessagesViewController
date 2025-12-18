import UIKit

extension UIImage {

    /**
     *  Creates and returns a new image object that is masked with the specified mask color.
     *
     *  - parameter maskColor: The color value for the mask. This value must not be `nil`.
     *
     *  - returns: A new image object masked with the specified color.
     */
    public func jsq_imageMasked(with color: UIColor) -> UIImage? {
        let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)

        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }

        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -imageRect.size.height)

        context.clip(to: imageRect, mask: cgImage)
        context.setFillColor(color.cgColor)
        context.fill(imageRect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    private static func jsq_bubbleImage(fromBundleWithName name: String) -> UIImage? {
        let bundle = Bundle.jsq_messagesAsset()
        guard let path = bundle?.path(forResource: name, ofType: "png", inDirectory: "Images")
        else { return nil }
        return UIImage(contentsOfFile: path)
    }

    /**
     *  - Returns: The regular message bubble image.
     */
    public static func jsq_bubbleRegular() -> UIImage? {
        return UIImage.jsq_bubbleImage(fromBundleWithName: "bubble_regular")
    }

    /**
     *  - Returns: The regular message bubble image without a tail.
     */
    public static func jsq_bubbleRegularTailless() -> UIImage? {
        return UIImage.jsq_bubbleImage(fromBundleWithName: "bubble_tailless")
    }

    /**
     *  - Returns: The regular message bubble image stroked, not filled.
     */
    public static func jsq_bubbleRegularStroked() -> UIImage? {
        return UIImage.jsq_bubbleImage(fromBundleWithName: "bubble_stroked")
    }

    /**
     *  - Returns: The regular message bubble image stroked, not filled and without a tail.
     */
    public static func jsq_bubbleRegularStrokedTailless() -> UIImage? {
        return UIImage.jsq_bubbleImage(fromBundleWithName: "bubble_stroked_tailless")
    }

    /**
     *  - Returns: The compact message bubble image.
     *
     *  - Discussion: This is the default bubble image used by `JSQMessagesBubbleImageFactory`.
     */
    public static func jsq_bubbleCompact() -> UIImage? {
        return UIImage.jsq_bubbleImage(fromBundleWithName: "bubble_min")
    }

    /**
     *  - Returns: The compact message bubble image without a tail.
     */
    public static func jsq_bubbleCompactTailless() -> UIImage? {
        return UIImage.jsq_bubbleImage(fromBundleWithName: "bubble_min_tailless")
    }

    /**
     *  - Returns: The default input toolbar accessory image.
     */
    public static func jsq_defaultAccessory() -> UIImage? {
        return UIImage.jsq_bubbleImage(fromBundleWithName: "clip")
    }

    /**
     *  - Returns: The default typing indicator image.
     */
    public static func jsq_defaultTypingIndicator() -> UIImage? {
        return UIImage.jsq_bubbleImage(fromBundleWithName: "typing")
    }

    /**
     *  - Returns: The default play icon image.
     */
    public static func jsq_defaultPlay() -> UIImage? {
        return UIImage.jsq_bubbleImage(fromBundleWithName: "play")
    }

    /**
     *  - Returns: The default pause icon image.
     */
    public static func jsq_defaultPause() -> UIImage? {
        return UIImage.jsq_bubbleImage(fromBundleWithName: "pause")
    }

    /**
     *  - Returns: The standard share icon image.
     *
     *  - Discussion: This is the default icon for the message accessory button.
     */
    public static func jsq_shareAction() -> UIImage? {
        return UIImage.jsq_bubbleImage(fromBundleWithName: "share")
    }
}
