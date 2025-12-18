import Foundation
import UIKit

/// *  The `JSQMessagesViewAccessoryButtonDelegate` protocol defines methods that allow you to
/// *  handle accessory actions for the collection view.
public protocol JSQMessagesViewAccessoryButtonDelegate: NSObjectProtocol {

    /**
     *  Notifies the delegate that the accessory button at the specified indexPath did receive a tap event.
     *
     *  - parameter messageView:    The collection view object that is notifying the delegate of the tap event.
     *  - parameter path:      The index path of the item for which the accessory button was tapped.
     */
    func messageView(
        _ messageView: JSQMessagesCollectionView, didTapAccessoryButtonAt path: IndexPath)
}
