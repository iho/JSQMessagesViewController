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
public class JSQMediaItem: NSObject, JSQMessageMediaData, NSCoding, NSCopying {

    /**
     *  A boolean value indicating whether this media item should apply
     *  an outgoing or incoming bubble image mask to its media views.
     *  Specify `YES` for an outgoing mask, and `NO` for an incoming mask.
     *  The default value is `YES`.
     */
    public var appliesMediaViewMaskAsOutgoing: Bool {
        didSet {
            self.cachedPlaceholderView = nil
        }
    }

    internal var cachedPlaceholderView: UIView?
    private var memoryWarningToken: NSObjectProtocol?

    // MARK: - Initialization

    /**
     *  Initializes and returns a media item with the specified value for maskAsOutgoing.
     *
     *  @param maskAsOutgoing A boolean value indicating whether this media item should apply
     *  an outgoing or incoming bubble image mask to its media views.
     *
     *  @return An initialized `JSQMediaItem` object.
     */
    required public init(maskAsOutgoing: Bool) {
        self.appliesMediaViewMaskAsOutgoing = maskAsOutgoing
        super.init()
        self.memoryWarningToken = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil
        ) { [weak self] _ in
            self?.clearCachedMediaViews()
        }
    }

    public override convenience init() {
        self.init(maskAsOutgoing: true)
    }

    deinit {
        if let token = self.memoryWarningToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    /**
     *  Clears any media view or media placeholder view that the item has cached.
     */
    public func clearCachedMediaViews() {
        self.cachedPlaceholderView = nil
    }

    // MARK: - JSQMessageMediaData protocol

    public func mediaView() -> UIView? {
        assertionFailure(
            "Error! required method not implemented in subclass. Need to implement \(#function)")
        return nil
    }

    public func mediaViewDisplaySize() -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: 315.0, height: 225.0)
        }

        return CGSize(width: 210.0, height: 150.0)
    }

    public func mediaPlaceholderView() -> UIView? {
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

    public func mediaHash() -> UInt {
        return UInt(bitPattern: self.hash)
    }

    // MARK: - NSObject

    public override func isEqual(_ object: Any?) -> Bool {
        if self === object as AnyObject {
            return true
        }

        guard let item = object as? JSQMediaItem else {
            return false
        }

        return self.appliesMediaViewMaskAsOutgoing == item.appliesMediaViewMaskAsOutgoing
    }

    public override var hash: Int {
        return NSNumber(value: self.appliesMediaViewMaskAsOutgoing).hash
    }

    public override var description: String {
        return
            "<\(type(of: self)): appliesMediaViewMaskAsOutgoing=\(self.appliesMediaViewMaskAsOutgoing)>"
    }

    func debugQuickLookObject() -> Any? {
        return self.mediaView() ?? self.mediaPlaceholderView()
    }

    // MARK: - NSCoding

    required public init?(coder aDecoder: NSCoder) {
        self.appliesMediaViewMaskAsOutgoing = aDecoder.decodeBool(
            forKey: "appliesMediaViewMaskAsOutgoing")
        super.init()
        self.memoryWarningToken = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil
        ) { [weak self] _ in
            self?.clearCachedMediaViews()
        }
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.appliesMediaViewMaskAsOutgoing, forKey: "appliesMediaViewMaskAsOutgoing")
    }

    // MARK: - NSCopying

    public func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(maskAsOutgoing: self.appliesMediaViewMaskAsOutgoing)
    }
}
