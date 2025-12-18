import UIKit

@objc public class JSQMessagesTypingView: UIView {

    @objc public var dotsColor: UIColor = .lightGray {
        didSet {
            dot?.fillColor = dotsColor.cgColor
            updateAnimation()
        }
    }

    @objc public var animateToColor: UIColor = .gray {
        didSet {
            updateAnimation()
        }
    }

    @objc public var animationDuration: CGFloat = 1.33

    @objc public var isAnimated: Bool = false {
        didSet {
            updateAnimation()
        }
    }

    private var dot: CAShapeLayer?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.isAnimated = false
        self.animationDuration = 1.33
        self.dotsColor = .lightGray
        self.animateToColor = .gray

        let dotDimension = self.frame.size.width / 7.125
        let firstDotCenterX = 2 * self.frame.size.width / 7
        let intervalBetweenDotsOnXAxis = 3.0 * self.frame.size.width / 14.0

        let container = CAReplicatorLayer()
        container.position = CGPoint(
            x: self.layer.bounds.size.width / 2.0, y: self.layer.bounds.size.height / 2.0)
        container.bounds = CGRect(
            x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        container.instanceCount = 3
        container.instanceTransform = CATransform3DMakeTranslation(
            intervalBetweenDotsOnXAxis, 0.0, 0.0)
        container.instanceDelay = CFTimeInterval(self.animationDuration / 7.0)

        let dot = CAShapeLayer()
        dot.position = CGPoint(x: firstDotCenterX, y: container.bounds.size.height / 2.0)
        dot.bounds = CGRect(x: 0, y: 0, width: dotDimension, height: dotDimension)
        dot.path = UIBezierPath(ovalIn: dot.bounds).cgPath
        dot.fillColor = self.dotsColor.cgColor
        self.dot = dot

        container.addSublayer(dot)
        self.layer.addSublayer(container)

        updateAnimation()
    }

    private func updateAnimation() {
        dot?.removeAnimation(forKey: "darkening")

        if isAnimated {
            dot?.add(fillColorAnimation(), forKey: "darkening")
        }
    }

    private func fillColorAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "fillColor")
        animation.values = [
            self.dotsColor.cgColor,
            self.dotsColor.cgColor,
            self.animateToColor.cgColor,
            self.dotsColor.cgColor,
            self.dotsColor.cgColor,
        ]
        animation.keyTimes = [0, 2 / 7.0, 1 / 2.0, 5 / 7.0, 1] as [NSNumber]
        animation.duration = CFTimeInterval(self.animationDuration)
        animation.repeatCount = .infinity
        animation.autoreverses = true
        return animation
    }
}
