import UIKit

public let kJSQMessagesTypingIndicatorFooterViewHeight: CGFloat = 46.0

@objc(JSQMessagesTypingIndicatorFooterView)
public class JSQMessagesTypingIndicatorFooterView: UICollectionReusableView {

    @IBOutlet public weak var bubbleImageView: UIImageView!
    @IBOutlet private weak var bubbleImageViewRightHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet public weak var typingView: JSQMessagesTypingView!
    @IBOutlet private weak var typingIndicatorImageViewRightHorizontalConstraint:
        NSLayoutConstraint!
    @IBOutlet private weak var typingIndicatorToBubbleImageAlignConstraint: NSLayoutConstraint!

    // MARK: - Class methods

    @objc public class func nib() -> UINib {
        return UINib(nibName: NSStringFromClass(self), bundle: Bundle(for: self))
    }

    @objc public class func footerReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }

    // MARK: - Initialization

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
    }

    public override var backgroundColor: UIColor? {
        didSet {
            bubbleImageView?.backgroundColor = backgroundColor
        }
    }

    // MARK: - Typing indicator

    @objc public func configure(
        withEllipsisColor ellipsisColor: UIColor,
        messageBubbleColor: UIColor,
        animated: Bool,
        shouldDisplayOnLeft: Bool,
        for collectionView: UICollectionView
    ) {

        let bubbleMarginMinimumSpacing: CGFloat = 6.0
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()

        if shouldDisplayOnLeft {
            self.bubbleImageView.image =
                bubbleImageFactory.incomingMessagesBubbleImage(with: messageBubbleColor)
                .messageBubbleImage

            let collectionViewWidth = collectionView.frame.width
            let bubbleWidth = self.bubbleImageView.frame.width
            let bubbleMarginMaximumSpacing =
                collectionViewWidth - bubbleWidth - bubbleMarginMinimumSpacing

            self.bubbleImageViewRightHorizontalConstraint.constant = bubbleMarginMaximumSpacing
            self.typingIndicatorToBubbleImageAlignConstraint.constant = 0
        } else {
            self.bubbleImageView.image =
                bubbleImageFactory.outgoingMessagesBubbleImage(with: messageBubbleColor)
                .messageBubbleImage
            self.bubbleImageViewRightHorizontalConstraint.constant = bubbleMarginMinimumSpacing
            self.typingIndicatorToBubbleImageAlignConstraint.constant = 6
        }

        self.setNeedsUpdateConstraints()

        self.typingView.dotsColor = ellipsisColor
        self.typingView.animateToColor = ellipsisColor.jsq_colorByDarkeningColor(withValue: 0.2)
        self.typingView.isAnimated = animated
        self.typingView.animationDuration = 1.33

        if animated {
            let pulse = pulseAnimation()
            pulse.duration = CFTimeInterval(self.typingView.animationDuration * 2)
            self.bubbleImageView.layer.add(pulse, forKey: "pulsing")
        }
    }

    private func pulseAnimation() -> CAKeyframeAnimation {
        let pulseAnimation = CAKeyframeAnimation(keyPath: "transform")
        pulseAnimation.values = [
            NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.03, 0.97, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(0.97, 1.03, 1.0)),
            NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)),
        ]
        pulseAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.autoreverses = true
        return pulseAnimation
    }
}
