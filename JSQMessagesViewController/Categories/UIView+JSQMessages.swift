import UIKit

extension UIView {

    /**
     *  Pins the subview of the receiver to the edge of its frame, as specified by the given attribute, by adding a layout constraint.
     *
     *  - parameter subview:   The subview to which the receiver will be pinned.
     *  - parameter attribute: The layout constraint attribute specifying one of `NSLayoutAttributeBottom`, `NSLayoutAttributeTop`, `NSLayoutAttributeLeading`, `NSLayoutAttributeTrailing`.
     */
    @objc public func jsq_pinSubview(
        _ subview: UIView, toEdge attribute: NSLayoutConstraint.Attribute
    ) {
        self.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: .equal,
                toItem: subview,
                attribute: attribute,
                multiplier: 1.0,
                constant: 0.0))
    }

    /**
     *  Pins all edges of the specified subview to the receiver.
     *
     *  - parameter subview: The subview to which the receiver will be pinned.
     */
    @objc public func jsq_pinAllEdgesOfSubview(_ subview: UIView) {
        self.jsq_pinSubview(subview, toEdge: .bottom)
        self.jsq_pinSubview(subview, toEdge: .top)
        self.jsq_pinSubview(subview, toEdge: .leading)
        self.jsq_pinSubview(subview, toEdge: .trailing)
    }
}
