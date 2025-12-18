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
import MobileCoreServices
import UIKit

/// The `JSQPhotoMediaItem` class is a concrete `JSQMediaItem` subclass that implements the `JSQMessageMediaData` protocol
/// and represents a photo media message. An initialized `JSQPhotoMediaItem` object can be passed
/// to a `JSQMediaMessage` object during its initialization to construct a valid media message object.
/// You may wish to subclass `JSQPhotoMediaItem` to provide additional functionality or behavior.
public class JSQPhotoMediaItem: JSQMediaItem {

    /**
     *  The image for the photo media item. The default value is `nil`.
     */
    public var image: UIImage? {
        didSet {
            self.cachedImageView = nil
        }
    }

    private var cachedImageView: UIImageView?

    // MARK: - Initialization

    /**
     *  Initializes and returns a photo media item object having the given image.
     *
     *  @param image The image for the photo media item. This value may be `nil`.
     *
     *  @return An initialized `JSQPhotoMediaItem`.
     *
     *  @discussion If the image must be dowloaded from the network,
     *  you may initialize a `JSQPhotoMediaItem` object with a `nil` image.
     *  Once the image has been retrieved, you can then set the image property.
     */
    public init(image: UIImage?) {
        self.image = image
        super.init(maskAsOutgoing: true)
    }

    public required init(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }

    public override func clearCachedMediaViews() {
        super.clearCachedMediaViews()
        self.cachedImageView = nil
    }

    public override var appliesMediaViewMaskAsOutgoing: Bool {
        didSet {
            self.cachedImageView = nil
        }
    }

    // MARK: - JSQMessageMediaData protocol

    public override func mediaView() -> UIView? {
        guard let image = self.image else {
            return nil
        }

        if self.cachedImageView == nil {
            let size = self.mediaViewDisplaySize()
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(origin: .zero, size: size)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true

            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(
                toMediaView: imageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            self.cachedImageView = imageView
        }

        return self.cachedImageView
    }

    public override func mediaHash() -> UInt {
        return UInt(bitPattern: self.hash)
    }

    public func mediaDataType() -> String? {
        return kUTTypeJPEG as String
    }

    public func mediaData() -> Any? {
        guard let image = self.image else { return nil }
        return image.jpegData(compressionQuality: 1.0)
    }

    // MARK: - NSObject

    public override var hash: Int {
        return super.hash ^ (self.image?.hash ?? 0)
    }

    public override var description: String {
        return
            "<\(type(of: self)): image=\(String(describing: self.image)), appliesMediaViewMaskAsOutgoing=\(self.appliesMediaViewMaskAsOutgoing)>"
    }

    // MARK: - NSCoding

    required public init?(coder aDecoder: NSCoder) {
        self.image = aDecoder.decodeObject(forKey: "image") as? UIImage
        super.init(coder: aDecoder)
    }

    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.image, forKey: "image")
    }

    // MARK: - NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = JSQPhotoMediaItem(image: self.image)
        copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing
        return copy
    }
}
