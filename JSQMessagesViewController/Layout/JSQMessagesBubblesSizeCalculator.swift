import UIKit

/// An instance of `JSQMessagesBubblesSizeCalculator` is responsible for calculating
/// message bubble sizes for an instance of `JSQMessagesCollectionViewFlowLayout`.
@objc public class JSQMessagesBubblesSizeCalculator: NSObject, JSQMessagesBubbleSizeCalculating {

    /**
     *  The cache used to store layout information.
     */
    @objc public let cache: NSCache<AnyObject, AnyObject>

    /**
     *  The minimum width for any given message bubble.
     */
    @objc public let minimumBubbleWidth: UInt

    /**
     *  Specifies whether or not to use fixed-width bubbles.
     *  If `false` (the default), then bubbles will resize when rotating to landscape.
     */
    @objc public let usesFixedWidthBubbles: Bool

    @objc public let additionalInset: Int = 2

    @objc public var layoutWidthForFixedWidthBubbles: CGFloat = 0.0

    /**
     *  Initializes and returns a bubble size calculator with the given cache and minimumBubbleWidth.
     *
     *  - parameter cache:                 A cache object used to store layout information.
     *  - parameter minimumBubbleWidth:    The minimum width for any given message bubble.
     *  - parameter usesFixedWidthBubbles: Specifies whether or not to use fixed-width bubbles.
     *  If `false` (the default), then bubbles will resize when rotating to landscape.
     *
     *  - returns: An initialized `JSQMessagesBubblesSizeCalculator`.
     */
    @objc public init(
        cache: NSCache<AnyObject, AnyObject> = NSCache<AnyObject, AnyObject>(),
        minimumBubbleWidth: UInt = UInt(UIImage.jsq_bubbleCompact()?.size.width ?? 40.0),
        usesFixedWidthBubbles: Bool = false
    ) {
        self.cache = cache
        self.minimumBubbleWidth = minimumBubbleWidth
        self.usesFixedWidthBubbles = usesFixedWidthBubbles

        if self.cache.name.isEmpty {
            self.cache.name = "JSQMessagesBubblesSizeCalculator.cache"
        }
        self.cache.countLimit = 200
        super.init()
    }

    // MARK: - JSQMessagesBubbleSizeCalculating

    @objc public func prepareForResettingLayout(_ layout: JSQMessagesCollectionViewFlowLayout) {
        self.cache.removeAllObjects()
    }

    @objc public func messageBubbleSize(
        for messageData: JSQMessageData, at indexPath: IndexPath,
        with layout: JSQMessagesCollectionViewFlowLayout
    ) -> CGSize {
        if let cachedSize = self.cache.object(forKey: NSNumber(value: messageData.messageHash))
            as? NSValue
        {
            return cachedSize.cgSizeValue
        }

        var finalSize = CGSize.zero

        if messageData.isMediaMessage {
            finalSize = (messageData.media as? JSQMessageMediaData)?.mediaViewDisplaySize() ?? .zero
        } else {
            let avatarSize = self.jsq_avatarSize(for: messageData, with: layout)

            // from the cell xibs, there is a 2 point space between avatar and bubble
            let spacingBetweenAvatarAndBubble: CGFloat = 2.0
            let horizontalContainerInsets =
                layout.messageBubbleTextViewTextContainerInsets.left
                + layout.messageBubbleTextViewTextContainerInsets.right
            let horizontalFrameInsets =
                layout.messageBubbleTextViewFrameInsets.left
                + layout.messageBubbleTextViewFrameInsets.right

            let horizontalInsetsTotal =
                horizontalContainerInsets + horizontalFrameInsets + spacingBetweenAvatarAndBubble
            let maximumTextWidth =
                self.textBubbleWidth(for: layout) - avatarSize.width
                - layout.messageBubbleLeftRightMargin - horizontalInsetsTotal

            let text = (messageData.text as? String) ?? ""
            let attributes: [NSAttributedString.Key: Any] = [.font: layout.messageBubbleFont]

            let stringRect = text.boundingRect(
                with: CGSize(width: maximumTextWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil as NSStringDrawingContext?)

            let stringSize = stringRect.integral.size

            let verticalContainerInsets =
                layout.messageBubbleTextViewTextContainerInsets.top
                + layout.messageBubbleTextViewTextContainerInsets.bottom
            let verticalFrameInsets =
                layout.messageBubbleTextViewFrameInsets.top
                + layout.messageBubbleTextViewFrameInsets.bottom

            let verticalInsets =
                verticalContainerInsets + verticalFrameInsets + CGFloat(self.additionalInset)

            let finalWidth =
                max(stringSize.width + horizontalInsetsTotal, CGFloat(self.minimumBubbleWidth))
                + CGFloat(self.additionalInset)

            finalSize = CGSize(width: finalWidth, height: stringSize.height + verticalInsets)
        }

        self.cache.setObject(
            NSValue(cgSize: finalSize), forKey: NSNumber(value: messageData.messageHash))

        return finalSize
    }

    @objc private func jsq_avatarSize(
        for messageData: JSQMessageData, with layout: JSQMessagesCollectionViewFlowLayout
    ) -> CGSize {
        let messageSender = messageData.senderId

        let dataSource = layout.collectionView?.dataSource as? JSQMessagesCollectionViewDataSource
        if messageSender == dataSource?.senderId {
            return layout.outgoingAvatarViewSize
        }

        return layout.incomingAvatarViewSize
    }

    @objc private func textBubbleWidth(for layout: JSQMessagesCollectionViewFlowLayout) -> CGFloat {
        if self.usesFixedWidthBubbles {
            return self.widthForFixedWidthBubbles(with: layout)
        }

        return layout.itemWidth
    }

    @objc private func widthForFixedWidthBubbles(with layout: JSQMessagesCollectionViewFlowLayout)
        -> CGFloat
    {
        if self.layoutWidthForFixedWidthBubbles > 0.0 {
            return self.layoutWidthForFixedWidthBubbles
        }

        let horizontalInsets =
            layout.sectionInset.left + layout.sectionInset.right + CGFloat(self.additionalInset)
        let width = layout.collectionView?.bounds.width ?? 0.0 - horizontalInsets
        let height = layout.collectionView?.bounds.height ?? 0.0 - horizontalInsets

        self.layoutWidthForFixedWidthBubbles = min(width, height)

        return self.layoutWidthForFixedWidthBubbles
    }
}
