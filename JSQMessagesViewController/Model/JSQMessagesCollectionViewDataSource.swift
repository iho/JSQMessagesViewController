import UIKit

/// An object that adopts the `JSQMessagesCollectionViewDataSource` protocol is responsible for providing the data and views
/// required by a `JSQMessagesCollectionView`. The data source object represents your app’s messaging data model
/// and vends information to the collection view as needed.
@objc public protocol JSQMessagesCollectionViewDataSource: UICollectionViewDataSource {

    /**
     *  Asks the data source for the current sender's display name, that is, the current user who is sending messages.
     *
     *  - returns: An initialized string describing the current sender to display in a `JSQMessagesCollectionViewCell`.
     *
     *  - Warning: You must not return `nil` from this method. This value does not need to be unique.
     */
    /**
     *  Asks the data source for the current sender's display name, that is, the current user who is sending messages.
     *
     *  - returns: An initialized string describing the current sender to display in a `JSQMessagesCollectionViewCell`.
     *
     *  - Warning: You must not return `nil` from this method. This value does not need to be unique.
     */
    var senderDisplayName: String { get }

    /**
     *  Asks the data source for the current sender's unique identifier, that is, the current user who is sending messages.
     *
     *  - returns: An initialized string identifier that uniquely identifies the current sender.
     *
     *  - Warning: You must not return `nil` from this method. This value must be unique.
     */
    var senderId: String { get }

    /**
     *  Asks the data source for the message data that corresponds to the specified item at indexPath in the collectionView.
     *
     *  - parameter collectionView: The collection view requesting this information.
     *  - parameter indexPath:      The index path that specifies the location of the item.
     *
     *  - returns: An initialized object that conforms to the `JSQMessageData` protocol. You must not return `nil` from this method.
     */
    func collectionView(
        _ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath
    ) -> any JSQMessageData

    /**
     *  Notifies the data source that the item at indexPath has been deleted.
     *  Implementations of this method should remove the item from the data source.
     *
     *  - parameter collectionView: The collection view requesting this information.
     *  - parameter indexPath:      The index path that specifies the location of the item.
     */
    func collectionView(
        _ collectionView: JSQMessagesCollectionView, didDeleteMessageAt indexPath: IndexPath)

    /**
     *  Asks the data source for the message bubble image data that corresponds to the specified message data item at indexPath in the collectionView.
     *
     *  - parameter collectionView: The collection view requesting this information.
     *  - parameter indexPath:      The index path that specifies the location of the item.
     *
     *  - returns: An initialized object that conforms to the `JSQMessageBubbleImageDataSource` protocol. You may return `nil` from this method if you do not
     *  want the specified item to display a message bubble image.
     *
     *  - Discussion: It is recommended that you utilize `JSQMessagesBubbleImageFactory` to return valid `JSQMessagesBubbleImage` objects.
     *  However, you may provide your own data source object as long as it conforms to the `JSQMessageBubbleImageDataSource` protocol.
     */
    func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        messageBubbleImageDataForItemAt indexPath: IndexPath
    ) -> (any JSQMessageBubbleImageDataSource)?

    /**
     *  Asks the data source for the avatar image data that corresponds to the specified message data item at indexPath in the collectionView.
     *
     *  - parameter collectionView: The collection view requesting this information.
     *  - parameter indexPath:      The index path that specifies the location of the item.
     *
     *  - returns: A initialized object that conforms to the `JSQMessageAvatarImageDataSource` protocol. You may return `nil` from this method if you do not want
     *  the specified item to display an avatar.
     *
     *  - Discussion: It is recommended that you utilize `JSQMessagesAvatarImageFactory` to return valid `JSQMessagesAvatarImage` objects.
     *  However, you may provide your own data source object as long as it conforms to the `JSQMessageAvatarImageDataSource` protocol.
     */
    func collectionView(
        _ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath
    ) -> (any JSQMessageAvatarImageDataSource)?

    // MARK: - Optional

    /**
     *  Asks the data source for the text to display in the `cellTopLabel` for the specified
     *  message data item at indexPath in the collectionView.
     *
     *  - parameter collectionView: The collection view requesting this information.
     *  - parameter indexPath:      The index path that specifies the location of the item.
     *
     *  - returns: A configured attributed string or `nil` if you do not want text displayed for the item at indexPath.
     *  Return an attributed string with `nil` attributes to use the default attributes.
     */
    @objc optional func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        attributedTextForCellTopLabelAt indexPath: IndexPath
    ) -> NSAttributedString?

    /**
     *  Asks the data source for the text to display in the `messageBubbleTopLabel` for the specified
     *  message data item at indexPath in the collectionView.
     *
     *  - parameter collectionView: The collection view requesting this information.
     *  - parameter indexPath:      The index path that specifies the location of the item.
     *
     *  - returns: A configured attributed string or `nil` if you do not want text displayed for the item at indexPath.
     *  Return an attributed string with `nil` attributes to use the default attributes.
     */
    @objc optional func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath
    ) -> NSAttributedString?

    /**
     *  Asks the data source for the text to display in the `cellBottomLabel` for the the specified
     *  message data item at indexPath in the collectionView.
     *
     *  - parameter collectionView: The collection view requesting this information.
     *  - parameter indexPath:      The index path that specifies the location of the item.
     *
     *  - returns: A configured attributed string or `nil` if you do not want text displayed for the item at indexPath.
     *  Return an attributed string with `nil` attributes to use the default attributes.
     */
    @objc optional func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        attributedTextForCellBottomLabelAt indexPath: IndexPath
    ) -> NSAttributedString?
}
