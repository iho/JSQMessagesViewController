import UIKit

/// `JSQMessagesLabel` is a subclass of `UILabel` that adds support for a `textInsets` property,
/// which is similar to the `textContainerInset` property of `UITextView`.
public class JSQMessagesLabel: UILabel {

    /**
     *  The inset of the text layout area within the label's content area. The default value is `UIEdgeInsetsZero`.
     *
     *  - Discussion: This property provides text margins for the text laid out in the label.
     *  The inset values provided must be greater than or equal to `0.0`.
     */
    public var textInsets: UIEdgeInsets = .zero {
        didSet {
            if textInsets != oldValue {
                self.setNeedsDisplay()
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        jsq_configureLabel()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        jsq_configureLabel()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        jsq_configureLabel()
    }

    private func jsq_configureLabel() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textInsets = .zero
    }

    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}
