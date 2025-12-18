import UIKit

/// The `JSQMessageBubbleImageDataSource` protocol defines the common interface through which
/// a `JSQMessagesViewController` and `JSQMessagesCollectionView` interact with
/// message bubble image model objects.
///
/// It declares the required and optional methods that a class must implement so that instances
/// of that class can be display properly within a `JSQMessagesCollectionViewCell`.
///
/// A concrete class that conforms to this protocol is provided in the library. See `JSQMessagesBubbleImage`.
///
/// - seealso: JSQMessagesBubbleImage
@objc public protocol JSQMessageBubbleImageDataSource: NSObjectProtocol {

    /**
     *  - Returns: The message bubble image for a regular display state.
     *
     *  - Warning: You must not return `nil` from this method.
     */
    var messageBubbleImage: UIImage { get }

    /**
     *  - Returns: The message bubble image for a highlighted display state.
     *
     *  - Warning: You must not return `nil` from this method.
     */
    var messageBubbleHighlightedImage: UIImage { get }
}
