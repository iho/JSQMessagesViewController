import UIKit

/// A `JSQMessagesCollectionViewLayoutAttributes` is an object that manages the layout-related attributes
/// for a given `JSQMessagesCollectionViewCell` in a `JSQMessagesCollectionView`.
@objc public class JSQMessagesCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

    /**
     *  The font used to display the body of a text message in a message bubble within a `JSQMessagesCollectionViewCell`.
     *  This value must not be `nil`.
     */
    @objc public var messageBubbleFont: UIFont = UIFont.preferredFont(forTextStyle: .body)

    /**
     *  The width of the `messageBubbleContainerView` of a `JSQMessagesCollectionViewCell`.
     *  This value should be greater than `0.0`.
     *
     *  - seealso: JSQMessagesCollectionViewCell.
     */
    @objc public var messageBubbleContainerViewWidth: CGFloat = 320.0 {
        didSet {
            messageBubbleContainerViewWidth = ceil(messageBubbleContainerViewWidth)
        }
    }

    /**
     *  The inset of the text container's layout area within the text view's content area in a `JSQMessagesCollectionViewCell`.
     *  The specified inset values should be greater than or equal to `0.0`.
     */
    @objc public var textViewTextContainerInsets: UIEdgeInsets = .zero

    /**
     *  The inset of the frame of the text view within a `JSQMessagesCollectionViewCell`.
     *
     *  - Discussion: The inset values should be greater than or equal to `0.0` and are applied in the following ways:
     *
     *  1. The right value insets the text view frame on the side adjacent to the avatar image
     *  (or where the avatar would normally appear). For outgoing messages this is the right side,
     *  for incoming messages this is the left side.
     *
     *  2. The left value insets the text view frame on the side opposite the avatar image
     *  (or where the avatar would normally appear). For outgoing messages this is the left side,
     *  for incoming messages this is the right side.
     *
     *  3. The top value insets the top of the frame.
     *
     *  4. The bottom value insets the bottom of the frame.
     */
    @objc public var textViewFrameInsets: UIEdgeInsets = .zero

    /**
     *  The size of the `avatarImageView` of a `JSQMessagesCollectionViewCellIncoming`.
     *  The size values should be greater than or equal to `0.0`.
     *
     *  - seealso: JSQMessagesCollectionViewCellIncoming.
     */
    @objc public var incomingAvatarViewSize: CGSize = .zero {
        didSet {
            incomingAvatarViewSize = CGSize(
                width: ceil(incomingAvatarViewSize.width),
                height: ceil(incomingAvatarViewSize.height))
        }
    }

    /**
     *  The size of the `avatarImageView` of a `JSQMessagesCollectionViewCellOutgoing`.
     *  The size values should be greater than or equal to `0.0`.
     *
     *  - seealso: `JSQMessagesCollectionViewCellOutgoing`.
     */
    @objc public var outgoingAvatarViewSize: CGSize = .zero {
        didSet {
            outgoingAvatarViewSize = CGSize(
                width: ceil(outgoingAvatarViewSize.width),
                height: ceil(outgoingAvatarViewSize.height))
        }
    }

    /**
     *  The height of the `cellTopLabel` of a `JSQMessagesCollectionViewCell`.
     *  This value should be greater than or equal to `0.0`.
     *
     *  - seealso: JSQMessagesCollectionViewCell.
     */
    @objc public var cellTopLabelHeight: CGFloat = 0.0 {
        didSet {
            cellTopLabelHeight = ceil(cellTopLabelHeight)
        }
    }

    /**
     *  The height of the `messageBubbleTopLabel` of a `JSQMessagesCollectionViewCell`.
     *  This value should be greater than or equal to `0.0`.
     *
     *  - seealso: JSQMessagesCollectionViewCell.
     */
    @objc public var messageBubbleTopLabelHeight: CGFloat = 0.0 {
        didSet {
            messageBubbleTopLabelHeight = ceil(messageBubbleTopLabelHeight)
        }
    }

    /**
     *  The height of the `cellBottomLabel` of a `JSQMessagesCollectionViewCell`.
     *  This value should be greater than or equal to `0.0`.
     *
     *  - seealso: JSQMessagesCollectionViewCell.
     */
    @objc public var cellBottomLabelHeight: CGFloat = 0.0 {
        didSet {
            cellBottomLabelHeight = ceil(cellBottomLabelHeight)
        }
    }

    // MARK: - Init

    public override init() {
        super.init()
    }

    // MARK: - NSObject

    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? JSQMessagesCollectionViewLayoutAttributes else {
            return false
        }

        if self === object {
            return true
        }

        if self.representedElementCategory == .cell {
            if self.messageBubbleFont != object.messageBubbleFont
                || self.textViewFrameInsets != object.textViewFrameInsets
                || self.textViewTextContainerInsets != object.textViewTextContainerInsets
                || self.incomingAvatarViewSize != object.incomingAvatarViewSize
                || self.outgoingAvatarViewSize != object.outgoingAvatarViewSize
                || Int(self.messageBubbleContainerViewWidth)
                    != Int(object.messageBubbleContainerViewWidth)
                || Int(self.cellTopLabelHeight) != Int(object.cellTopLabelHeight)
                || Int(self.messageBubbleTopLabelHeight) != Int(object.messageBubbleTopLabelHeight)
                || Int(self.cellBottomLabelHeight) != Int(object.cellBottomLabelHeight)
            {
                return false
            }
        }

        return super.isEqual(object)
    }

    public override var hash: Int {
        return self.indexPath.hashValue
    }

    // MARK: - NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! JSQMessagesCollectionViewLayoutAttributes

        if copy.representedElementCategory != .cell {
            return copy
        }

        copy.messageBubbleFont = self.messageBubbleFont
        copy.messageBubbleContainerViewWidth = self.messageBubbleContainerViewWidth
        copy.textViewFrameInsets = self.textViewFrameInsets
        copy.textViewTextContainerInsets = self.textViewTextContainerInsets
        copy.incomingAvatarViewSize = self.incomingAvatarViewSize
        copy.outgoingAvatarViewSize = self.outgoingAvatarViewSize
        copy.cellTopLabelHeight = self.cellTopLabelHeight
        copy.messageBubbleTopLabelHeight = self.messageBubbleTopLabelHeight
        copy.cellBottomLabelHeight = self.cellBottomLabelHeight

        return copy
    }
}
