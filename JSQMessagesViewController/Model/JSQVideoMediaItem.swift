//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import UIKit

/// The `JSQVideoMediaItem` class is a concrete `JSQMediaItem` subclass that implements the `JSQMessageMediaData` protocol
/// and represents a video media message. An initialized `JSQVideoMediaItem` object can be passed
/// to a `JSQMediaMessage` object during its initialization to construct a valid media message object.
/// You may wish to subclass `JSQVideoMediaItem` to provide additional functionality or behavior.
@objc public class JSQVideoMediaItem: JSQMediaItem {

    /**
     *  The URL that identifies a video resource.
     */
    @objc public var fileURL: URL? {
        didSet {
            self.cachedVideoImageView = nil
        }
    }

    /**
     *  The thumbnail image to display for the video.
     */
    @objc public var thumbnailImage: UIImage? {
        didSet {
            self.cachedVideoImageView = nil
        }
    }

    /**
     *  A boolean value that specifies whether or not the video is ready to be played.
     *
     *  @discussion When set to `YES`, the video is ready. When set to `NO` it is not ready.
     */
    @objc public var isReadyToPlay: Bool = false {
        didSet {
            self.cachedVideoImageView = nil
        }
    }

    private var cachedVideoImageView: UIImageView?

    // MARK: - Initialization

    /**
     *  Initializes and returns a video media item having the given fileURL.
     *
     *  @param fileURL       The URL that identifies the video resource.
     *  @param isReadyToPlay A boolean value that specifies if the video is ready to play.
     *
     *  @return An initialized `JSQVideoMediaItem`.
     *
     *  @discussion If the video must be downloaded from the network,
     *  you may initialize a `JSQVideoMediaItem` with a `nil` fileURL or specify `NO` for
     *  isReadyToPlay. Once the video has been saved to disk, or is ready to stream, you can
     *  set the fileURL property or isReadyToPlay property, respectively.
     */
    @objc public convenience init(fileURL: URL?, isReadyToPlay: Bool) {
        self.init(fileURL: fileURL, isReadyToPlay: isReadyToPlay, thumbnailImage: nil)
    }

    /**
     *  Initializes and returns a video media item having the given fileURL.
     *
     *  @param fileURL          The URL that identifies the video resource.
     *  @param isReadyToPlay    A boolean value that specifies if the video is ready to play.
     *  @param thumbnailImage   The background thumbnail image for the video.
     *
     *  @return An initialized `JSQVideoMediaItem` if successful, `nil` otherwise.
     *
     *  @discussion If the video must be downloaded from the network,
     *  you may initialize a `JSQVideoMediaItem` with a `nil` fileURL or specify `NO` for
     *  isReadyToPlay. Once the video has been saved to disk, or is ready to stream, you can
     *  set the fileURL property or isReadyToPlay property, respectively. The background thumbnail
     *  is optional.
     */
    @objc public init(fileURL: URL?, isReadyToPlay: Bool, thumbnailImage: UIImage? = nil) {
        self.fileURL = fileURL
        self.isReadyToPlay = isReadyToPlay
        self.thumbnailImage = thumbnailImage
        super.init(maskAsOutgoing: true)
    }

    @objc public required init(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }

    @objc public override func clearCachedMediaViews() {
        super.clearCachedMediaViews()
        self.cachedVideoImageView = nil
    }

    @objc public override var appliesMediaViewMaskAsOutgoing: Bool {
        didSet {
            self.cachedVideoImageView = nil
        }
    }

    // MARK: - JSQMessageMediaData protocol

    @objc public override func mediaView() -> UIView? {
        if self.fileURL == nil || !self.isReadyToPlay {
            return nil
        }

        if self.cachedVideoImageView == nil {
            let size = self.mediaViewDisplaySize()
            let playIcon = UIImage(
                named: "play", in: Bundle(for: JSQMessagesViewController.self), compatibleWith: nil)

            let imageView = UIImageView(image: self.thumbnailImage)
            imageView.backgroundColor = UIColor.black
            imageView.frame = CGRect(origin: .zero, size: size)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true

            let iconView = UIImageView(image: playIcon)
            iconView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            iconView.contentMode = .center
            iconView.clipsToBounds = true

            imageView.addSubview(iconView)

            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(
                toMediaView: imageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            self.cachedVideoImageView = imageView
        }

        return self.cachedVideoImageView
    }

    @objc public override func mediaHash() -> UInt {
        return UInt(bitPattern: self.hash)
    }

    // MARK: - NSObject

    @objc public override var hash: Int {
        return super.hash ^ (self.fileURL?.hashValue ?? 0)
    }

    @objc public override var description: String {
        return
            "<\(type(of: self)): fileURL=\(String(describing: self.fileURL)), isReadyToPlay=\(self.isReadyToPlay), appliesMediaViewMaskAsOutgoing=\(self.appliesMediaViewMaskAsOutgoing)>"
    }

    // MARK: - NSCoding

    @objc required public init?(coder aDecoder: NSCoder) {
        self.fileURL = aDecoder.decodeObject(forKey: "fileURL") as? URL
        self.isReadyToPlay = aDecoder.decodeBool(forKey: "isReadyToPlay")
        self.thumbnailImage = aDecoder.decodeObject(forKey: "thumbnailImage") as? UIImage
        super.init(coder: aDecoder)
    }

    @objc public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.fileURL, forKey: "fileURL")
        aCoder.encode(self.isReadyToPlay, forKey: "isReadyToPlay")
        aCoder.encode(self.thumbnailImage, forKey: "thumbnailImage")
    }

    // MARK: - NSCopying

    @objc public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = JSQVideoMediaItem(
            fileURL: self.fileURL, isReadyToPlay: self.isReadyToPlay,
            thumbnailImage: self.thumbnailImage)
        copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing
        return copy
    }
}
