import UIKit

public let kJSQMessagesToolbarContentViewHorizontalSpacingDefault: CGFloat = 8.0

/// A `JSQMessagesToolbarContentView` represents the content displayed in a `JSQMessagesInputToolbar`.
/// These subviews consist of a left button, a text view, and a right button. One button is used as
/// the send button, and the other as the accessory button. The text view is used for composing messages.
@objc(JSQMessagesToolbarContentView)
public class JSQMessagesToolbarContentView: UIView {

    /**
     *  Returns the text view in which the user composes a message.
     */
    @IBOutlet public weak var textView: JSQMessagesComposerTextView?

    /**
     *  A custom button item displayed on the left of the toolbar content view.
     *
     *  - Discussion: The frame height of this button is ignored. When you set this property, the button
     *  is fitted within a pre-defined default content view, the leftBarButtonContainerView,
     *  whose height is determined by the height of the toolbar. However, the width of this button
     *  will be preserved. You may specify a new width using `leftBarButtonItemWidth`.
     *  If the frame of this button is equal to `CGRectZero` when set, then a default frame size will be used.
     *  Set this value to `nil` to remove the button.
     */
    @objc dynamic public var leftBarButtonItem: UIButton? {
        willSet {
            if let oldItem = leftBarButtonItem {
                oldItem.removeFromSuperview()
            }
        }
        didSet {
            guard let leftBarButtonItem = leftBarButtonItem else {
                leftHorizontalSpacingConstraint.constant = 0.0
                leftBarButtonItemWidth = 0.0
                leftBarButtonContainerView.isHidden = true
                return
            }

            if leftBarButtonItem.frame == .zero {
                leftBarButtonItem.frame = leftBarButtonContainerView.bounds
            }

            leftBarButtonContainerView.isHidden = false
            leftHorizontalSpacingConstraint.constant =
                kJSQMessagesToolbarContentViewHorizontalSpacingDefault
            leftBarButtonItemWidth = leftBarButtonItem.frame.width

            leftBarButtonItem.translatesAutoresizingMaskIntoConstraints = false
            leftBarButtonContainerView.addSubview(leftBarButtonItem)
            leftBarButtonContainerView.jsq_pinAllEdgesOfSubview(leftBarButtonItem)
            self.setNeedsUpdateConstraints()
        }
    }

    /**
     *  Specifies the width of the leftBarButtonItem.
     *
     *  - Discussion: This property modifies the width of the leftBarButtonContainerView.
     */
    public var leftBarButtonItemWidth: CGFloat {
        get {
            return leftBarButtonContainerViewWidthConstraint.constant
        }
        set {
            leftBarButtonContainerViewWidthConstraint.constant = newValue
            self.setNeedsUpdateConstraints()
        }
    }

    /**
     *  Specifies the amount of spacing between the content view and the leading edge of leftBarButtonItem.
     *
     *  - Discussion: The default value is `8.0f`.
     */
    public var leftContentPadding: CGFloat {
        get {
            return leftHorizontalSpacingConstraint.constant
        }
        set {
            leftHorizontalSpacingConstraint.constant = newValue
            self.setNeedsUpdateConstraints()
        }
    }

    /**
     *  The container view for the leftBarButtonItem.
     *
     *  - Discussion:
     *  You may use this property to add additional button items to the left side of the toolbar content view.
     *  However, you will be completely responsible for responding to all touch events for these buttons
     *  in your `JSQMessagesViewController` subclass.
     */
    @IBOutlet public weak var leftBarButtonContainerView: UIView!
    @IBOutlet private weak var leftBarButtonContainerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leftHorizontalSpacingConstraint: NSLayoutConstraint!

