import UIKit

/// `JSQMessagesToolbarButtonFactory` is a factory that provides a means for creating the default
/// toolbar button items to be displayed in the content view of a `JSQMessagesInputToolbar`.
public class JSQMessagesToolbarButtonFactory: NSObject {

    private let buttonFont: UIFont

    /**
     *  Creates and returns a new instance of `JSQMessagesToolbarButtonFactory` that uses
     *  the default font for creating buttons.
     *
     *  - returns: An initialized `JSQMessagesToolbarButtonFactory` object.
     */
    public override convenience init() {
        self.init(font: UIFont.preferredFont(forTextStyle: .headline))
    }

    /**
     *  Creates and returns a new instance of `JSQMessagesToolbarButtonFactory` that uses
     *  the specified font for creating buttons.
     *
     *  - parameter font: The font that will be used for the buttons produced by the factory.
     *
     *  - returns: An initialized `JSQMessagesToolbarButtonFactory` object.
     */
    public init(font: UIFont) {
        self.buttonFont = font
        super.init()
    }

    /**
     *  Creates and returns a new button that is styled as the default accessory button.
     *  The button has a paper clip icon image and no text.
     *
     *  - returns: A newly created button.
     */
    public func defaultAccessoryButtonItem() -> UIButton {
        let accessoryImage = UIImage.jsq_defaultAccessory() ?? UIImage()
        let normalImage = accessoryImage.jsq_imageMasked(with: UIColor.lightGray)
        let highlightedImage = accessoryImage.jsq_imageMasked(with: UIColor.darkGray)

        let accessoryButton = UIButton(
            frame: CGRect(x: 0.0, y: 0.0, width: accessoryImage.size.width, height: 32.0))
        accessoryButton.setImage(normalImage, for: .normal)
        accessoryButton.setImage(highlightedImage, for: .highlighted)

        accessoryButton.contentMode = .scaleAspectFit
        accessoryButton.backgroundColor = UIColor.clear
        accessoryButton.tintColor = UIColor.lightGray
        accessoryButton.titleLabel?.font = self.buttonFont

        accessoryButton.accessibilityLabel = Bundle.jsq_localizedString(
            forKey: "accessory_button_accessibility_label")

        return accessoryButton
    }

    /**
     *  Creates and returns a new button that is styled as the default send button.
     *  The button has title text `@"Send"` and no image.
     *
     *  - returns: A newly created button.
     */
    public func defaultSendButtonItem() -> UIButton {
        let sendTitle = Bundle.jsq_localizedString(forKey: "send")

        let sendButton = UIButton(frame: .zero)
        sendButton.setTitle(sendTitle, for: .normal)
        sendButton.setTitleColor(UIColor.jsq_messageBubbleBlue(), for: .normal)
        sendButton.setTitleColor(
            UIColor.jsq_messageBubbleBlue().jsq_colorByDarkeningColor(withValue: 0.1),
            for: .highlighted)
        sendButton.setTitleColor(UIColor.lightGray, for: .disabled)

        sendButton.titleLabel?.font = self.buttonFont
        sendButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sendButton.titleLabel?.minimumScaleFactor = 0.85
        sendButton.contentMode = .center
        sendButton.backgroundColor = UIColor.clear
        sendButton.tintColor = UIColor.jsq_messageBubbleBlue()

        let maxHeight: CGFloat = 32.0

        let attributes: [NSAttributedString.Key: Any] = [.font: sendButton.titleLabel!.font!]
        let sendTitleRect = sendTitle.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: maxHeight),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil)

        sendButton.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: sendTitleRect.integral.width,
            height: maxHeight)

        return sendButton
    }
}
