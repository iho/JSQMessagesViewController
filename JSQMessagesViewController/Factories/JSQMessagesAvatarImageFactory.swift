import UIKit

/// `JSQMessagesAvatarImageFactory` is a factory that provides a means for creating and styling
/// `JSQMessagesAvatarImage` objects to be displayed in a `JSQMessagesCollectionViewCell` of a `JSQMessagesCollectionView`.
@objc public class JSQMessagesAvatarImageFactory: NSObject {

    private let diameter: UInt

    /**
     *  Creates and returns a new instance of `JSQMessagesAvatarImageFactory` that uses
     *  the default diameter for creating avatars.
     *
     *  - returns: An initialized `JSQMessagesAvatarImageFactory` object.
     */
    @objc public override convenience init() {
        // TODO: define kJSQMessagesCollectionViewAvatarSizeDefault elsewhere so we can remove this dependency
        // Assuming 30.0f is default or we need to access the constant which is in JSQMessagesCollectionViewFlowLayout.h (ObjC)
        // Since we are rewriting, we can hardcode or lookup.
        // Let's assume 30 for now or fetch from layout if available.
        // kJSQMessagesCollectionViewAvatarSizeDefault is indeed in JSQMessagesCollectionViewFlowLayout.h
        self.init(diameter: 30)
    }

    /**
     *  Creates and returns a new instance of `JSQMessagesAvatarImageFactory` that uses
     *  the specified diameter for creating avatars.
     *
     *  - parameter diameter: An integer value specifying the diameter size of the image in points. This value must be greater than `0`.
     *
     *  - returns: An initialized `JSQMessagesAvatarImageFactory` object.
     */
    @objc public init(diameter: UInt) {
        self.diameter = diameter
        super.init()
    }

    /**
    *  Creates and returns a `JSQMessagesAvatarImage` object with the specified placeholderImage that is
    *  cropped to a circle of the given diameter.
    *
    *  - parameter placeholderImage: An image object that represents a placeholder avatar image. This value must not be `nil`.
    *
    *  - returns: An initialized `JSQMessagesAvatarImage` object.
    */
    @objc public func avatarImage(withPlaceholder placeholderImage: UIImage)
        -> JSQMessagesAvatarImage
    {
        let circlePlaceholderImage = self.jsq_circularImage(
            placeholderImage, withHighlightedColor: nil)
        return JSQMessagesAvatarImage.avatarImage(withPlaceholder: circlePlaceholderImage!)
    }

    /**
     *  Creates and returns a `JSQMessagesAvatarImage` object with the specified image that is
     *  cropped to a circle of the given diameter and used for the `avatarImage` and `avatarPlaceholderImage` properties
     *  of the returned `JSQMessagesAvatarImage` object. This image is then copied and has a transparent black mask applied to it,
     *  which is used for the `avatarHighlightedImage` property of the returned `JSQMessagesAvatarImage` object.
     *
     *  - parameter image:    An image object that represents an avatar image. This value must not be `nil`.
     *
     *  - returns: An initialized `JSQMessagesAvatarImage` object.
     */
    @objc public func avatarImage(with image: UIImage) -> JSQMessagesAvatarImage {
        let avatar = self.circularAvatarImage(image)
        let highlightedAvatar = self.circularAvatarHighlightedImage(image)

        return JSQMessagesAvatarImage(
            avatarImage: avatar, highlightedImage: highlightedAvatar, placeholderImage: avatar!)
    }

    /**
     *  Returns a copy of the specified image that is cropped to a circle with the given diameter.
     *
     *  - parameter image:    The image to crop. This value must not be `nil`.
     *
     *  - returns: A new image object.
     */
    @objc public func circularAvatarImage(_ image: UIImage) -> UIImage? {
        return self.jsq_circularImage(image, withHighlightedColor: nil)
    }

    /**
     *  Returns a copy of the specified image that is cropped to a circle with the given diameter.
     *  Additionally, a transparent overlay is applied to the image to represent a pressed or highlighted state.
     *
     *  - parameter image:    The image to crop. This value must not be `nil`.
     *
     *  - returns: A new image object.
     */
    @objc public func circularAvatarHighlightedImage(_ image: UIImage) -> UIImage? {
        return self.jsq_circularImage(image, withHighlightedColor: UIColor(white: 0.1, alpha: 0.3))
    }

    /**
     *  Creates and returns a `JSQMessagesAvatarImage` object with a circular shape that displays the specified userInitials
     *  with the given backgroundColor, textColor, font, and diameter.
     *
     *  - parameter userInitials:    The user initials to display in the avatar image. This value must not be `nil`.
     *  - parameter backgroundColor: The background color of the avatar. This value must not be `nil`.
     *  - parameter textColor:       The color of the text of the userInitials. This value must not be `nil`.
     *  - parameter font:            The font applied to userInitials. This value must not be `nil`.
     *
     *  - returns: An initialized `JSQMessagesAvatarImage` object.
     */
    @objc public func avatarImage(
        withUserInitials userInitials: String, backgroundColor: UIColor, textColor: UIColor,
        font: UIFont
    ) -> JSQMessagesAvatarImage {
        let avatarImage = self.jsq_image(
            withInitials: userInitials, backgroundColor: backgroundColor, textColor: textColor,
            font: font)
        let avatarHighlightedImage = self.jsq_circularImage(
            avatarImage!, withHighlightedColor: UIColor(white: 0.1, alpha: 0.3))

        return JSQMessagesAvatarImage(
            avatarImage: avatarImage, highlightedImage: avatarHighlightedImage,
            placeholderImage: avatarImage!)
    }

    // MARK: - Private

    private func jsq_image(
        withInitials initials: String, backgroundColor: UIColor, textColor: UIColor, font: UIFont
    ) -> UIImage? {
        let frame = CGRect(
            x: 0.0, y: 0.0, width: Double(self.diameter), height: Double(self.diameter))
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: textColor]

        // This is a rough port of NSString drawing. Swift strings are bridging to NSString forboundingRect.
        let textFrame = (initials as NSString).boundingRect(
            with: frame.size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil)

        let frameMidPoint = CGPoint(x: frame.midX, y: frame.midY)
        let textFrameMidPoint = CGPoint(x: textFrame.midX, y: textFrame.midY)

        let dx = frameMidPoint.x - textFrameMidPoint.x
        let dy = frameMidPoint.y - textFrameMidPoint.y
        let drawPoint = CGPoint(x: dx, y: dy)

        var image: UIImage? = nil

        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(backgroundColor.cgColor)
            context.fill(frame)
            (initials as NSString).draw(at: drawPoint, withAttributes: attributes)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()

        // Circular clip
        return self.jsq_circularImage(image!, withHighlightedColor: nil)
    }

    private func jsq_circularImage(
        _ image: UIImage, withHighlightedColor highlightedColor: UIColor?
    ) -> UIImage? {
        let frame = CGRect(
            x: 0.0, y: 0.0, width: Double(self.diameter), height: Double(self.diameter))
        var newImage: UIImage? = nil

        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            let imgPath = UIBezierPath(ovalIn: frame)
            imgPath.addClip()
            image.draw(in: frame)

            if let highlightedColor = highlightedColor {
                context.setFillColor(highlightedColor.cgColor)
                context.fillEllipse(in: frame)
            }

            newImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()

        return newImage
    }
}