    /**
     *  A custom button item displayed on the right of the toolbar content view.
     *
     *  - Discussion: The frame height of this button is ignored. When you set this property, the button
     *  is fitted within a pre-defined default content view, the rightBarButtonContainerView,
     *  whose height is determined by the height of the toolbar. However, the width of this button
     *  will be preserved. You may specify a new width using `rightBarButtonItemWidth`.
     *  If the frame of this button is equal to `CGRectZero` when set, then a default frame size will be used.
     *  Set this value to `nil` to remove the button.
     */
    @objc dynamic public var rightBarButtonItem: UIButton? {
        willSet {
            if let oldItem = rightBarButtonItem {
                oldItem.removeFromSuperview()
            }
        }
        didSet {
            guard let rightBarButtonItem = rightBarButtonItem else {
                rightHorizontalSpacingConstraint.constant = 0.0
                rightBarButtonItemWidth = 0.0
                rightBarButtonContainerView.isHidden = true
                return
            }

            if rightBarButtonItem.frame == .zero {
                rightBarButtonItem.frame = rightBarButtonContainerView.bounds
            }

            rightBarButtonContainerView.isHidden = false
            rightHorizontalSpacingConstraint.constant =
                kJSQMessagesToolbarContentViewHorizontalSpacingDefault
            rightBarButtonItemWidth = rightBarButtonItem.frame.width

            rightBarButtonItem.translatesAutoresizingMaskIntoConstraints = false
            rightBarButtonContainerView.addSubview(rightBarButtonItem)
            rightBarButtonContainerView.jsq_pinAllEdgesOfSubview(rightBarButtonItem)
            self.setNeedsUpdateConstraints()
        }
    }

    /**
     *  Specifies the width of the rightBarButtonItem.
     *
     *  - Discussion: This property modifies the width of the rightBarButtonContainerView.
     */
    public var rightBarButtonItemWidth: CGFloat {
        get {
            return rightBarButtonContainerViewWidthConstraint.constant
        }
        set {
            rightBarButtonContainerViewWidthConstraint.constant = newValue
            self.setNeedsUpdateConstraints()
        }
    }

    /**
     *  Specifies the amount of spacing between the content view and the trailing edge of rightBarButtonItem.
     *
     *  - Discussion: The default value is `8.0f`.
     */
    public var rightContentPadding: CGFloat {
        get {
            return rightHorizontalSpacingConstraint.constant
        }
        set {
            rightHorizontalSpacingConstraint.constant = newValue
            self.setNeedsUpdateConstraints()
        }
    }

    /**
     *  The container view for the rightBarButtonItem.
     *
     *  - Discussion:
     *  You may use this property to add additional button items to the right side of the toolbar content view.
     *  However, you will be completely responsible for responding to all touch events for these buttons
     *  in your `JSQMessagesViewController` subclass.
     */
    @IBOutlet public weak var rightBarButtonContainerView: UIView!
    @IBOutlet private weak var rightBarButtonContainerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightHorizontalSpacingConstraint: NSLayoutConstraint!

    // MARK: - Class methods

    /**
     *  Returns the `UINib` object initialized for a `JSQMessagesToolbarContentView`.
     *
     *  - returns: The initialized `UINib` object.
     */
    public class func nib() -> UINib {
        return UINib(nibName: NSStringFromClass(self), bundle: Bundle(for: self))
    }

    // MARK: - Initialization

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.translatesAutoresizingMaskIntoConstraints = false

        self.leftHorizontalSpacingConstraint.constant =
            kJSQMessagesToolbarContentViewHorizontalSpacingDefault
        self.rightHorizontalSpacingConstraint.constant =
            kJSQMessagesToolbarContentViewHorizontalSpacingDefault

        self.backgroundColor = .clear
    }

    public override var backgroundColor: UIColor? {
        didSet {
            leftBarButtonContainerView?.backgroundColor = backgroundColor
            rightBarButtonContainerView?.backgroundColor = backgroundColor
        }
    }

    public override func setNeedsDisplay() {
        super.setNeedsDisplay()
        textView?.setNeedsDisplay()
    }
}
