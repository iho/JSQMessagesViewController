import UIKit

/// `JSQMessagesBubbleImageFactory` is a factory that provides a means for creating and styling
/// `JSQMessagesBubbleImage` objects to be displayed in a `JSQMessagesCollectionViewCell` of a `JSQMessagesCollectionView`.
@objc public class JSQMessagesBubbleImageFactory: NSObject {

    private let bubbleImage: UIImage
    private let capInsets: UIEdgeInsets
    private let layoutDirection: UIUserInterfaceLayoutDirection

    private var isRightToLeftLanguage: Bool {
        return layoutDirection == .rightToLeft
    }

    /**
     *  Creates and returns a new instance of `JSQMessagesBubbleImageFactory` that uses the
     *  default bubble image assets, cap insets, and layout direction.
     *
     *  - returns: An initialized `JSQMessagesBubbleImageFactory` object.
     */
    @objc public override convenience init() {
        self.init(
            bubbleImage: UIImage.jsq_bubbleCompact() ?? UIImage(),
            capInsets: .zero,
            layoutDirection: UIApplication.shared.userInterfaceLayoutDirection)
    }

    /**
     *  Creates and returns a new instance of `JSQMessagesBubbleImageFactory` having the specified
     *  bubbleImage and capInsets. These values are used internally in the factory to produce
     *  `JSQMessagesBubbleImage` objects.
     *
     *  - parameter bubbleImage:     A template bubble image from which all images will be generated.
     *  The image should represent the *outgoing* message bubble image, which will be flipped
     *  horizontally for generating the corresponding *incoming* message bubble images. This value must not be `nil`.
     *
     *  - parameter capInsets:       The values to use for the cap insets that define the unstretchable regions of the image.
     *  Specify `UIEdgeInsetsZero` to have the factory create insets that allow the image to stretch from its center point.
     *
     *  - parameter layoutDirection: The layout direction to use.
     *
     *  - returns: An initialized `JSQMessagesBubbleImageFactory`.
     */
    @objc public init(
        bubbleImage: UIImage, capInsets: UIEdgeInsets,
        layoutDirection: UIUserInterfaceLayoutDirection
    ) {
        self.bubbleImage = bubbleImage
        self.layoutDirection = layoutDirection

        if capInsets == .zero {
            self.capInsets = JSQMessagesBubbleImageFactory.jsq_centerPointEdgeInsets(
                forImageSize: bubbleImage.size)
        } else {
            self.capInsets = capInsets
        }

        super.init()
    }

    /**
     *  Creates and returns a `JSQMessagesBubbleImage` object with the specified color for *outgoing* message image bubbles.
     *  The `messageBubbleImage` property of the `JSQMessagesBubbleImage` is configured with a flat bubble image, masked to the given color.
     *  The `messageBubbleHighlightedImage` property is configured similarly, but with a darkened version of the given color.
     *
     *  - parameter color: The color of the bubble image in the image view. This value must not be `nil`.
     *
     *  - returns: An initialized `JSQMessagesBubbleImage` object.
     */
    @objc public func outgoingMessagesBubbleImage(with color: UIColor) -> JSQMessagesBubbleImage {
        return self.jsq_messagesBubbleImage(
            with: color, flippedForIncoming: false != self.isRightToLeftLanguage)
    }

    /**
     *  Creates and returns a `JSQMessagesBubbleImage` object with the specified color for *incoming* message image bubbles.
     *  The `messageBubbleImage` property of the `JSQMessagesBubbleImage` is configured with a flat bubble image, masked to the given color.
     *  The `messageBubbleHighlightedImage` property is configured similarly, but with a darkened version of the given color.
     *
     *  - parameter color: The color of the bubble image in the image view. This value must not be `nil`.
     *
     *  - returns: An initialized `JSQMessagesBubbleImage` object.
     */
    @objc public func incomingMessagesBubbleImage(with color: UIColor) -> JSQMessagesBubbleImage {
        return self.jsq_messagesBubbleImage(
            with: color, flippedForIncoming: true != self.isRightToLeftLanguage)
    }

    // MARK: - Private

    private static func jsq_centerPointEdgeInsets(forImageSize bubbleImageSize: CGSize)
        -> UIEdgeInsets
    {
        let center = CGPoint(x: bubbleImageSize.width / 2.0, y: bubbleImageSize.height / 2.0)
        return UIEdgeInsets(top: center.y, left: center.x, bottom: center.y, right: center.x)
    }

    private func jsq_messagesBubbleImage(with color: UIColor, flippedForIncoming: Bool)
        -> JSQMessagesBubbleImage
    {
        var normalBubble = self.bubbleImage.jsq_imageMasked(with: color) ?? self.bubbleImage
        var highlightedBubble =
            self.bubbleImage.jsq_imageMasked(with: color.jsq_colorByDarkeningColor(withValue: 0.12))
            ?? self.bubbleImage

        if flippedForIncoming {
            normalBubble = self.jsq_horizontallyFlippedImage(from: normalBubble)
            highlightedBubble = self.jsq_horizontallyFlippedImage(from: highlightedBubble)
        }

        normalBubble = self.jsq_stretchableImage(from: normalBubble, withCapInsets: self.capInsets)
        highlightedBubble = self.jsq_stretchableImage(
            from: highlightedBubble, withCapInsets: self.capInsets)

        return JSQMessagesBubbleImage(
            messageBubbleImage: normalBubble, highlightedImage: highlightedBubble)
    }

    private func jsq_horizontallyFlippedImage(from image: UIImage) -> UIImage {
        return UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .upMirrored)
    }

    private func jsq_stretchableImage(from image: UIImage, withCapInsets capInsets: UIEdgeInsets)
        -> UIImage
    {
        return image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }
}
