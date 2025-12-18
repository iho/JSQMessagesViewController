import UIKit

/// *  The `JSQMessagesCollectionViewDelegateFlowLayout` protocol defines methods that allow you to
/// *  manage additional layout information for the collection view and respond to additional actions on its items.
/// *  The methods of this protocol are all optional.
@objc
public protocol JSQMessagesCollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {

    /**
     *  Asks the delegate for the height of the `cellTopLabel` for the item at the specified indexPath.
     *
     *  - parameter collectionView:       The collection view object displaying the flow layout.
     *  - parameter collectionViewLayout: The layout object requesting the information.
     *  - parameter indexPath:            The index path of the item.
     *
     *  - returns: The height of the `cellTopLabel` for the item at indexPath.
     */
    @objc optional func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForCellTopLabelAt indexPath: IndexPath
    ) -> CGFloat

    /**
     *  Asks the delegate for the height of the `messageBubbleTopLabel` for the item at the specified indexPath.
     *
     *  - parameter collectionView:       The collection view object displaying the flow layout.
     *  - parameter collectionViewLayout: The layout object requesting the information.
     *  - parameter indexPath:            The index path of the item.
     *
     *  - returns: The height of the `messageBubbleTopLabel` for the item at indexPath.
     */
    @objc optional func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForMessageBubbleTopLabelAt indexPath: IndexPath
    ) -> CGFloat

    /**
     *  Asks the delegate for the height of the `cellBottomLabel` for the item at the specified indexPath.
     *
     *  - parameter collectionView:       The collection view object displaying the flow layout.
     *  - parameter collectionViewLayout: The layout object requesting the information.
     *  - parameter indexPath:            The index path of the item.
     *
     *  - returns: The height of the `cellBottomLabel` for the item at indexPath.
     */
    @objc optional func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForCellBottomLabelAt indexPath: IndexPath
    ) -> CGFloat

    /**
     *  Notifies the delegate that the avatar image view at the specified indexPath did receive a tap event.
     *
     *  - parameter collectionView:  The collection view object that is notifying the delegate of the tap event.
     *  - parameter avatarImageView: The avatar image view that was tapped.
     *  - parameter indexPath:       The index path of the item for which the avatar was tapped.
     */
    @objc optional func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        didTapAvatarImageView avatarImageView: UIImageView, at indexPath: IndexPath)

    /**
     *  Notifies the delegate that the message bubble at the specified indexPath did receive a tap event.
     *
     *  - parameter collectionView: The collection view object that is notifying the delegate of the tap event.
     *  - parameter indexPath:      The index path of the item for which the message bubble was tapped.
     */
    @objc optional func collectionView(
        _ collectionView: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath)

    /**
     *  Notifies the delegate that the cell at the specified indexPath did receive a tap event at the specified touchLocation.
     *
     *  - parameter collectionView: The collection view object that is notifying the delegate of the tap event.
     *  - parameter indexPath:      The index path of the item for which the message bubble was tapped.
     *  - parameter touchLocation:  The location of the touch event in the cell's coordinate system.
     *
     *  - Warning: This method is *only* called if position is *not* within the bounds of the cell's
     *  avatar image view or message bubble image view. In other words, this method is *not* called when the cell's
     *  avatar or message bubble are tapped. There are separate delegate methods for these two cases.
     */
    @objc optional func collectionView(
        _ collectionView: JSQMessagesCollectionView, didTapCellAt indexPath: IndexPath,
        touchLocation: CGPoint)

    /**
     *  Notifies the delegate that the collection view's header did receive a tap event.
     *
     *  - parameter collectionView: The collection view object that is notifying the delegate of the tap event.
     *  - parameter headerView:     The header view in the collection view.
     *  - parameter sender:         The button that was tapped.
     */
    @objc optional func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        header headerView: JSQMessagesLoadEarlierHeaderView,
        didTapLoadEarlierMessagesButton sender: UIButton)
}
