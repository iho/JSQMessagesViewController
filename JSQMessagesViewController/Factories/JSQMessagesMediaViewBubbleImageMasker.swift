import UIKit

/// An instance of `JSQMessagesMediaViewBubbleImageMasker` is an object that masks
/// media views for a `JSQMessageMediaData` object. Given a view, it will mask the view
/// with a bubble image for an outgoing or incoming media view.
///
/// - seealso: JSQMessageMediaData
/// - seealso: JSQMessagesBubbleImageFactory
/// - seealso: JSQMessagesBubbleImage
@objc public class JSQMessagesMediaViewBubbleImageMasker: NSObject {

    /**
     *  Returns the bubble image factory that the masker uses to mask media views.
     */
    public let bubbleImageFactory: JSQMessagesBubbleImageFactory

    /**
     *  Creates and returns a new instance of `JSQMessagesMediaViewBubbleImageMasker`
     *  that uses a default instance of `JSQMessagesBubbleImageFactory`. The masker uses the `JSQMessagesBubbleImage`
     *  objects returned by the factory to mask media views.
     *
     *  - returns: An initialized `JSQMessagesMediaViewBubbleImageMasker` object.
     */
    @objc public override convenience init() {
        self.init(bubbleImageFactory: JSQMessagesBubbleImageFactory())
    }

    /**
     *  Creates and returns a new instance of `JSQMessagesMediaViewBubbleImageMasker`
     *  having the specified bubbleImageFactory. The masker uses the `JSQMessagesBubbleImage`
     *  objects returned by the factory to mask media views.
     *
     *  - parameter bubbleImageFactory: An initialized `JSQMessagesBubbleImageFactory` object to use for masking media views. This value must not be `nil`.
     *
     *  - returns: An initialized `JSQMessagesMediaViewBubbleImageMasker` object.
     */
    @objc public init(bubbleImageFactory: JSQMessagesBubbleImageFactory) {
        self.bubbleImageFactory = bubbleImageFactory
        super.init()
    }

    /**
     *  Applies an outgoing bubble image mask to the specified mediaView.
     *
     *  - parameter mediaView: The media view to mask.
     */
    @objc public func applyOutgoingBubbleImageMask(toMediaView mediaView: UIView) {
        let bubbleImageData = self.bubbleImageFactory.outgoingMessagesBubbleImage(
            with: UIColor.white)
        self.jsq_mask(view: mediaView, with: bubbleImageData.messageBubbleImage)
    }

    /**
     *  Applies an incoming bubble image mask to the specified mediaView.
     *
     *  - parameter mediaView: The media view to mask.
     */
    @objc public func applyIncomingBubbleImageMask(toMediaView mediaView: UIView) {
        let bubbleImageData = self.bubbleImageFactory.incomingMessagesBubbleImage(
            with: UIColor.white)
        self.jsq_mask(view: mediaView, with: bubbleImageData.messageBubbleImage)
    }

    /**
     *  A convenience method for applying a bubble image mask to the specified mediaView.
     *  This method uses the default instance of `JSQMessagesBubbleImageFactory`.
     *
     *  - parameter mediaView:  The media view to mask.
     *  - parameter isOutgoing: A boolean value specifiying whether or not the mask should be for an outgoing or incoming view.
     *  Specify `YES` for outgoing and `NO` for incoming.
     */
    @objc public static func applyBubbleImageMask(toMediaView mediaView: UIView, isOutgoing: Bool) {
        let masker = JSQMessagesMediaViewBubbleImageMasker()
        if isOutgoing {
            masker.applyOutgoingBubbleImageMask(toMediaView: mediaView)
        } else {
            masker.applyIncomingBubbleImageMask(toMediaView: mediaView)
        }
    }

    // MARK: - Private

    private func jsq_mask(view: UIView, with image: UIImage) {
        let imageViewMask = UIImageView(image: image)
        imageViewMask.frame = view.frame.insetBy(dx: 2.0, dy: 2.0)
        view.layer.mask = imageViewMask.layer
    }
}
