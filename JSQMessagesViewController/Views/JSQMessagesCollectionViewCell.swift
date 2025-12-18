import UIKit

/// The `JSQMessagesCollectionViewCellDelegate` protocol defines methods that allow you to manage
/// additional interactions within the collection view cell.
@objc public protocol JSQMessagesCollectionViewCellDelegate: NSObjectProtocol {

    /**
     *  Tells the delegate that the avatarImageView of the cell has been tapped.
     *
     *  - parameter cell: The cell that received the tap touch event.
     */
    func messagesCollectionViewCellDidTapAvatar(_ cell: JSQMessagesCollectionViewCell)

    /**
     *  Tells the delegate that the message bubble of the cell has been tapped.
     *
     *  - parameter cell: The cell that received the tap touch event.
     */
    func messagesCollectionViewCellDidTapMessageBubble(_ cell: JSQMessagesCollectionViewCell)

    /**
     *  Tells the delegate that the cell has been tapped at the point specified by position.
     *
     *  - parameter cell: The cell that received the tap touch event.
     *  - parameter position: The location of the received touch in the cell's coordinate system.
     *
     *  - Discussion: This method is *only* called if position is *not* within the bounds of the cell's
     *  avatar image view or message bubble image view. In other words, this method is *not* called when the cell's
     *  avatar or message bubble are tapped.
     */
    func messagesCollectionViewCellDidTapCell(
        _ cell: JSQMessagesCollectionViewCell, atPosition position: CGPoint)

    /**
     *  Tells the delegate that an actions has been selected from the menu of this cell.
     *  This method is automatically called for any registered actions.
     *
     *  - parameter cell: The cell that displayed the menu.
     *  - parameter action: The action that has been performed.
     *  - parameter sender: The object that initiated the action.
     */
    func messagesCollectionViewCell(
        _ cell: JSQMessagesCollectionViewCell, didPerformAction action: Selector,
        withSender sender: Any?)

    /**
     *  Tells the delegate that the accessory button of the cell has been tapped.
     *
     *  - parameter cell: The cell that the accessory button belongs to.
     */
    func messagesCollectionViewCellDidTapAccessoryButton(_ cell: JSQMessagesCollectionViewCell)
}

/// The `JSQMessagesCollectionViewCell` is an abstract base class that presents the content for
/// a single message data item when that item is within the collection view’s visible bounds.
/// The layout and presentation of cells is managed by the collection view and its corresponding layout object.
///
/// - Warning: This class is intended to be subclassed. You should not use it directly.
@objc(JSQMessagesCollectionViewCell)
public class JSQMessagesCollectionViewCell: UICollectionViewCell {

    /**
     *  The object that acts as the delegate for the cell.
     */
    @objc public weak var delegate: JSQMessagesCollectionViewCellDelegate?

    /**
     *  Returns the label that is pinned to the top of the cell.
     *  This label is most commonly used to display message timestamps.
     */
    @IBOutlet public weak var cellTopLabel: JSQMessagesLabel!

    /**
     *  Returns the label that is pinned just above the messageBubbleImageView, and below the cellTopLabel.
     *  This label is most commonly used to display the message sender.
     */
    @IBOutlet public weak var messageBubbleTopLabel: JSQMessagesLabel!

    /**
     *  Returns the label that is pinned to the bottom of the cell.
     *  This label is most commonly used to display message delivery status.
     */
    @IBOutlet public weak var cellBottomLabel: JSQMessagesLabel!

    /**
     *  Returns the text view of the cell. This text view contains the message body text.
     *
     *  - Warning: If mediaView returns a non-nil view, then this value will be `nil`.
     */
    @IBOutlet public weak var textView: JSQMessagesCellTextView!

    /**
     *  Returns the bubble image view of the cell that is responsible for displaying message bubble images.
     *
     *  - Warning: If mediaView returns a non-nil view, then this value will be `nil`.
     */
    @IBOutlet public weak var messageBubbleImageView: UIImageView!

    /**
     *  Returns the message bubble container view of the cell. This view is the superview of
     *  the cell's textView and messageBubbleImageView.
     *
     *  - Discussion: You may customize the cell by adding custom views to this container view.
     *  To do so, override `collectionView:cellForItemAtIndexPath:`
     *
     *  - Warning: You should not try to manipulate any properties of this view, for example adjusting
     *  its frame, nor should you remove this view from the cell or remove any of its subviews.
     *  Doing so could result in unexpected behavior.
     */
    @IBOutlet public weak var messageBubbleContainerView: UIView!

    /**
     *  Returns the avatar image view of the cell that is responsible for displaying avatar images.
     */
    @IBOutlet public weak var avatarImageView: UIImageView!

    /**
     *  Returns the avatar container view of the cell. This view is the superview of the cell's avatarImageView.
     *
     *  - Discussion: You may customize the cell by adding custom views to this container view.
     *  To do so, override `collectionView:cellForItemAtIndexPath:`
     *
     *  - Warning: You should not try to manipulate any properties of this view, for example adjusting
     *  its frame, nor should you remove this view from the cell or remove any of its subviews.
     *  Doing so could result in unexpected behavior.
     */
    @IBOutlet public weak var avatarContainerView: UIView!

