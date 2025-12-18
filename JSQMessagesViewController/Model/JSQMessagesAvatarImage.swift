import UIKit

/// A `JSQMessagesAvatarImage` model object represents an avatar image.
/// This is a concrete class that implements the `JSQMessageAvatarImageDataSource` protocol.
/// It contains a regular avatar image, a highlighted avatar image, and a placeholder avatar image.
///
/// - seealso: JSQMessagesAvatarImageFactory
@objc public class JSQMessagesAvatarImage: NSObject, JSQMessageAvatarImageDataSource, NSCopying {

    /**
     *  The avatar image for a regular display state.
     */
    public var avatarImage: UIImage?

    /**
     *  The avatar image for a highlighted display state.
     */
    public var avatarHighlightedImage: UIImage?

    /**
     *  Returns the placeholder image for an avatar to display if avatarImage is `nil`.
     */
    public var avatarPlaceholderImage: UIImage

    /**
     *  Initializes and returns an avatar image object having the specified image.
     *
     *  - parameter image: The image for this avatar image. This image will be used for the all of the following
     *  properties: avatarImage, avatarHighlightedImage, avatarPlaceholderImage;
     *  This value must not be `nil`.
     *
     *  - returns: An initialized `JSQMessagesAvatarImage` object.
     */
    @objc public static func avatar(with image: UIImage) -> JSQMessagesAvatarImage {
        return JSQMessagesAvatarImage(
            avatarImage: image, highlightedImage: image, placeholderImage: image)
    }

    /**
     *  Initializes and returns an avatar image object having the specified placeholder image.
     *
     *  - parameter placeholderImage: The placeholder image for this avatar image. This value must not be `nil`.
     *
     *  - returns: An initialized `JSQMessagesAvatarImage` object.
     */
    @objc public static func avatarImage(withPlaceholder placeholderImage: UIImage)
        -> JSQMessagesAvatarImage
    {
        return JSQMessagesAvatarImage(
            avatarImage: nil, highlightedImage: nil, placeholderImage: placeholderImage)
    }

    /**
     *  Initializes and returns an avatar image object having the specified regular, highlighed, and placeholder images.
     *
     *  - parameter avatarImage:      The avatar image for a regular display state.
     *  - parameter highlightedImage: The avatar image for a highlighted display state.
     *  - parameter placeholderImage: The placeholder image for this avatar image. This value must not be `nil`.
     *
     *  - returns: An initialized `JSQMessagesAvatarImage` object.
     */
    @objc public init(avatarImage: UIImage?, highlightedImage: UIImage?, placeholderImage: UIImage)
    {
        self.avatarImage = avatarImage
        self.avatarHighlightedImage = highlightedImage
        self.avatarPlaceholderImage = placeholderImage
        super.init()
    }

    // MARK: - JSQMessageAvatarImageDataSource

    // MARK: - NSObject

    public override var description: String {
        return
            "<\(String(describing: type(of: self))): avatarImage=\(String(describing: avatarImage)), avatarHighlightedImage=\(String(describing: avatarHighlightedImage)), avatarPlaceholderImage=\(avatarPlaceholderImage)>"
    }

    public func debugQuickLookObject() -> AnyObject? {
        return UIImageView(image: avatarImage ?? avatarPlaceholderImage)
    }

    // MARK: - NSCopying

    public func copy(with zone: NSZone? = nil) -> Any {
        let copyAvatar = avatarImage != nil ? UIImage(cgImage: avatarImage!.cgImage!) : nil
        let copyHighlighted =
            avatarHighlightedImage != nil ? UIImage(cgImage: avatarHighlightedImage!.cgImage!) : nil
        let copyPlaceholder = UIImage(cgImage: avatarPlaceholderImage.cgImage!)

        return JSQMessagesAvatarImage(
            avatarImage: copyAvatar,
            highlightedImage: copyHighlighted,
            placeholderImage: copyPlaceholder)
    }
}
