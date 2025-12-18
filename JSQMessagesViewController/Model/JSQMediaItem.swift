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

/// The `JSQMediaItem` class is a base class for media item model objects that represents
/// a single media attachment for a user message. It provides some default behavior for media items,
/// including a default mediaViewDisplaySize, a default mediaPlaceholderView, and view masking as
/// specified by appliesMediaViewMaskAsOutgoing.
///
/// @warning This class is intended to be subclassed. You should not use it directly.
///
/// @see JSQLocationMediaItem.
/// @see JSQPhotoMediaItem.
/// @see JSQVideoMediaItem.
@objc public class JSQMediaItem: NSObject, JSQMessageMediaData, NSCoding, NSCopying {

    /**
     *  A boolean value indicating whether this media item should apply
     *  an outgoing or incoming bubble image mask to its media views.
     *  Specify `YES` for an outgoing mask, and `NO` for an incoming mask.
     *  The default value is `YES`.
     */
    @objc public var appliesMediaViewMaskAsOutgoing: Bool {
        didSet {
            self.cachedPlaceholderView = nil
        }
    }

    internal var cachedPlaceholderView: UIView?

    // MARK: - Initialization

    /**
     *  Initializes and returns a media item with the specified value for maskAsOutgoing.
     *
     *  @param maskAsOutgoing A boolean value indicating whether this media item should apply
     *  an outgoing or incoming bubble image mask to its media views.
     *
     *  @return An initialized `JSQMediaItem` object.
     */
    @objc required public init(maskAsOutgoing: Bool) {
        self.appliesMediaViewMaskAsOutgoing = maskAsOutgoing
        super.init()
        NotificationCenter.default.addObserver(
            self, selector: #selector(didReceiveMemoryWarningNotification(_:)),
            name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    @objc public override convenience init() {
        self.init(maskAsOutgoing: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /**
     *  Clears any media view or media placeholder view that the item has cached.
     */
    @objc public func clearCachedMediaViews() {
        self.cachedPlaceholderView = nil
    }

    // MARK: - Notifications

    @objc func didReceiveMemoryWarningNotification(_ notification: Notification) {
        self.clearCachedMediaViews()
    }

    // MARK: - JSQMessageMediaData protocol

    @objc public func mediaView() -> UIView? {
        assertionFailure(
            "Error! required method not implemented in subclass. Need to implement \(#function)")
        return nil
    }

    @objc public func mediaViewDisplaySize() -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: 315.0, height: 225.0)
        }

        return CGSize(width: 210.0, height: 150.0)
    }

    @objc public func mediaPlaceholderView() -> UIView? {
        if self.cachedPlaceholderView == nil {
            let size = self.mediaViewDisplaySize()
            let view = JSQMessagesMediaPlaceholderView.viewWithActivityIndicator()
            view.frame = CGRect(origin: .zero, size: size)

            // Assuming JSQMessagesMediaViewBubbleImageMasker is visible (still ObjC or updated)
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(
                toMediaView: view, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            self.cachedPlaceholderView = view
        }

        return self.cachedPlaceholderView
    }

    @objc public func mediaHash() -> UInt {
        return UInt(bitPattern: self.hash)
    }

    // MARK: - NSObject

    @objc public override func isEqual(_ object: Any?) -> Bool {
        if self === object as AnyObject {
            return true
        }

        guard let item = object as? JSQMediaItem else {
            return false
        }

        return self.appliesMediaViewMaskAsOutgoing == item.appliesMediaViewMaskAsOutgoing
    }

    @objc public override var hash: Int {
        return NSNumber(value: self.appliesMediaViewMaskAsOutgoing).hash
    }

    @objc public override var description: String {
        return
            "<\(type(of: self)): appliesMediaViewMaskAsOutgoing=\(self.appliesMediaViewMaskAsOutgoing)>"
    }

    @objc func debugQuickLookObject() -> Any? {
        return self.mediaView() ?? self.mediaPlaceholderView()
    }

    // MARK: - NSCoding

    @objc required public init?(coder aDecoder: NSCoder) {
        self.appliesMediaViewMaskAsOutgoing = aDecoder.decodeBool(
            forKey: "appliesMediaViewMaskAsOutgoing")
        super.init()
        NotificationCenter.default.addObserver(
            self, selector: #selector(didReceiveMemoryWarningNotification(_:)),
            name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.appliesMediaViewMaskAsOutgoing, forKey: "appliesMediaViewMaskAsOutgoing")
    }

    // MARK: - NSCopying

    @objc public func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(maskAsOutgoing: self.appliesMediaViewMaskAsOutgoing)
    }
}