    /**
     *  Returns the accessory button of the cell.
     */
    @IBOutlet public weak var accessoryButton: UIButton!

    /**
     *  The media view of the cell. This view displays the contents of a media message.
     *
     *  - Warning: If this value is non-nil, then textView and messageBubbleImageView will both be `nil`.
     */
    @objc public var mediaView: UIView? {
        didSet {
            guard let mediaView = mediaView else { return }

            messageBubbleImageView.removeFromSuperview()
            textView.removeFromSuperview()

            mediaView.translatesAutoresizingMaskIntoConstraints = false
            mediaView.frame = messageBubbleContainerView.bounds

            messageBubbleContainerView.addSubview(mediaView)
            messageBubbleContainerView.jsq_pinAllEdgesOfSubview(mediaView)

            //  because of cell re-use (and caching media views, if using built-in library media item)
            //  we may have dequeued a cell with a media view and add this one on top
            //  thus, remove any additional subviews hidden behind the new media view
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                for subview in self.messageBubbleContainerView.subviews {
                    if subview != mediaView {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }

    /**
     *  Returns the underlying gesture recognizer for tap gestures in the avatarImageView of the cell.
     *  This gesture handles the tap event for the avatarImageView and notifies the cell's delegate.
     */
    @objc public weak var tapGestureRecognizer: UITapGestureRecognizer?

    @IBOutlet private weak var messageBubbleContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textViewTopVerticalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textViewBottomVerticalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textViewAvatarHorizontalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textViewMarginHorizontalSpaceConstraint: NSLayoutConstraint!

    @IBOutlet private weak var cellTopLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var messageBubbleTopLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellBottomLabelHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var avatarContainerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var avatarContainerViewHeightConstraint: NSLayoutConstraint!

    private var _textViewFrameInsets: UIEdgeInsets = .zero
    @objc public var textViewFrameInsets: UIEdgeInsets {
        get {
            return UIEdgeInsets(
                top: textViewTopVerticalSpaceConstraint.constant,
                left: textViewMarginHorizontalSpaceConstraint.constant,
                bottom: textViewBottomVerticalSpaceConstraint.constant,
                right: textViewAvatarHorizontalSpaceConstraint.constant)
        }
        set {
            if newValue == _textViewFrameInsets { return }
            _textViewFrameInsets = newValue
            jsq_updateConstraint(textViewTopVerticalSpaceConstraint, withConstant: newValue.top)
            jsq_updateConstraint(
                textViewBottomVerticalSpaceConstraint, withConstant: newValue.bottom)
            jsq_updateConstraint(
                textViewAvatarHorizontalSpaceConstraint, withConstant: newValue.right)
            jsq_updateConstraint(
                textViewMarginHorizontalSpaceConstraint, withConstant: newValue.left)
        }
    }

    private var _avatarViewSize: CGSize = .zero
    @objc public var avatarViewSize: CGSize {
        get {
            return CGSize(
                width: avatarContainerViewWidthConstraint.constant,
                height: avatarContainerViewHeightConstraint.constant)
        }
        set {
            if newValue == _avatarViewSize { return }
            _avatarViewSize = newValue
            jsq_updateConstraint(avatarContainerViewWidthConstraint, withConstant: newValue.width)
            jsq_updateConstraint(avatarContainerViewHeightConstraint, withConstant: newValue.height)
        }
    }

    /**
     *  Returns the `UINib` object initialized for the cell.
     *
     *  - returns: The initialized `UINib` object.
     */
    @objc public class func nib() -> UINib {
        // NSStringFromClass(self) with @objc(Name) returns Name.
        return UINib(nibName: NSStringFromClass(self), bundle: Bundle(for: self))
    }

    /**
     *  Returns the default string used to identify a reusable cell for text message items.
     *
     *  - returns: The string used to identify a reusable cell.
     */
    @objc public class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }

    /**
     *  Returns the default string used to identify a reusable cell for media message items.
     *
     *  - returns: The string used to identify a reusable cell.
     */
    @objc public class func mediaCellReuseIdentifier() -> String {
        return NSStringFromClass(self) + "_JSQMedia"
    }

    // MARK: - Menu Actions

    // Note: In Swift, dynamic registration of actions via forwardInvocation is not supported.
    // Actions are handled via UICollectionViewDelegate methods in the controller.
    @available(*, deprecated, message: "Use UICollectionViewDelegate methods to handle actions.")
    @objc public class func registerMenuAction(_ action: Selector) {
        // No-op
    }

    // MARK: - Initialization

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.translatesAutoresizingMaskIntoConstraints = false

        self.isAccessibilityElement = true
        self.backgroundColor = .white
        self.avatarViewSize = .zero

        let topLabelFont = UIFont.preferredFont(forTextStyle: .caption1)
        self.cellTopLabel.textAlignment = .center
        self.cellTopLabel.font = topLabelFont
        self.cellTopLabel.textColor = .lightGray
        self.cellTopLabel.numberOfLines = 0

        let messageBubbleTopLabelFont = UIFont.preferredFont(forTextStyle: .caption1)
        self.messageBubbleTopLabel.font = messageBubbleTopLabelFont
        self.messageBubbleTopLabel.textColor = .lightGray
        self.messageBubbleTopLabel.numberOfLines = 0

        let bottomLabelFont = UIFont.preferredFont(forTextStyle: .caption2)
        self.cellBottomLabel.font = bottomLabelFont
        self.cellBottomLabel.textColor = .lightGray
        self.cellBottomLabel.numberOfLines = 0

        configureAccessoryButton()

        self.cellTopLabelHeightConstraint.constant = topLabelFont.pointSize
        self.messageBubbleTopLabelHeightConstraint.constant = messageBubbleTopLabelFont.pointSize
        self.cellBottomLabelHeightConstraint.constant = bottomLabelFont.pointSize

        let tap = UITapGestureRecognizer(target: self, action: #selector(jsq_handleTapGesture(_:)))
        self.addGestureRecognizer(tap)
        self.tapGestureRecognizer = tap
    }

    private func configureAccessoryButton() {
        let tintColor = UIColor.lightGray
        let shareActionImage = UIImage.jsq_shareAction()?.jsq_imageMasked(with: tintColor)
        self.accessoryButton.setImage(shareActionImage, for: .normal)
    }

    deinit {
        delegate = nil
        tapGestureRecognizer?.removeTarget(nil, action: nil)
        tapGestureRecognizer = nil
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        self.cellTopLabel.text = nil
        self.messageBubbleTopLabel.text = nil
        self.cellBottomLabel.text = nil

        self.textView.dataDetectorTypes = []
        self.textView.text = nil
        self.textView.attributedText = nil

        self.avatarImageView.image = nil
        self.avatarImageView.highlightedImage = nil

        self.accessoryButton.isHidden = true
    }

    public override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        guard let customAttributes = layoutAttributes as? JSQMessagesCollectionViewLayoutAttributes
        else { return }

        // textView will be nil for media messages, so check before accessing
        if let textView = self.textView {
            if textView.font != customAttributes.messageBubbleFont {
                textView.font = customAttributes.messageBubbleFont
            }

            if textView.textContainerInset != customAttributes.textViewTextContainerInsets {
                textView.textContainerInset = customAttributes.textViewTextContainerInsets
            }
        }

        self.textViewFrameInsets = customAttributes.textViewFrameInsets

        jsq_updateConstraint(
            self.messageBubbleContainerWidthConstraint,
            withConstant: customAttributes.messageBubbleContainerViewWidth)
        jsq_updateConstraint(
            self.cellTopLabelHeightConstraint, withConstant: customAttributes.cellTopLabelHeight)
        jsq_updateConstraint(
            self.messageBubbleTopLabelHeightConstraint,
            withConstant: customAttributes.messageBubbleTopLabelHeight)
        jsq_updateConstraint(
            self.cellBottomLabelHeightConstraint,
            withConstant: customAttributes.cellBottomLabelHeight)

        if self is JSQMessagesCollectionViewCellIncoming {
            self.avatarViewSize = customAttributes.incomingAvatarViewSize
        } else if self is JSQMessagesCollectionViewCellOutgoing {
            self.avatarViewSize = customAttributes.outgoingAvatarViewSize
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            self.avatarImageView?.isHighlighted = isHighlighted
            self.messageBubbleImageView?.isHighlighted = isHighlighted
        }
    }

    public override var isSelected: Bool {
        didSet {
            self.avatarImageView?.isHighlighted = isSelected
            self.messageBubbleImageView?.isHighlighted = isSelected
        }
    }

    // MARK: - Menu actions

    // forwardInvocation removed.
    // Dynamic action registration via Cell is not supported in Swift.

    // MARK: - Setters

    public override var backgroundColor: UIColor? {
        didSet {
            guard let color = backgroundColor else { return }
            cellTopLabel.backgroundColor = color
            messageBubbleTopLabel.backgroundColor = color
            cellBottomLabel.backgroundColor = color

            messageBubbleImageView.backgroundColor = color
            avatarImageView.backgroundColor = color

            messageBubbleContainerView.backgroundColor = color
            avatarContainerView.backgroundColor = color
        }
    }

    private func jsq_updateConstraint(
        _ constraint: NSLayoutConstraint, withConstant constant: CGFloat
    ) {
        if constraint.constant == constant { return }
        constraint.constant = constant
    }

    // MARK: - Gesture recognizers

    @objc func jsq_handleTapGesture(_ tap: UITapGestureRecognizer) {
        let touchPt = tap.location(in: self)

        if avatarContainerView.frame.contains(touchPt) {
            delegate?.messagesCollectionViewCellDidTapAvatar(self)
        } else if messageBubbleContainerView.frame.contains(touchPt) {
            delegate?.messagesCollectionViewCellDidTapMessageBubble(self)
        } else {
            delegate?.messagesCollectionViewCellDidTapCell(self, atPosition: touchPt)
        }
    }

    @IBAction public func didTapAccessoryButton(_ sender: UIButton) {
        delegate?.messagesCollectionViewCellDidTapAccessoryButton(self)
    }
}
