import AVFoundation
import UIKit

/// A completion block for a `JSQMessagesVideoThumbnailFactory`.
public typealias JSQMessagesVideoThumbnailCompletionBlock = (UIImage?, Error?) -> Void

/// `JSQMessagesVideoThumbnailFactory` is a factory that provides a means for generating
/// a thumbnail image with for a `JSQVideoMediaItem`.
@objc public class JSQMessagesVideoThumbnailFactory: NSObject {

    /**
     *  Generates and returns a thumbnail image for the specified video media asset
     *  with the default time of `CMTimeMakeWithSeconds(1, 2)`.
     *
     *  The specified block is executed upon completion of generating the thumbnail image
     *  and is executed on the main thread.
     *
     *  - parameter asset:      The `AVURLAsset` for the video media item.
     *  - parameter completion: The block to call after the thumbnail has been generated.
     */
    @objc public func thumbnail(
        forVideoMediaAsset asset: AVURLAsset,
        completion: @escaping JSQMessagesVideoThumbnailCompletionBlock
    ) {
        self.thumbnail(
            forVideoMediaAsset: asset, time: CMTime(seconds: 1, preferredTimescale: 2),
            completion: completion)
    }

    /**
     *  Generates and returns a thumbnail image for the specified video media asset with the given `CMTime`.
     *
     *  The specified block is executed upon completion of generating the thumbnail image
     *  and is executed on the main thread.
     *
     *  - parameter asset:      The `AVURLAsset` for the video media item.
     *  - parameter time:       The CMTime for capturing the thumbnail image from the video asset.
     *  - parameter completion: The block to call after the thumbnail has been generated.
     */
    @objc public func thumbnail(
        forVideoMediaAsset asset: AVURLAsset, time: CMTime,
        completion: @escaping JSQMessagesVideoThumbnailCompletionBlock
    ) {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        if UIDevice.current.userInterfaceIdiom == .pad {
            generator.maximumSize = CGSize(width: 315.0, height: 225.0)
        } else {
            generator.maximumSize = CGSize(width: 210.0, height: 150.0)
        }

        let times = [NSValue(time: time)]
        generator.generateCGImagesAsynchronously(forTimes: times) {
            requestedTime, image, actualTime, result, error in
            let uiImage: UIImage? =
                (result == .succeeded && image != nil) ? UIImage(cgImage: image!) : nil

            DispatchQueue.main.async {
                completion(uiImage, error)
            }
        }
    }
}
