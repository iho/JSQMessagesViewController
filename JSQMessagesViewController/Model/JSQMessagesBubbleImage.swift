import UIKit

/// A `JSQMessagesBubbleImage` model object represents a message bubble image, and is immutable.
/// This is a concrete class that implements the `JSQMessageBubbleImageDataSource` protocol.
/// It contains a regular message bubble image and a highlighted message bubble image.
///
/// - seealso: JSQMessagesBubbleImageFactory
public class JSQMessagesBubbleImage: NSObject, JSQMessageBubbleImageDataSource, NSCopying {

    /**
     *  Returns the message bubble image for a regular display state.
     */
    public let messageBubbleImage: UIImage

    /**
     *  Returns the message bubble image for a highlighted display state.
     */
    public let messageBubbleHighlightedImage: UIImage

    /**
     *  Initializes and returns a message bubble image object having the specified regular image and highlighted image.
     *
     *  - parameter image:            The regular message bubble image. This value must not be `nil`.
     *  - parameter highlightedImage: The highlighted message bubble image. This value must not be `nil`.
     *
     *  - returns: An initialized `JSQMessagesBubbleImage` object.
     */
    public init(messageBubbleImage image: UIImage, highlightedImage: UIImage) {
        self.messageBubbleImage = image
        self.messageBubbleHighlightedImage = highlightedImage
        super.init()
    }

    // MARK: - JSQMessageBubbleImageDataSource

    // Note: Implicitly implemented by properties above, but redundant definitions for Protocol witness might be needed if ObjC inference isn't perfect for properties-as-methods.
    // However, Swift properties expose getters that match the protocol requirement `func messageBubbleImage() -> UIImage`.
    // Actually, in Swift, `func foo()` requirements are satisfied by `var foo: Type` getters.
    // But  protocols might expect actual methods.
    // The ObjC protocol defined `- (UIImage *)messageBubbleImage;`
    // The Swift property `var messageBubbleImage: UIImage` generates `- (UIImage *)messageBubbleImage;` getter.
    // So this should work.

    // MARK: - NSObject

    public override var description: String {
        return
            "<\(String(describing: type(of: self))): messageBubbleImage=\(messageBubbleImage), messageBubbleHighlightedImage=\(messageBubbleHighlightedImage)>"
    }

    public func debugQuickLookObject() -> AnyObject? {
        return UIImageView(
            image: messageBubbleImage, highlightedImage: messageBubbleHighlightedImage)
    }

    // MARK: - NSCopying

    public func copy(with zone: NSZone? = nil) -> Any {
        return JSQMessagesBubbleImage(
            messageBubbleImage: UIImage(cgImage: messageBubbleImage.cgImage!),
            highlightedImage: UIImage(cgImage: messageBubbleHighlightedImage.cgImage!))
    }
}
