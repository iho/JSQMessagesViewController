import UIKit

@objc(JSQMessagesViewController)
open class JSQMessagesViewController: UIViewController, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout, UITextViewDelegate, JSQMessagesCollectionViewDataSource,
    JSQMessagesInputToolbarDelegate, JSQMessagesCollectionViewDelegateFlowLayout
{

    // MARK: - IBOutlets

    @IBOutlet public weak var collectionView: JSQMessagesCollectionView!
    @IBOutlet public weak var inputToolbar: JSQMessagesInputToolbar!

    // MARK: - Properties

    open var senderId: String {
        NSException(
            name: .internalInconsistencyException,
            reason:
                "Error! required method not implemented in subclass. Need to implement \(#function)",
            userInfo: nil
        ).raise()
        return ""
    }

    open var senderDisplayName: String {
        NSException(
            name: .internalInconsistencyException,
            reason:
                "Error! required method not implemented in subclass. Need to implement \(#function)",
            userInfo: nil
        ).raise()
        return ""
    }

    open var automaticallyScrollsToMostRecentMessage: Bool = true
    open var outgoingCellIdentifier: String?
    open var outgoingMediaCellIdentifier: String?
    open var incomingCellIdentifier: String?
    open var incomingMediaCellIdentifier: String?

    open var showTypingIndicator: Bool = false {
        didSet {
            if oldValue == showTypingIndicator { return }
            collectionView?.collectionViewLayout.invalidateLayout(
                with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }

    open var showLoadEarlierMessagesHeader: Bool = false {
        didSet {
            if oldValue == showLoadEarlierMessagesHeader { return }
            collectionView?.collectionViewLayout.invalidateLayout(
                with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
            collectionView?.collectionViewLayout.invalidateLayout()
            collectionView?.reloadData()
        }
    }

    open var additionalContentInset: UIEdgeInsets = .zero {
        didSet {
            jsq_updateCollectionViewInsets()
        }
    }

    // Internal/Private properties matching ObjC implementation
    private var toolbarHeightConstraint: NSLayoutConstraint?
    private var selectedIndexPathForMenu: IndexPath?

    private var notificationTokens: [NSObjectProtocol] = []
    private var jsq_isHandlingMenuShow: Bool = false

    // MARK: - Class Methods

    open class func nib() -> UINib {
        return UINib(nibName: NSStringFromClass(self), bundle: Bundle(for: self))
    }

    open class func messagesViewController() -> JSQMessagesViewController {
        return self.init(nibName: NSStringFromClass(self), bundle: Bundle(for: self))
    }

    // MARK: - Initialization

    required public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        // When loaded from storyboard, we need to manually load the XIB's view
        // to get the collectionView and inputToolbar outlets
        jsq_loadViewFromNibIfNeeded()
    }

    private func jsq_loadViewFromNibIfNeeded() {
        // Load the XIB to get the view with outlets
        let nibName = String(describing: JSQMessagesViewController.self)
        let nib = UINib(nibName: nibName, bundle: Bundle(for: JSQMessagesViewController.self))
        let nibViews = nib.instantiate(withOwner: self, options: nil)

        // The XIB should have set up the outlets via connections.
        // When instantiated via storyboard (`init(coder:)`), UIKit will not automatically
        // replace `self.view` with the one from this XIB, so we must.
        if let nibRootView = nibViews.first as? UIView {
            self.view = nibRootView
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Note: In Swift with Storyboards/XIBs associated via class name, loading might happen automatically if init(coder:) is used.
        // But if instantiated manually effectively, we follow the ObjC pattern if needed.
        // However, standard UIViewController loading from XIB usually handles IBOutlet connection before viewDidLoad.

        jsq_configureMessagesViewController()
        jsq_registerForNotifications(true)
    }

    deinit {
        jsq_registerForNotifications(false)
        collectionView?.dataSource = nil
        collectionView?.delegate = nil
        inputToolbar?.contentView?.textView?.delegate = nil
        inputToolbar?.delegate = nil
    }

    private func jsq_configureMessagesViewController() {
        self.view.backgroundColor = .white

        // toolbarHeightConstraint logic from ObjC seems dead if not connected, but let's try to mimic
        // if it were connected. Since it's not IBOutlet in ObjC, it's likely nil.
        self.toolbarHeightConstraint?.constant = self.inputToolbar.preferredDefaultHeight

        self.collectionView.messagesDataSource = self
        self.collectionView.messagesCollectionViewDelegate = self

        self.inputToolbar.messagesToolbarDelegate = self
        self.inputToolbar.contentView.textView?.placeHolder = Bundle.jsq_localizedString(
            forKey: "new_message")
        self.inputToolbar.contentView.textView?.accessibilityLabel = Bundle.jsq_localizedString(
            forKey: "new_message")
        self.inputToolbar.contentView.textView?.delegate = self
        self.inputToolbar.contentView.textView?.font = UIFont.preferredFont(forTextStyle: .body)

        // Input toolbar is removed because it is used as inputAccessoryView
        self.inputToolbar.removeFromSuperview()

        self.automaticallyScrollsToMostRecentMessage = true

        self.outgoingCellIdentifier = JSQMessagesCollectionViewCellOutgoing.cellReuseIdentifier()
        self.outgoingMediaCellIdentifier =
            JSQMessagesCollectionViewCellOutgoing.mediaCellReuseIdentifier()

        self.incomingCellIdentifier = JSQMessagesCollectionViewCellIncoming.cellReuseIdentifier()
        self.incomingMediaCellIdentifier =
            JSQMessagesCollectionViewCellIncoming.mediaCellReuseIdentifier()

        self.showTypingIndicator = false
        self.showLoadEarlierMessagesHeader = false

        self.additionalContentInset = .zero

        jsq_updateCollectionViewInsets()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Add safety checks for toolbar initialization
        guard let toolbar = inputToolbar,
            let content = toolbar.contentView
        else {
            return
        }

        if let textView = content.textView, !textView.hasText {
            toolbarHeightConstraint?.constant = toolbar.preferredDefaultHeight
        }

        self.view.layoutIfNeeded()
        self.collectionView.messagesCollectionViewLayout.invalidateLayout()

        if automaticallyScrollsToMostRecentMessage {
            DispatchQueue.main.async {
                self.scrollToBottom(animated: false)
                self.collectionView.messagesCollectionViewLayout.invalidateLayout(
                    with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
            }
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.messagesCollectionViewLayout.springinessEnabled = true
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.collectionView.messagesCollectionViewLayout.springinessEnabled = false
    }

    // MARK: - View Rotation

    open override var shouldAutorotate: Bool {
        return true
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        }
        return .all
    }

    open override func willRotate(
        to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval
    ) {
        super.willRotate(to: toInterfaceOrientation, duration: duration)
        self.collectionView.messagesCollectionViewLayout.invalidateLayout(
            with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
    }

    open override func viewWillTransition(
        to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        jsq_resetLayoutAndCaches()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        jsq_resetLayoutAndCaches()
    }

    private func jsq_resetLayoutAndCaches() {
        let context = JSQMessagesCollectionViewFlowLayoutInvalidationContext.context()
        context.invalidateFlowLayoutMessagesCache = true
        self.collectionView.messagesCollectionViewLayout.invalidateLayout(with: context)
    }

    // MARK: - Input Accessory View

    open override var inputAccessoryView: UIView? {
        return self.inputToolbar
    }

    open override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: - Actions

    open func didPressSendButton(
        _ button: UIButton, withMessageText text: String, senderId: String,
        senderDisplayName: String, date: Date
    ) {
        NSException(
            name: .internalInconsistencyException,
            reason:
                "Error! required method not implemented in subclass. Need to implement \(#function)",
            userInfo: nil
        ).raise()
    }

    open func didPressAccessoryButton(_ sender: UIButton) {
        NSException(
            name: .internalInconsistencyException,
            reason:
                "Error! required method not implemented in subclass. Need to implement \(#function)",
            userInfo: nil
        ).raise()
    }

    open func finishSendingMessage(animated: Bool = true) {
        guard let textView = inputToolbar.contentView.textView else { return }

        textView.text = nil
        textView.undoManager?.removeAllActions()

        NotificationCenter.default.post(
            name: UITextView.textDidChangeNotification, object: textView)

        let oldCount = collectionView.numberOfItems(inSection: 0)
        let newCount = self.collectionView(collectionView, numberOfItemsInSection: 0)

        collectionView.messagesCollectionViewLayout.invalidateLayout(
            with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())

        if newCount >= oldCount {
            let insertedIndexPaths = (oldCount..<newCount).map { IndexPath(item: $0, section: 0) }

            let applyUpdates = {
                if !insertedIndexPaths.isEmpty {
                    self.collectionView.insertItems(at: insertedIndexPaths)
                } else {
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                }
            }

            let completion: (Bool) -> Void = { _ in
                if self.automaticallyScrollsToMostRecentMessage {
                    self.scrollToBottom(animated: animated)
                }
            }

            if animated {
                collectionView.performBatchUpdates(applyUpdates, completion: completion)
            } else {
                UIView.performWithoutAnimation {
                    collectionView.performBatchUpdates(applyUpdates, completion: completion)
                    collectionView.layoutIfNeeded()
                }
            }
        } else {
            collectionView.reloadData()
            if automaticallyScrollsToMostRecentMessage {
                scrollToBottom(animated: animated)
            }
        }
    }

    open func finishReceivingMessage(animated: Bool = true) {
        self.showTypingIndicator = false

        let oldCount = collectionView.numberOfItems(inSection: 0)
        let newCount = self.collectionView(collectionView, numberOfItemsInSection: 0)

        collectionView.messagesCollectionViewLayout.invalidateLayout(
            with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())

        if newCount >= oldCount {
            let insertedIndexPaths = (oldCount..<newCount).map { IndexPath(item: $0, section: 0) }

            let applyUpdates = {
                if !insertedIndexPaths.isEmpty {
                    self.collectionView.insertItems(at: insertedIndexPaths)
                } else {
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                }
            }

            let completion: (Bool) -> Void = { _ in
                if self.automaticallyScrollsToMostRecentMessage && !self.jsq_isMenuVisible() {
                    self.scrollToBottom(animated: animated)
                }
            }

            if animated {
                collectionView.performBatchUpdates(applyUpdates, completion: completion)
            } else {
                UIView.performWithoutAnimation {
                    collectionView.performBatchUpdates(applyUpdates, completion: completion)
                    collectionView.layoutIfNeeded()
                }
            }
        } else {
            collectionView.reloadData()
            if automaticallyScrollsToMostRecentMessage && !jsq_isMenuVisible() {
                scrollToBottom(animated: animated)
            }
        }

        UIAccessibility.post(
            notification: .announcement,
            argument: Bundle.jsq_localizedString(
                forKey: "new_message_received_accessibility_announcement"))
    }

    open func scrollToBottom(animated: Bool) {
        if collectionView.numberOfSections == 0 { return }

        let items = collectionView.numberOfItems(inSection: 0)
        if items == 0 { return }

        let lastCell = IndexPath(item: items - 1, section: 0)
        scrollToIndexPath(lastCell, animated: animated)
    }

    open func scrollToIndexPath(_ indexPath: IndexPath, animated: Bool) {
        if collectionView.numberOfSections <= indexPath.section { return }

        let numberOfItems = collectionView.numberOfItems(inSection: indexPath.section)
        if numberOfItems == 0 { return }

        let collectionViewContentHeight = collectionView.collectionViewLayout
            .collectionViewContentSize.height
        let isContentTooSmall = (collectionViewContentHeight < collectionView.bounds.height)

        if isContentTooSmall {
            collectionView.scrollRectToVisible(
                CGRect(x: 0.0, y: collectionViewContentHeight - 1.0, width: 1.0, height: 1.0),
                animated: animated)
            return
        }

        let item = max(min(indexPath.item, numberOfItems - 1), 0)
        let safeIndexPath = IndexPath(item: item, section: 0)

        let cellSize = collectionView.messagesCollectionViewLayout.sizeForItem(at: safeIndexPath)
        let maxHeightForVisibleMessage =
            collectionView.bounds.height - collectionView.contentInset.top
            - collectionView.contentInset.bottom - inputToolbar.bounds.height

        let scrollPosition: UICollectionView.ScrollPosition =
            (cellSize.height > maxHeightForVisibleMessage) ? .bottom : .top

        collectionView.scrollToItem(at: safeIndexPath, at: scrollPosition, animated: animated)
    }

    open func isOutgoingMessage(_ messageItem: any JSQMessageData) -> Bool {
        return messageItem.senderId == self.senderId
    }

    // MARK: - Collection View Data Source

    open func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        return 0
    }

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        guard let customCollectionView = collectionView as? JSQMessagesCollectionView else {
            fatalError("CollectionView must be JSQMessagesCollectionView")
        }

        let messageItem = customCollectionView.messagesDataSource?.collectionView(
            customCollectionView, messageDataForItemAt: indexPath)
        assert(messageItem != nil, "Delegate must return message data")

        let isOutgoing = isOutgoingMessage(messageItem!)
        let isMedia = messageItem!.isMediaMessage

        let cellIdentifier: String
        if isMedia {
            cellIdentifier =
                isOutgoing
                ? (outgoingMediaCellIdentifier
                    ?? JSQMessagesCollectionViewCellOutgoing.mediaCellReuseIdentifier())
                : (incomingMediaCellIdentifier
                    ?? JSQMessagesCollectionViewCellIncoming.mediaCellReuseIdentifier())
        } else {
            cellIdentifier =
                isOutgoing
                ? (outgoingCellIdentifier
                    ?? JSQMessagesCollectionViewCellOutgoing.cellReuseIdentifier())
                : (incomingCellIdentifier
                    ?? JSQMessagesCollectionViewCellIncoming.cellReuseIdentifier())
        }

        let cell =
            customCollectionView.dequeueReusableCell(
                withReuseIdentifier: cellIdentifier, for: indexPath)
            as! JSQMessagesCollectionViewCell
        cell.delegate = customCollectionView

        if !isMedia {
            cell.textView?.text = messageItem!.text as? String

            let bubbleImageDataSource = customCollectionView.messagesDataSource?.collectionView(
                customCollectionView, messageBubbleImageDataForItemAt: indexPath)
            cell.messageBubbleImageView?.image = bubbleImageDataSource?.messageBubbleImage
            cell.messageBubbleImageView?.highlightedImage =
                bubbleImageDataSource?
                .messageBubbleHighlightedImage
        } else {
            let messageMedia = messageItem!.media as? JSQMessageMediaData
            cell.mediaView = messageMedia?.mediaView() ?? messageMedia?.mediaPlaceholderView()
        }

        var needsAvatar = true
        if let layout = customCollectionView.collectionViewLayout
            as? JSQMessagesCollectionViewFlowLayout
        {
            if isOutgoing && layout.outgoingAvatarViewSize == .zero {
                needsAvatar = false
            } else if !isOutgoing && layout.incomingAvatarViewSize == .zero {
                needsAvatar = false
            }
        }

        if needsAvatar {
            let avatarImageDataSource = customCollectionView.messagesDataSource?.collectionView(
                customCollectionView, avatarImageDataForItemAt: indexPath)
            if let avatarImageDataSource = avatarImageDataSource {
                let avatarImage = avatarImageDataSource.avatarImage
                if avatarImage == nil {
                    cell.avatarImageView?.image = avatarImageDataSource.avatarPlaceholderImage
                    cell.avatarImageView?.highlightedImage = nil
                } else {
                    cell.avatarImageView?.image = avatarImage
                    cell.avatarImageView?.highlightedImage =
                        avatarImageDataSource.avatarHighlightedImage
                }
            }
        }

        cell.cellTopLabel?.attributedText = customCollectionView.messagesDataSource?
            .collectionView?(
                customCollectionView, attributedTextForCellTopLabelAt: indexPath)
        cell.messageBubbleTopLabel?.attributedText = customCollectionView.messagesDataSource?
            .collectionView?(
                customCollectionView, attributedTextForMessageBubbleTopLabelAt: indexPath)
        cell.cellBottomLabel?.attributedText = customCollectionView.messagesDataSource?
            .collectionView?(
                customCollectionView, attributedTextForCellBottomLabelAt: indexPath)

        let bubbleTopLabelInset: CGFloat = (needsAvatar) ? 60.0 : 15.0

        if isOutgoing {
            cell.messageBubbleTopLabel?.textInsets = UIEdgeInsets(
                top: 0, left: 0, bottom: 0, right: bubbleTopLabelInset)
        } else {
            cell.messageBubbleTopLabel?.textInsets = UIEdgeInsets(
                top: 0, left: bubbleTopLabelInset, bottom: 0, right: 0)
        }

        cell.textView?.dataDetectorTypes = .all
        cell.backgroundColor = .clear
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.layer.shouldRasterize = true

        self.collectionView(
            customCollectionView, accessibilityForCell: cell, indexPath: indexPath,
            message: messageItem!)

        return cell
    }

    private func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        accessibilityForCell cell: JSQMessagesCollectionViewCell, indexPath: IndexPath,
        message: any JSQMessageData
    ) {
        cell.isAccessibilityElement = true
        if !message.isMediaMessage {
            cell.accessibilityLabel = String(
                format: Bundle.jsq_localizedString(forKey: "text_message_accessibility_label"),
                message.senderDisplayName, (message.text as? String) ?? "")
        } else {
            cell.accessibilityLabel = String(
                format: Bundle.jsq_localizedString(forKey: "media_message_accessibility_label"),
                message.senderDisplayName)
        }
    }

    open func collectionView(
        _ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let customCollectionView = collectionView as? JSQMessagesCollectionView else {
            return UICollectionReusableView()
        }

        if showTypingIndicator && kind == UICollectionView.elementKindSectionFooter {
            return customCollectionView.dequeueTypingIndicatorFooterView(for: indexPath)
        } else if showLoadEarlierMessagesHeader && kind == UICollectionView.elementKindSectionHeader
        {
            return customCollectionView.dequeueLoadEarlierMessagesViewHeader(for: indexPath)
        }

        return UICollectionReusableView()
    }

    // MARK: - JSQMessagesCollectionViewDataSource Stubs
    // Subclasses MUST implement these because they access the data source

    open func collectionView(
        _ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath
    ) -> any JSQMessageData {
        NSException(
            name: .internalInconsistencyException,
            reason:
                "Error! required method not implemented in subclass. Need to implement \(#function)",
            userInfo: nil
        ).raise()
        fatalError("Unreachable")
    }

    open func collectionView(
        _ collectionView: JSQMessagesCollectionView, didDeleteMessageAt indexPath: IndexPath
    ) {
        NSException(
            name: .internalInconsistencyException,
            reason:
                "Error! required method not implemented in subclass. Need to implement \(#function)",
            userInfo: nil
        ).raise()
    }

    open func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        messageBubbleImageDataForItemAt indexPath: IndexPath
    ) -> (any JSQMessageBubbleImageDataSource)? {
        NSException(
            name: .internalInconsistencyException,
            reason:
                "Error! required method not implemented in subclass. Need to implement \(#function)",
            userInfo: nil
        ).raise()
        fatalError("Unreachable")
    }

    open func collectionView(
        _ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath
    ) -> (any JSQMessageAvatarImageDataSource)? {
        NSException(
            name: .internalInconsistencyException,
            reason:
                "Error! required method not implemented in subclass. Need to implement \(#function)",
            userInfo: nil
        ).raise()
        fatalError("Unreachable")
    }

    // Optional methods
    open func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        attributedTextForCellTopLabelAt indexPath: IndexPath
    ) -> NSAttributedString? { return nil }
    open func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath
    ) -> NSAttributedString? { return nil }
    open func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        attributedTextForCellBottomLabelAt indexPath: IndexPath
    ) -> NSAttributedString? { return nil }

    // MARK: - JSQMessagesCollectionViewDelegateFlowLayout

    open func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForCellTopLabelAt indexPath: IndexPath
    ) -> CGFloat { return 0.0 }

    open func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForMessageBubbleTopLabelAt indexPath: IndexPath
    ) -> CGFloat { return 0.0 }

    open func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForCellBottomLabelAt indexPath: IndexPath
    ) -> CGFloat { return 0.0 }

    open func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        didTapAvatarImageView avatarImageView: UIImageView, at indexPath: IndexPath
    ) {}

    open func collectionView(
        _ collectionView: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath
    ) {}

    open func collectionView(
        _ collectionView: JSQMessagesCollectionView, didTapCellAt indexPath: IndexPath,
        touchLocation: CGPoint
    ) {}

    open func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        header headerView: JSQMessagesLoadEarlierHeaderView,
        didTapLoadEarlierMessagesButton sender: UIButton
    ) {}

    // MARK: - UICollectionViewDelegateFlowLayout

    open func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let flowLayout = collectionViewLayout as? JSQMessagesCollectionViewFlowLayout else {
            return .zero
        }
        return flowLayout.sizeForItem(at: indexPath)
    }

    open func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        if !showTypingIndicator { return .zero }
        guard let flowLayout = collectionViewLayout as? JSQMessagesCollectionViewFlowLayout else {
            return .zero
        }
        return CGSize(
            width: flowLayout.itemWidth, height: kJSQMessagesTypingIndicatorFooterViewHeight)
    }

    open func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if !showLoadEarlierMessagesHeader { return .zero }
        guard let flowLayout = collectionViewLayout as? JSQMessagesCollectionViewFlowLayout else {
            return .zero
        }
        return CGSize(width: flowLayout.itemWidth, height: kJSQMessagesLoadEarlierHeaderViewHeight)
    }

    // MARK: - Collection View Delegate - Menu Actions

    open func collectionView(
        _ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath
    ) -> Bool {
        guard let customCollectionView = collectionView as? JSQMessagesCollectionView else {
            return false
        }

        let messageItem = customCollectionView.messagesDataSource?.collectionView(
            customCollectionView, messageDataForItemAt: indexPath)

        if let messageItem = messageItem, messageItem.isMediaMessage {
            // Logic check: original checked if media responds to mediaDataType. Swift mediaData protocol handles this.
            return true
        }

        self.selectedIndexPathForMenu = indexPath

        if let selectedCell = collectionView.cellForItem(at: indexPath)
            as? JSQMessagesCollectionViewCell
        {
            selectedCell.textView?.isSelectable = false  // Prevent system menu conflict

            // Re-assign font/color to preserve appearance (workaround)
            selectedCell.textView?.textColor = selectedCell.textView?.textColor
            selectedCell.textView?.font = selectedCell.textView?.font
        }

        return true
    }

    open func collectionView(
        _ collectionView: UICollectionView, canPerformAction action: Selector,
        forItemAt indexPath: IndexPath, withSender sender: Any?
    ) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy(_:))
            || action == Selector("delete:")
    }

    open func collectionView(
        _ collectionView: UICollectionView, performAction action: Selector,
        forItemAt indexPath: IndexPath, withSender sender: Any?
    ) {
        guard let customCollectionView = collectionView as? JSQMessagesCollectionView else {
            return
        }

        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            guard
                let messageData = customCollectionView.messagesDataSource?.collectionView(
                    customCollectionView, messageDataForItemAt: indexPath)
            else { return }

            if messageData.isMediaMessage {
                if let mediaData = messageData.media as? JSQMessageMediaData,
                    let data = mediaData.mediaData?(),
                    let type = mediaData.mediaDataType?()
                {
                    UIPasteboard.general.setValue(data, forPasteboardType: type)
                }
            } else {
                UIPasteboard.general.string = messageData.text as? String
            }
        } else if action == Selector("delete:") {
            customCollectionView.messagesDataSource?.collectionView(
                customCollectionView, didDeleteMessageAt: indexPath)
            customCollectionView.deleteItems(at: [indexPath])
            customCollectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - JSQMessages Input Toolbar Delegate

    open func messagesInputToolbar(
        _ toolbar: JSQMessagesInputToolbar, didPressLeftBarButton sender: UIButton
    ) {
        if toolbar.sendButtonLocation == .left {
            didPressSendButton(
                sender, withMessageText: jsq_currentlyComposedMessageText(),
                senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date())
        } else {
            didPressAccessoryButton(sender)
        }
    }

    open func messagesInputToolbar(
        _ toolbar: JSQMessagesInputToolbar, didPressRightBarButton sender: UIButton
    ) {
        if toolbar.sendButtonLocation == .right {
            didPressSendButton(
                sender, withMessageText: jsq_currentlyComposedMessageText(),
                senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date())
        } else {
            didPressAccessoryButton(sender)
        }
    }

    private func jsq_currentlyComposedMessageText() -> String {
        inputToolbar.contentView.textView?.inputDelegate?.selectionWillChange(
            inputToolbar.contentView.textView!)
        inputToolbar.contentView.textView?.inputDelegate?.selectionDidChange(
            inputToolbar.contentView.textView!)
        return inputToolbar.contentView.textView?.text.jsq_stringByTrimingWhitespace() ?? ""
    }

    // MARK: - TextView Delegate

    open func textViewDidBeginEditing(_ textView: UITextView) {
        if textView != inputToolbar.contentView.textView { return }
        textView.becomeFirstResponder()
        if automaticallyScrollsToMostRecentMessage {
            scrollToBottom(animated: true)
        }
    }

    open func textViewDidChange(_ textView: UITextView) {
        if textView != inputToolbar.contentView.textView { return }
    }

    open func textViewDidEndEditing(_ textView: UITextView) {
        if textView != inputToolbar.contentView.textView { return }
        textView.resignFirstResponder()
    }

    // MARK: - Notifications

    private func jsq_registerForNotifications(_ register: Bool) {
        if register {
            let center = NotificationCenter.default

            // Keyboard
            let keyboardToken = center.addObserver(
                forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil,
                using: { [weak self] notification in
                    self?.jsq_didReceiveKeyboardWillChangeFrameNotification(notification)
                })
            notificationTokens.append(keyboardToken)

            // Menu Show
            let menuShowToken = center.addObserver(
                forName: UIMenuController.willShowMenuNotification, object: nil, queue: nil,
                using: { [weak self] notification in
                    self?.jsq_didReceiveMenuWillShowNotification(notification)
                })
            notificationTokens.append(menuShowToken)

            // Menu Hide
            let menuHideToken = center.addObserver(
                forName: UIMenuController.willHideMenuNotification, object: nil, queue: nil,
                using: { [weak self] notification in
                    self?.jsq_didReceiveMenuWillHideNotification(notification)
                })
            notificationTokens.append(menuHideToken)

            // Content Size
            let contentResultToken = center.addObserver(
                forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: nil,
                using: { [weak self] notification in
                    self?.jsq_preferredContentSizeChanged(notification)
                })
            notificationTokens.append(contentResultToken)
        } else {
            notificationTokens.forEach { NotificationCenter.default.removeObserver($0) }
            notificationTokens.removeAll()
        }
    }

    private func jsq_didReceiveKeyboardWillChangeFrameNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
                .cgRectValue
        else { return }

        if keyboardEndFrame.isNull { return }

        let animationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? 0
        let animationDuration =
            (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.0

        UIView.animate(
            withDuration: animationDuration, delay: 0.0,
            options: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16)),
            animations: {
                self.jsq_setCollectionViewInsetsTopValue(
                    self.additionalContentInset.top,
                    bottomValue: keyboardEndFrame.height + self.additionalContentInset.bottom)
            }, completion: nil)
    }

    private func jsq_didReceiveMenuWillShowNotification(_ notification: Notification) {
        if jsq_isHandlingMenuShow { return }

        guard let selectedIndexPath = selectedIndexPathForMenu,
            let menu = notification.object as? UIMenuController
        else { return }

        // Logic handled by flag instead of remove/add observer
        jsq_isHandlingMenuShow = true
        menu.setMenuVisible(false, animated: false)

        if let selectedCell = collectionView.cellForItem(at: selectedIndexPath)
            as? JSQMessagesCollectionViewCell
        {
            let selectedCellMessageBubbleFrame = selectedCell.convert(
                selectedCell.messageBubbleContainerView.frame, to: self.view)
            menu.setTargetRect(selectedCellMessageBubbleFrame, in: self.view)
            menu.setMenuVisible(true, animated: true)
        }
        jsq_isHandlingMenuShow = false
    }

    private func jsq_didReceiveMenuWillHideNotification(_ notification: Notification) {
        guard let selectedIndexPath = selectedIndexPathForMenu else { return }

        if let selectedCell = collectionView.cellForItem(at: selectedIndexPath)
            as? JSQMessagesCollectionViewCell
        {
            selectedCell.textView?.isSelectable = true
        }
        selectedIndexPathForMenu = nil
    }

    private func jsq_preferredContentSizeChanged(_ notification: Notification) {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setNeedsLayout()
    }

    private func jsq_updateCollectionViewInsets() {
        let top = additionalContentInset.top
        let bottom =
            collectionView.frame.maxY - inputToolbar.frame.minY + additionalContentInset.bottom
        jsq_setCollectionViewInsetsTopValue(top, bottomValue: bottom)
    }

    private func jsq_setCollectionViewInsetsTopValue(_ top: CGFloat, bottomValue bottom: CGFloat) {
        // Using safeAreaInsets if available or topLayoutGuide
        // Actually, ObjC used topLayoutGuide.length.
        // In iOS 11+, use use safeAreaInsets.

        if #available(iOS 11.0, *) {
            // For iOS 11, handled by safe area?
            // But existing logic was explicit.
            // topLayoutGuide.length + top.
            let topGuide = self.view.safeAreaInsets.top
            let adjustedInsets = UIEdgeInsets(
                top: topGuide + top, left: 0, bottom: bottom, right: 0)
            collectionView.contentInset = adjustedInsets
            collectionView.scrollIndicatorInsets = adjustedInsets
        } else {
            // Fallback
            let topGuide = self.topLayoutGuide.length
            let adjustedInsets = UIEdgeInsets(
                top: topGuide + top, left: 0, bottom: bottom, right: 0)
            collectionView.contentInset = adjustedInsets
            collectionView.scrollIndicatorInsets = adjustedInsets
        }
    }

    private func jsq_isMenuVisible() -> Bool {
        return selectedIndexPathForMenu != nil && UIMenuController.shared.isMenuVisible
    }
}
