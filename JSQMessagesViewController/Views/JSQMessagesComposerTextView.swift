import UIKit

/// A delegate object used to notify the receiver of paste events from a `JSQMessagesComposerTextView`.
@objc public protocol JSQMessagesComposerTextViewPasteDelegate: NSObjectProtocol {

    /**
     *  Asks the delegate whether or not the `textView` should use the original implementation of `-[UITextView paste]`.
     *
     *  - Discussion: Use this delegate method to implement custom pasting behavior.
     *  You should return `false` when you want to handle pasting.
     *  Return `true` to defer functionality to the `textView`.
     */
    func composerTextView(
        _ textView: JSQMessagesComposerTextView, shouldPasteWithSender sender: Any?
    ) -> Bool
}

/// An instance of `JSQMessagesComposerTextView` is a subclass of `UITextView` that is styled and used
/// for composing messages in a `JSQMessagesViewController`. It is a subview of a `JSQMessagesToolbarContentView`.
@objc public class JSQMessagesComposerTextView: UITextView {

    /**
     *  The text to be displayed when the text view is empty. The default value is `nil`.
     */
    @objc public var placeHolder: String? {
        didSet {
            if placeHolder != oldValue {
                self.setNeedsDisplay()
            }
        }
    }

    /**
     *  The color of the place holder text. The default value is `[UIColor lightGrayColor]`.
     */
    @objc public var placeHolderTextColor: UIColor = .lightGray {
        didSet {
            if placeHolderTextColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }

    /**
     *  The insets to be used when the placeholder is drawn. The default value is `UIEdgeInsets(5.0, 7.0, 5.0, 7.0)`.
     */
    @objc public var placeHolderInsets: UIEdgeInsets = UIEdgeInsets(
        top: 5.0, left: 7.0, bottom: 5.0, right: 7.0)
    {
        didSet {
            if placeHolderInsets != oldValue {
                self.setNeedsDisplay()
            }
        }
    }

    /**
     *  The object that acts as the paste delegate of the text view.
     */
    @objc public weak var composerPasteDelegate: JSQMessagesComposerTextViewPasteDelegate?

    public override func paste(_ sender: Any?) {
        if let delegate = composerPasteDelegate,
            delegate.composerTextView(self, shouldPasteWithSender: sender)
        {
            return
        }
        super.paste(sender)
    }

    /**
     *  Determines whether or not the text view contains text after trimming white space
     *  from the front and back of its string.
     *
     *  - returns: `true` if the text view contains text, `false` otherwise.
     */
    @objc public override var hasText: Bool {
        return (self.text.jsq_stringByTrimingWhitespace().count > 0)
    }

    private weak var heightConstraint: NSLayoutConstraint?
    private weak var minHeightConstraint: NSLayoutConstraint?
    private weak var maxHeightConstraint: NSLayoutConstraint?

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        jsq_configureTextView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        jsq_configureTextView()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        jsq_configureTextView()
    }

    deinit {
        jsq_removeTextViewNotificationObservers()
    }

    private func jsq_configureTextView() {
        self.translatesAutoresizingMaskIntoConstraints = false

        let cornerRadius: CGFloat = 6.0

        self.backgroundColor = .white
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = cornerRadius

        self.scrollIndicatorInsets = UIEdgeInsets(
            top: cornerRadius, left: 0.0, bottom: cornerRadius, right: 0.0)

        self.textContainerInset = UIEdgeInsets(top: 4.0, left: 2.0, bottom: 4.0, right: 2.0)
        self.contentInset = UIEdgeInsets(top: 1.0, left: 0.0, bottom: 1.0, right: 0.0)

        self.isScrollEnabled = true
        self.scrollsToTop = false
        self.isUserInteractionEnabled = true

        self.font = UIFont.preferredFont(forTextStyle: .body)
        self.textColor = .black
        self.textAlignment = .natural

        self.contentMode = .redraw
        self.dataDetectorTypes = []
        self.keyboardAppearance = .default
        self.keyboardType = .default
        self.returnKeyType = .default

        self.text = nil

        associateConstraints()
        jsq_addTextViewNotificationObservers()
    }

    private func associateConstraints() {
        // iterate through all text view's constraints and identify
        // height, max height and min height constraints.

        for constraint in self.constraints {
            if constraint.firstAttribute == .height {
                if constraint.relation == .equal {
                    self.heightConstraint = constraint
                } else if constraint.relation == .lessThanOrEqual {
                    self.maxHeightConstraint = constraint
                } else if constraint.relation == .greaterThanOrEqual {
                    self.minHeightConstraint = constraint
                }
            }
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        // calculate size needed for the text to be visible without scrolling
        let sizeThatFits = self.sizeThatFits(self.frame.size)
        var newHeight = sizeThatFits.height

        // if there is any minimal height constraint set, make sure we consider that
        if let maxHeightConstraint = maxHeightConstraint {
            newHeight = min(newHeight, maxHeightConstraint.constant)
        }

        // if there is any maximal height constraint set, make sure we consider that
        if let minHeightConstraint = minHeightConstraint {
            newHeight = max(newHeight, minHeightConstraint.constant)
        }

        // update the height constraint
        self.heightConstraint?.constant = newHeight
    }

    // MARK: - UITextView overrides

    public override var bounds: CGRect {
        didSet {
            if self.contentSize.height <= self.bounds.size.height + 1 {
                self.contentOffset = .zero
            }
        }
    }

    public override var text: String! {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public override var attributedText: NSAttributedString! {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public override var font: UIFont? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public override var textAlignment: NSTextAlignment {
        didSet {
            self.setNeedsDisplay()
        }
    }

    // MARK: - Drawing

    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        if self.text.isEmpty && placeHolder != nil {
            placeHolderTextColor.set()

            (placeHolder! as NSString).draw(
                in: rect.inset(by: placeHolderInsets),
                withAttributes: jsq_placeholderTextAttributes())
        }
    }

    // MARK: - Notifications

    private func jsq_addTextViewNotificationObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(jsq_didReceiveTextViewNotification(_:)),
            name: UITextView.textDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(
            self, selector: #selector(jsq_didReceiveTextViewNotification(_:)),
            name: UITextView.textDidBeginEditingNotification, object: self)
        NotificationCenter.default.addObserver(
            self, selector: #selector(jsq_didReceiveTextViewNotification(_:)),
            name: UITextView.textDidEndEditingNotification, object: self)
    }

    private func jsq_removeTextViewNotificationObservers() {
        NotificationCenter.default.removeObserver(
            self, name: UITextView.textDidChangeNotification, object: self)
        NotificationCenter.default.removeObserver(
            self, name: UITextView.textDidBeginEditingNotification, object: self)
        NotificationCenter.default.removeObserver(
            self, name: UITextView.textDidEndEditingNotification, object: self)
    }

    @objc private func jsq_didReceiveTextViewNotification(_ notification: Notification) {
        self.setNeedsDisplay()
    }

    // MARK: - Utilities

    private func jsq_placeholderTextAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = self.textAlignment

        return [
            .font: self.font ?? UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: self.placeHolderTextColor,
            .paragraphStyle: paragraphStyle,
        ]
    }

    // MARK: - UIMenuController

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        UIMenuController.shared.menuItems = nil
        return super.canPerformAction(action, withSender: sender)
    }
}
