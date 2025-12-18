import UIKit

@objc public enum JSQMessagesInputSendButtonLocation: UInt {
    case none
    case right
    case left
}

/// The `JSQMessagesInputToolbarDelegate` protocol defines methods for interacting with
/// a `JSQMessagesInputToolbar` object.
@objc public protocol JSQMessagesInputToolbarDelegate: UIToolbarDelegate {

    /**
     *  Tells the delegate that the toolbar's `rightBarButtonItem` has been pressed.
     *
     *  - parameter toolbar: The object representing the toolbar sending this information.
     *  - parameter sender:  The button that received the touch event.
     */
    func messagesInputToolbar(
        _ toolbar: JSQMessagesInputToolbar, didPressRightBarButton sender: UIButton)

    /**
     *  Tells the delegate that the toolbar's `leftBarButtonItem` has been pressed.
     *
     *  - parameter toolbar: The object representing the toolbar sending this information.
     *  - parameter sender:  The button that received the touch event.
     */
    func messagesInputToolbar(
        _ toolbar: JSQMessagesInputToolbar, didPressLeftBarButton sender: UIButton)
}

/// An instance of `JSQMessagesInputToolbar` defines the input toolbar for
/// composing a new message. It is displayed above and follow the movement of the system keyboard.
@objc public class JSQMessagesInputToolbar: UIToolbar {

    /**
     *  The object that acts as the delegate of the toolbar.
     */
    // Ignoring the warning about hiding inherited delegate for now, as we want to refine the protocol
    @objc public weak var messagesToolbarDelegate: (any JSQMessagesInputToolbarDelegate)?

    /**
     *  Returns the content view of the toolbar. This view contains all subviews of the toolbar.
     */
    @objc public private(set) weak var contentView: JSQMessagesToolbarContentView!

    /**
     *  Indicates the location of the send button in the toolbar.
     *
     *  - Discussion: The default value is `JSQMessagesInputSendButtonLocation.right`, which indicates that the send button is the right-most subview of
     *  the toolbar's `contentView`. Set to `JSQMessagesInputSendButtonLocation.left` to specify that the send button is on the left. Set to 'JSQMessagesInputSendButtonLocation.none' if there is no send button or if you want to take control of the send button actions. This
     *  property is used to determine which touch events correspond to which actions.
     *
     *  - Warning: Note, this property *does not* change the positions of buttons in the toolbar's content view.
     *  It only specifies whether the `rightBarButtonItem` or the `leftBarButtonItem` is the send button or there is no send button.
     *  The other button then acts as the accessory button.
     */
    @objc public var sendButtonLocation: JSQMessagesInputSendButtonLocation = .right {
        didSet {
            updateSendButtonEnabledState()
        }
    }

    /**
     *  Specify if the send button should be enabled automatically when the `textView` contains text.
     *  The default value is `true`.
     *
     *  - Discussion: If `true`, the send button will be enabled if the `textView` contains text. Otherwise,
     *  you are responsible for determining when to enable/disable the send button.
     */
    @objc public var enablesSendButtonAutomatically: Bool = true {
        didSet {
            updateSendButtonEnabledState()
        }
    }

    /**
     *  Specifies the default (minimum) height for the toolbar. The default value is `44.0f`. This value must be positive.
     */
    @objc public var preferredDefaultHeight: CGFloat = 44.0

    /**
     *  Specifies the maximum height for the toolbar. The default value is `NSNotFound`, which specifies no maximum height.
     */
    @objc public var maximumHeight: UInt = UInt(NSNotFound)

    private var jsq_isObserving: Bool = false

    // MARK: - Initialization

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        self.jsq_isObserving = false
        self.sendButtonLocation = .right
        self.enablesSendButtonAutomatically = true
        self.preferredDefaultHeight = 44.0
        self.maximumHeight = UInt(NSNotFound)

        let toolbarContentView = loadToolbarContentView()
        toolbarContentView.frame = self.frame
        self.addSubview(toolbarContentView)
        self.jsq_pinAllEdgesOfSubview(toolbarContentView)
        self.setNeedsUpdateConstraints()
        self.contentView = toolbarContentView

        jsq_addObservers()

        let toolbarButtonFactory = JSQMessagesToolbarButtonFactory(
            font: UIFont.preferredFont(forTextStyle: .headline))
        self.contentView.leftBarButtonItem = toolbarButtonFactory.defaultAccessoryButtonItem()
        self.contentView.rightBarButtonItem = toolbarButtonFactory.defaultSendButtonItem()

