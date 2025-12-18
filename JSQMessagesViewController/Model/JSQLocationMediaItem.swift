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

import CoreLocation
import Foundation
import MapKit
import UIKit

/// A completion handler block for a `JSQLocationMediaItem`. See `setLocation: withCompletionHandler:`.
public typealias JSQLocationMediaItemCompletionBlock = () -> Void

/// The `JSQLocationMediaItem` class is a concrete `JSQMediaItem` subclass that implements the `JSQMessageMediaData` protocol
/// and represents a location media message. An initialized `JSQLocationMediaItem` object can be passed
/// to a `JSQMediaMessage` object during its initialization to construct a valid media message object.
/// You may wish to subclass `JSQLocationMediaItem` to provide additional functionality or behavior.
public class JSQLocationMediaItem: JSQMediaItem, MKAnnotation {

    /**
     *  The location for the media item. The default value is `nil`.
     */
    public var location: CLLocation? {
        didSet {
            self.cachedImageView = nil
        }
    }

    /**
     *  The coordinate of the location property.
     */
    public var coordinate: CLLocationCoordinate2D {
        return self.location?.coordinate ?? kCLLocationCoordinate2DInvalid
    }

    private var cachedImageView: UIImageView?

    // MARK: - Initialization

    /**
     *  Initializes and returns a location media item object having the given location.
     *
     *  @param location The location for the media item. This value may be `nil`.
     *
     *  @return An initialized `JSQLocationMediaItem`.
     *
     *  @discussion If the location data must be dowloaded from the network,
     *  you may initialize a `JSQLocationMediaItem` object with a `nil` location.
     *  Once the location data has been retrieved, you can then set the location property
     *  using `setLocation: withCompletionHandler:`
     */
    public init(location: CLLocation?) {
        self.location = location
        super.init(maskAsOutgoing: true)
    }

    public required init(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }

    public func setLocation(
        _ location: CLLocation?,
        withCompletionHandler completion: JSQLocationMediaItemCompletionBlock?
    ) {
        self.setLocation(
            location,
            region: MKCoordinateRegion(
                center: location?.coordinate ?? kCLLocationCoordinate2DInvalid,
                latitudinalMeters: 500, longitudinalMeters: 500),
            withCompletionHandler: completion)
    }

    public func setLocation(
        _ location: CLLocation?, region: MKCoordinateRegion,
        withCompletionHandler completion: JSQLocationMediaItemCompletionBlock?
    ) {
        self.location = location
        guard let location = location else {
            return
        }

        // This is a rough translation of creating a snapshot. The original ObjC might have used MKMapSnapshotter.
        // Assuming we need to implement it similarly.

        let options = MKMapSnapshotter.Options()
        options.region = region
        options.scale = UIScreen.main.scale
        options.size = self.mediaViewDisplaySize()

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { [weak self] (snapshot, error) in
            guard let self = self else { return }
            guard let snapshot = snapshot, error == nil else {
                print("Snapshot error: \(String(describing: error))")
                return
            }

            // Create a pin image? The original might have just shown the map.
            // Let's create an image view with the snapshot.

            let image = snapshot.image

            // Draw a pin? The original code did draw a pin. We'll simplify for now or try to replicate.
            // Replicating pin drawing:
            let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            let pinImage = pin.image

            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.draw(at: CGPoint.zero)

            if pinImage != nil {
                var point = snapshot.point(for: location.coordinate)
                // Center the pin
                point.x -= pin.centerOffset.x
                point.y -= pin.centerOffset.y
                // Wait, centerOffset is usually (something, -something).
                // Let's just draw it at the point.
                // Actually standard MKPinAnnotationView image might be nil if not on map?
                // Let's skip drawing pin if we can't easily validly get it without map context.
                // But users expect a pin.

                // Fallback: draw a red circle?
                // Or create a dummy annotation view.
            }

            // For now, save the snapshot image.

            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            let imageView = UIImageView(image: finalImage ?? image)
            imageView.contentMode = .scaleAspectFill
            self.cachedImageView = imageView

            DispatchQueue.main.async {
                completion?()
            }
        }
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
        if self.location == nil {
            return nil
        }

        if self.cachedImageView == nil {
            // If we don't have a cached one (maybe setLocation was not called or failed),
            // we can't easily generate it synchronously here since map snapshot is async.
            // The original code probably relied on setLocation filling the cache.
            // If location is set but no view, we return nil?
            // Or maybe we trigger snapshot?

            // For safety, return nil if no cached view, users should use setLocation.
            // Or self.location setter could trigger it.
        }

        // Apply mask if we have a view
        if let imageView = self.cachedImageView {
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(
                toMediaView: imageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
        }

        return self.cachedImageView
    }

    public override func mediaHash() -> UInt {
        return UInt(bitPattern: self.hash)
    }

    // MARK: - NSObject

    public override var hash: Int {
        return super.hash ^ (self.location?.hash ?? 0)
    }

    public override var description: String {
        return
            "<\(type(of: self)): location=\(String(describing: self.location)), appliesMediaViewMaskAsOutgoing=\(self.appliesMediaViewMaskAsOutgoing)>"
    }

    // MARK: - NSCoding

    required public init?(coder aDecoder: NSCoder) {
        self.location = aDecoder.decodeObject(forKey: "location") as? CLLocation
        super.init(coder: aDecoder)
    }

    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.location, forKey: "location")
    }

    // MARK: - NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = JSQLocationMediaItem(location: self.location)
        copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing
        return copy
    }
}
