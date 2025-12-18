import UIKit

/// `JSQMessagesCellTextView` is a subclass of `UITextView` that is used to display text
/// in a `JSQMessagesCollectionViewCell`.
@objc public class JSQMessagesCellTextView: UITextView {

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.textColor = .white
        self.isEditable = false
        self.isSelectable = true
        self.isUserInteractionEnabled = true
        self.dataDetectorTypes = []
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.isScrollEnabled = false
        self.backgroundColor = .clear
        self.contentInset = .zero
        self.scrollIndicatorInsets = .zero
        self.contentOffset = .zero
        self.textContainerInset = .zero
        self.textContainer.lineFragmentPadding = 0
        self.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
    }

    public override var selectedRange: NSRange {
        get {
            return NSRange(location: NSNotFound, length: NSNotFound)
        }
        set {
            // attempt to prevent selecting text
            super.selectedRange = NSRange(location: NSNotFound, length: 0)
        }
    }

    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer)
        -> Bool
    {
        // ignore double-tap to prevent copy/define/etc. menu from showing
        if let tap = gestureRecognizer as? UITapGestureRecognizer, tap.numberOfTapsRequired == 2 {
            return false
        }
        return true
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch
    ) -> Bool {
        // ignore double-tap to prevent copy/define/etc. menu from showing
        if let tap = gestureRecognizer as? UITapGestureRecognizer, tap.numberOfTapsRequired == 2 {
            return false
        }
        return true
    }

}
