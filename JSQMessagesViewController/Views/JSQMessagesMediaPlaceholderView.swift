import UIKit

/// A `JSQMessagesMediaPlaceholderView` object represents a loading or placeholder
/// view for media message objects whose media attachments are not yet available.
/// When sending or receiving media messages that must be uploaded or downloaded from the network,
/// you may display this view temporarily until the media attachement is available.
/// You should return an instance of this class from the `mediaPlaceholderView` method in
/// the `JSQMessageMediaData` protocol.
public class JSQMessagesMediaPlaceholderView: UIView {

    /**
     *  Returns the activity indicator view for this placeholder view, or `nil` if it does not exist.
     */
    public private(set) weak var activityIndicatorView: UIActivityIndicatorView?

    /**
     *  Returns the image view for this placeholder view, or `nil` if it does not exist.
     */
    public private(set) weak var imageView: UIImageView?

    /**
     *  Creates a media placeholder view object with a light gray background and
     *  a centered activity indicator.
     *
     *  - Discussion: When initializing a `JSQMessagesMediaPlaceholderView` with this method,
     *  its imageView property will be nil.
     *
     *  - returns: An initialized `JSQMessagesMediaPlaceholderView` object.
     */
    public class func viewWithActivityIndicator() -> JSQMessagesMediaPlaceholderView {
        let lightGrayColor = UIColor.jsq_messageBubbleLightGray()
        // Define style based on iOS version if needed, but .white is deprecated in recent iOS versions for .medium or .large, but .white is still available or mapped.
        // Assuming iOS 13+, UIActivityIndicatorViewStyleWhite is deprecated. Use .medium or .large.
        // But for compatibility with old style, let's use .medium if available (iOS 13+).
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .medium
        } else {
            style = .white
        }

        let spinner = UIActivityIndicatorView(style: style)
        spinner.color = lightGrayColor.jsq_colorByDarkeningColor(withValue: 0.4)

        let view = JSQMessagesMediaPlaceholderView(
            frame: CGRect(x: 0, y: 0, width: 200, height: 120), backgroundColor: lightGrayColor,
            activityIndicatorView: spinner)
        return view
    }

    /**
     *  Creates a media placeholder view object with a light gray background and
     *  a centered paperclip attachment icon.
     *
     *  - Discussion: When initializing a `JSQMessagesMediaPlaceholderView` with this method,
     *  its activityIndicatorView property will be nil.
     *
     *  - returns: An initialized `JSQMessagesMediaPlaceholderView` object.
     */
    public class func viewWithAttachmentIcon() -> JSQMessagesMediaPlaceholderView {
        let lightGrayColor = UIColor.jsq_messageBubbleLightGray()
        let paperclip = UIImage.jsq_defaultAccessory()?.jsq_imageMasked(
            with: lightGrayColor.jsq_colorByDarkeningColor(withValue: 0.4))
        let imageView = UIImageView(image: paperclip)

        let view = JSQMessagesMediaPlaceholderView(
            frame: CGRect(x: 0, y: 0, width: 200, height: 120), backgroundColor: lightGrayColor,
            imageView: imageView)
        return view
    }

    /**
     *  Creates a media placeholder view having the given frame, backgroundColor, and activityIndicatorView.
     *
     *  - parameter frame:                 A rectangle defining the frame of the view. This value must be a non-zero, non-null rectangle.
     *  - parameter backgroundColor:       The background color of the view. This value must not be `nil`.
     *  - parameter activityIndicatorView: An initialized activity indicator to be added and centered in the view. This value must not be `nil`.
     *
     *  - returns: An initialized `JSQMessagesMediaPlaceholderView` object.
     */
    public init(
        frame: CGRect, backgroundColor: UIColor, activityIndicatorView: UIActivityIndicatorView
    ) {
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        self.isUserInteractionEnabled = false
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill

        self.addSubview(activityIndicatorView)
        self.activityIndicatorView = activityIndicatorView
        activityIndicatorView.center = self.center
        activityIndicatorView.startAnimating()
    }

    /**
     *  Creates a media placeholder view having the given frame, backgroundColor, and imageView.
     *
     *  - parameter frame:           A rectangle defining the frame of the view. This value must be a non-zero, non-null rectangle.
     *  - parameter backgroundColor: The background color of the view. This value must not be `nil`.
     *  - parameter imageView:       An initialized image view to be added and centered in the view. This value must not be `nil`.
     *
     *  - returns: An initialized `JSQMessagesMediaPlaceholderView` object.
     */
    public init(frame: CGRect, backgroundColor: UIColor, imageView: UIImageView) {
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        self.isUserInteractionEnabled = false
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill

        self.addSubview(imageView)
        self.imageView = imageView
        imageView.center = self.center
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if let activityIndicatorView = activityIndicatorView {
            activityIndicatorView.center = self.center
        } else if let imageView = imageView {
            imageView.center = self.center
        }
    }
}
