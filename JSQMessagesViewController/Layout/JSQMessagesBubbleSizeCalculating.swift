import UIKit

/// The `JSQMessagesBubbleSizeCalculating` protocol defines the common interface through which
/// an object provides layout information to an instance of `JSQMessagesCollectionViewFlowLayout`.
///
/// A concrete class that conforms to this protocol is provided in the library.
/// See `JSQMessagesBubbleSizeCalculator`.
public protocol JSQMessagesBubbleSizeCalculating: NSObjectProtocol {

    /**
     *  Computes and returns the size of the `messageBubbleImageView` property
     *  of a `JSQMessagesCollectionViewCell` for the specified messageData at indexPath.
     *
     *  - parameter messageData: A message data object.
     *  - parameter indexPath:   The index path at which messageData is located.
     *  - parameter layout:      The layout object asking for this information.
     *
     *  - returns: A sizes that specifies the required dimensions to display the entire message contents.
     *  Note, this is *not* the entire cell, but only its message bubble.
     */
    func messageBubbleSize(
        for messageData: JSQMessageData, at indexPath: IndexPath,
        with layout: JSQMessagesCollectionViewFlowLayout
    ) -> CGSize

    /**
     *  Notifies the receiver that the layout will be reset.
     *  Use this method to clear any cached layout information, if necessary.
     *
     *  - parameter layout: The layout object notifying the receiver.
     */
    func prepareForResettingLayout(_ layout: JSQMessagesCollectionViewFlowLayout)
}
