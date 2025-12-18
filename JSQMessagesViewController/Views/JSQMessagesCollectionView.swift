import UIKit

/// The `JSQMessagesCollectionView` class manages an ordered collection of message data items and presents
/// them using a specialized layout for messages.
@objc
public class JSQMessagesCollectionView: UICollectionView, JSQMessagesCollectionViewCellDelegate,
    JSQMessagesLoadEarlierHeaderViewDelegate
{

    /**
     *  The object that provides the data for the collection view.
     *  The data source must adopt the `JSQMessagesCollectionViewDataSource` protocol.
     */
    public weak var messagesDataSource: JSQMessagesCollectionViewDataSource? {
        didSet {
            super.dataSource = messagesDataSource
        }
    }

    /**
     *  The object that acts as the delegate of the collection view.
     *  The delegate must adopt the `JSQMessagesCollectionViewDelegateFlowLayout` protocol.
     */
    public weak var messagesCollectionViewDelegate: JSQMessagesCollectionViewDelegateFlowLayout?
    {
        didSet {
            super.delegate = messagesCollectionViewDelegate
        }
    }

    /**
     *  The object that handles accessory actions for the collection view.
     *  It must adopt the `JSQMessagesViewAccessoryButtonDelegate` protocol.
     */
    public weak var accessoryDelegate: JSQMessagesViewAccessoryButtonDelegate?

    /**
     *  The layout used to organize the collection view’s items.
     */
    public var messagesCollectionViewLayout: JSQMessagesCollectionViewFlowLayout {
        get {
            return super.collectionViewLayout as! JSQMessagesCollectionViewFlowLayout
        }
        set {
            super.collectionViewLayout = newValue
        }
    }

    /**
     *  Specifies whether the typing indicator displays on the left or right side of the collection view
     *  when shown. That is, whether it displays for an "incoming" or "outgoing" message.
     *  The default value is `true`, meaning that the typing indicator will display on the left side of the
     *  collection view for incoming messages.
     *
     *  - Discussion: If your `JSQMessagesViewController` subclass displays messages for right-to-left
     *  languages, such as Arabic, set this property to `false`.
     */
    public var typingIndicatorDisplaysOnLeft: Bool = true

    /**
     *  The color of the typing indicator message bubble. The default value is a light gray color.
     */
    public var typingIndicatorMessageBubbleColor: UIColor =
        UIColor.jsq_messageBubbleLightGray()
    {
        didSet {
            typingIndicatorEllipsisColor =
                typingIndicatorMessageBubbleColor.jsq_colorByDarkeningColor(withValue: 0.3)
        }
    }

    /**
     *  The color of the typing indicator ellipsis. The default value is a dark gray color.
     */
    public var typingIndicatorEllipsisColor: UIColor

    /**
     *  The color of the text in the load earlier messages header. The default value is a bright blue color.
     */
    public var loadEarlierMessagesHeaderTextColor: UIColor = UIColor.jsq_messageBubbleBlue()

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        self.typingIndicatorEllipsisColor = UIColor.jsq_messageBubbleLightGray()
            .jsq_colorByDarkeningColor(withValue: 0.3)
        super.init(frame: frame, collectionViewLayout: layout)
        jsq_configureCollectionView()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.typingIndicatorEllipsisColor = UIColor.jsq_messageBubbleLightGray()
            .jsq_colorByDarkeningColor(withValue: 0.3)
        super.init(coder: aDecoder)
        jsq_configureCollectionView()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        jsq_configureCollectionView()
    }

    private func jsq_configureCollectionView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.keyboardDismissMode = .interactive
        self.alwaysBounceVertical = true
        self.bounces = true

        self.register(
            JSQMessagesCollectionViewCellIncoming.nib(),
            forCellWithReuseIdentifier: JSQMessagesCollectionViewCellIncoming.cellReuseIdentifier())
        self.register(
            JSQMessagesCollectionViewCellOutgoing.nib(),
            forCellWithReuseIdentifier: JSQMessagesCollectionViewCellOutgoing.cellReuseIdentifier())
        self.register(
            JSQMessagesCollectionViewCellIncoming.nib(),
            forCellWithReuseIdentifier:
                JSQMessagesCollectionViewCellIncoming.mediaCellReuseIdentifier())
        self.register(
            JSQMessagesCollectionViewCellOutgoing.nib(),
            forCellWithReuseIdentifier:
                JSQMessagesCollectionViewCellOutgoing.mediaCellReuseIdentifier())

        self.register(
            JSQMessagesTypingIndicatorFooterView.nib(),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: JSQMessagesTypingIndicatorFooterView.footerReuseIdentifier())
        self.register(
            JSQMessagesLoadEarlierHeaderView.nib(),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: JSQMessagesLoadEarlierHeaderView.headerReuseIdentifier())
    }

    // MARK: - Typing indicator

    public func dequeueTypingIndicatorFooterView(for indexPath: IndexPath)
        -> JSQMessagesTypingIndicatorFooterView
    {
        let footerView =
            super.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: JSQMessagesTypingIndicatorFooterView.footerReuseIdentifier(),
                for: indexPath) as! JSQMessagesTypingIndicatorFooterView

        footerView.configure(
            withEllipsisColor: typingIndicatorEllipsisColor,
            messageBubbleColor: typingIndicatorMessageBubbleColor, animated: true,
            shouldDisplayOnLeft: typingIndicatorDisplaysOnLeft, for: self)

        return footerView
    }

    // MARK: - Load earlier messages header

    public func dequeueLoadEarlierMessagesViewHeader(for indexPath: IndexPath)
        -> JSQMessagesLoadEarlierHeaderView
    {
        let headerView =
            super.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: JSQMessagesLoadEarlierHeaderView.headerReuseIdentifier(),
                for: indexPath) as! JSQMessagesLoadEarlierHeaderView

        headerView.loadButton.tintColor = loadEarlierMessagesHeaderTextColor
        headerView.delegate = self

        return headerView
    }

    // MARK: - Load earlier messages header delegate

    public func headerView(
        _ headerView: JSQMessagesLoadEarlierHeaderView, didPressLoadButton sender: UIButton
    ) {
        (delegate as? JSQMessagesCollectionViewDelegateFlowLayout)?.collectionView?(
            self, header: headerView, didTapLoadEarlierMessagesButton: sender)
    }

    // MARK: - Messages collection view cell delegate

    public func messagesCollectionViewCellDidTapAvatar(_ cell: JSQMessagesCollectionViewCell) {
        guard let indexPath = self.indexPath(for: cell) else { return }
        (delegate as? JSQMessagesCollectionViewDelegateFlowLayout)?.collectionView?(
            self, didTapAvatarImageView: cell.avatarImageView, at: indexPath)
    }

    public func messagesCollectionViewCellDidTapMessageBubble(
        _ cell: JSQMessagesCollectionViewCell
    ) {
        guard let indexPath = self.indexPath(for: cell) else { return }
        (delegate as? JSQMessagesCollectionViewDelegateFlowLayout)?.collectionView?(
            self, didTapMessageBubbleAt: indexPath)
    }

    public func messagesCollectionViewCellDidTapCell(
        _ cell: JSQMessagesCollectionViewCell, atPosition position: CGPoint
    ) {
        guard let indexPath = self.indexPath(for: cell) else { return }
        (delegate as? JSQMessagesCollectionViewDelegateFlowLayout)?.collectionView?(
            self, didTapCellAt: indexPath, touchLocation: position)
    }

    public func messagesCollectionViewCell(
        _ cell: JSQMessagesCollectionViewCell, didPerformAction action: Selector,
        withSender sender: Any?
    ) {
        guard let indexPath = self.indexPath(for: cell) else { return }
        // Note: delegate method signature for performAction might differ slightly in naming translation
        // ObjC: collectionView:performAction:forItemAtIndexPath:withSender:
        // Swift: collectionView(_:performAction:forItemAt:withSender:)
        // This is actually a UICollectionViewDelegate method, so standard delegate works?
        // But the error log didn't mention this one.
        // Wait, standard definition is: collectionView(_:performAction:forItemAt:withSender:)
        // If it's standard, NO cast is needed.
        // But if I want to be safe or if standard signature matches, I can leave it or verify.
        // The error log showed lines 190, 197. Line 208 was NOT in error log?
        // Let's assume performAction is standard.
        delegate?.collectionView?(
            self, performAction: action, forItemAt: indexPath, withSender: sender)
    }

    public func messagesCollectionViewCellDidTapAccessoryButton(
        _ cell: JSQMessagesCollectionViewCell
    ) {
        guard let indexPath = self.indexPath(for: cell) else { return }
        accessoryDelegate?.messageView(self, didTapAccessoryButtonAt: indexPath)
    }

}