        updateSendButtonEnabledState()

        NotificationCenter.default.addObserver(
            self, selector: #selector(textViewTextDidChangeNotification(_:)),
            name: UITextView.textDidChangeNotification, object: self.contentView.textView)
    }

    /**
     *  Loads the content view for the toolbar.
     *
     *  - Discussion: Override this method to provide a custom content view for the toolbar.
     *
     *  - returns: An initialized `JSQMessagesToolbarContentView`.
     */
    @objc open func loadToolbarContentView() -> JSQMessagesToolbarContentView {
        let nibArgs = Bundle(for: JSQMessagesInputToolbar.self).loadNibNamed(
            NSStringFromClass(JSQMessagesToolbarContentView.self), owner: nil, options: nil)
        return nibArgs!.first as! JSQMessagesToolbarContentView
    }

    deinit {
        jsq_removeObservers()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions

    @objc func jsq_leftBarButtonPressed(_ sender: UIButton) {
        messagesToolbarDelegate?.messagesInputToolbar(self, didPressLeftBarButton: sender)
    }

    @objc func jsq_rightBarButtonPressed(_ sender: UIButton) {
        messagesToolbarDelegate?.messagesInputToolbar(self, didPressRightBarButton: sender)
    }

    // MARK: - Input toolbar

    private func updateSendButtonEnabledState() {
        guard contentView != nil else {
            // contentView not loaded yet during initialization
            return
        }

        if !enablesSendButtonAutomatically {
            return
        }

        let enabled = contentView.textView?.hasText ?? false

        switch sendButtonLocation {
        case .right:
            contentView.rightBarButtonItem?.isEnabled = enabled
        case .left:
            contentView.leftBarButtonItem?.isEnabled = enabled
        case .none:
            break
        }
    }

    // MARK: - Notifications

    @objc func textViewTextDidChangeNotification(_ notification: Notification) {
        updateSendButtonEnabledState()
    }

    // MARK: - Key-value observing

    public override func observeValue(
        forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if context == &kJSQMessagesInputToolbarKeyValueObservingContext {
            if let contentView = object as? JSQMessagesToolbarContentView,
                contentView == self.contentView
            {
                if keyPath
                    == NSStringFromSelector(
                        #selector(getter: JSQMessagesToolbarContentView.leftBarButtonItem))
                {

                    self.contentView.leftBarButtonItem?.removeTarget(
                        self, action: nil, for: .touchUpInside)
                    self.contentView.leftBarButtonItem?.addTarget(
                        self, action: #selector(jsq_leftBarButtonPressed(_:)), for: .touchUpInside)

                } else if keyPath
                    == NSStringFromSelector(
                        #selector(getter: JSQMessagesToolbarContentView.rightBarButtonItem))
                {

                    self.contentView.rightBarButtonItem?.removeTarget(
                        self, action: nil, for: .touchUpInside)
                    self.contentView.rightBarButtonItem?.addTarget(
                        self, action: #selector(jsq_rightBarButtonPressed(_:)), for: .touchUpInside)
                }

                updateSendButtonEnabledState()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private var kJSQMessagesInputToolbarKeyValueObservingContext = 0

    private func jsq_addObservers() {
        if jsq_isObserving { return }

        // We use NSStringFromSelector to get the string compatible efficiently?
        // Actually just hardcoding or using #selector is better but #selector(getter:...) requires @objc property.
        // JSQMessagesToolbarContentView properties are @objc dynamic.

        self.contentView.addObserver(
            self, forKeyPath: "leftBarButtonItem", options: [],
            context: &kJSQMessagesInputToolbarKeyValueObservingContext)
        self.contentView.addObserver(
            self, forKeyPath: "rightBarButtonItem", options: [],
            context: &kJSQMessagesInputToolbarKeyValueObservingContext)

        jsq_isObserving = true
    }

    private func jsq_removeObservers() {
        if !jsq_isObserving { return }

        self.contentView.removeObserver(
            self, forKeyPath: "leftBarButtonItem",
            context: &kJSQMessagesInputToolbarKeyValueObservingContext)
        self.contentView.removeObserver(
            self, forKeyPath: "rightBarButtonItem",
            context: &kJSQMessagesInputToolbarKeyValueObservingContext)

        jsq_isObserving = false
    }

}
