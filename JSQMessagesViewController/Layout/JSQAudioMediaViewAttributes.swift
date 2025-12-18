import AVFoundation
import UIKit

/// An instance of `JSQAudioMediaViewAttributes` specifies the appearance configuration of a `JSQAudioMediaItem`.
/// Use this class to customize the appearance of `JSQAudioMediaItem`.
@objc public class JSQAudioMediaViewAttributes: NSObject {

    /**
     *  The image for the play button. The default is a play icon.
     */
    @objc public var playButtonImage: UIImage

    /**
     *  The image for the pause button. The default is a pause icon.
     */
    @objc public var pauseButtonImage: UIImage

    /**
     *  The font for the elapsed time label. The default is a system font.
     */
    @objc public var labelFont: UIFont

    /**
     *  Specifies whether to show fractions of a second for audio files with a duration of less than 1 minute.
     */
    @objc public var showFractionalSeconds: Bool

    /**
     *  The background color for the player.
     */
    /**
     *  The background color for the player when the audio item is an outgoing message.
     */
    @objc public var backgroundColorOutgoing: UIColor

    /**
     *  The background color for the player when the audio item is an incoming message.
     */
    @objc public var backgroundColorIncoming: UIColor

    /**
     *  The tint color for the player.
     */
    @objc public var tintColor: UIColor

    /**
     *  Insets that sepcify the padding around the play/pause button and time label.
     */
    @objc public var controlInsets: UIEdgeInsets

    /**
     *  Specifies the padding between the button, progress bar, and label.
     */
    @objc public var controlPadding: CGFloat

    /**
     *  Specifies the audio category set prior to playback.
     */
    @objc public var audioCategory: String

    /**
     *  Specifies the audio category options set prior to playback.
     */
    @objc public var audioCategoryOptions: AVAudioSession.CategoryOptions

    /**
     Initializes and returns a `JSQAudioMediaViewAttributes` instance having the specified attributes.
    
     - parameter playButtonImage:        The image for the play button.
     - parameter pauseButtonImage:       The image for the pause button.
     - parameter labelFont:              The font for the elapsed time label.
     - parameter showFractionalSeconds:  Specifies whether to show fractions of a second for audio files with a duration of less than 1 minute.
     - parameter backgroundColorOutgoing: The background color for the player when outgoing.
     - parameter backgroundColorIncoming: The background color for the player when incoming.
     - parameter tintColor:              The tint color for the player.
     - parameter controlInsets:          Insets that sepcify the padding around the play/pause button and time label.
     - parameter controlPadding:         Specifies the padding between the button, progress bar, and label.
     - parameter audioCategory:          Specifies the audio category set prior to playback.
     - parameter audioCategoryOptions:   Specifies the audio category options set prior to playback.
    
     - returns: A new `JSQAudioMediaViewAttributes` instance
     */
    @objc public init(
        playButtonImage: UIImage,
        pauseButtonImage: UIImage,
        labelFont: UIFont,
        showFractionalSeconds: Bool,
        backgroundColorOutgoing: UIColor,
        backgroundColorIncoming: UIColor,
        tintColor: UIColor,
        controlInsets: UIEdgeInsets,
        controlPadding: CGFloat,
        audioCategory: String,
        audioCategoryOptions: AVAudioSession.CategoryOptions
    ) {
        self.playButtonImage = playButtonImage
        self.pauseButtonImage = pauseButtonImage
        self.labelFont = labelFont
        self.showFractionalSeconds = showFractionalSeconds
        self.backgroundColorOutgoing = backgroundColorOutgoing
        self.backgroundColorIncoming = backgroundColorIncoming
        self.backgroundColor = backgroundColorOutgoing  // Legacy support or just pick one
        self.tintColor = tintColor
        self.controlInsets = controlInsets
        self.controlPadding = controlPadding
        self.audioCategory = audioCategory
        self.audioCategoryOptions = audioCategoryOptions
        super.init()
    }

    // Legacy support property if needed, but we should probably keep it to avoid breaking other calls if any?
    // Actually the previous class had `backgroundColor`. We might want to keep it as computed or remove it.
    // If I keep it, I need to init it.
    // I initialized it in the init above.

    /**
     *  The background color for the player.
     *  (Deprecated: Use outgoing/incoming variants)
     */
    @objc public var backgroundColor: UIColor

    /**
     Initializes and returns a default `JSQAudioMediaViewAttributes` instance.
    
     - returns: A new `JSQAudioMediaViewAttributes` instance
     */
    @objc public override convenience init() {
        let tintColor = UIColor.jsq_messageBubbleBlue()
        let options: AVAudioSession.CategoryOptions = [
            .duckOthers, .defaultToSpeaker, .allowBluetooth,
        ]

        self.init(
            playButtonImage: UIImage.jsq_defaultPlay()?.jsq_imageMasked(with: tintColor)
                ?? UIImage(),
            pauseButtonImage: UIImage.jsq_defaultPause()?.jsq_imageMasked(with: tintColor)
                ?? UIImage(),
            labelFont: UIFont.preferredFont(forTextStyle: .body),
            showFractionalSeconds: false,
            backgroundColorOutgoing: UIColor.jsq_messageBubbleLightGray(),  // Default outgoing
            backgroundColorIncoming: UIColor.jsq_messageBubbleLightGray(),  // Default incoming
            tintColor: tintColor,
            controlInsets: UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 18),
            controlPadding: 6,
            audioCategory: AVAudioSession.Category.playback.rawValue,
            audioCategoryOptions: options)
    }
}
