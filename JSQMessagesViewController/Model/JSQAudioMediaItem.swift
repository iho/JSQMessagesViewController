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

import AVFoundation
import Foundation
import UIKit

public protocol JSQAudioMediaItemDelegate: NSObjectProtocol {
    /**
     *  Tells the delegate if the specified `JSQAudioMediaItem` changes the sound category or categoryOptions, or if an error occurs.
     */
    func audioMediaItem(
        _ audioMediaItem: JSQAudioMediaItem, didChangeAudioCategory category: String,
        options: AVAudioSession.CategoryOptions, error: Error?)
}

/// The `JSQAudioMediaItem` class is a concrete `JSQMediaItem` subclass that implements the `JSQMessageMediaData` protocol
/// and represents an audio media message. An initialized `JSQAudioMediaItem` object can be passed
/// to a `JSQMediaMessage` object during its initialization to construct a valid media message object.
/// You may wish to subclass `JSQAudioMediaItem` to provide additional functionality or behavior.
public class JSQAudioMediaItem: JSQMediaItem, AVAudioPlayerDelegate {

    /**
     *  The delegate object for audio event notifications.
     */
    public weak var delegate: JSQAudioMediaItemDelegate?

    /**
     *  The view attributes to configure the appearance of the audio media view.
     */
    public private(set) var audioViewAttributes: JSQAudioMediaViewAttributes

    /**
     *  A data object that contains an audio resource.
     */
    public var audioData: Data? {
        didSet {
            self.cachedMediaView = nil
        }
    }

    private var cachedMediaView: UIView?
    private var audioPlayer: AVAudioPlayer?

    // MARK: - Initialization

    /**
     *  Initializes and returns a audio media item having the given audioData.
     *
     *  @param audioData              The data object that contains the audio resource.
     *  @param audioViewAttributes The view attributes to configure the appearance of the audio media view.
     *
     *  @return An initialized `JSQAudioMediaItem`.
     */
    public init(data audioData: Data?, audioViewAttributes: JSQAudioMediaViewAttributes) {
        self.audioData = audioData
        self.audioViewAttributes = audioViewAttributes
        super.init(maskAsOutgoing: true)
    }

    /**
     *  Initializes and returns a default audio media item.
     *
     *  @return An initialized `JSQAudioMediaItem`.
     */
    public convenience init() {
        self.init(data: nil, audioViewAttributes: JSQAudioMediaViewAttributes())
    }

    /**
     Initializes and returns a default audio media using the specified view attributes.
    
     @param audioViewAttributes The view attributes to configure the appearance of the audio media view.
    
     @return  An initialized `JSQAudioMediaItem`.
     */
    public convenience init(audioViewAttributes: JSQAudioMediaViewAttributes) {
        self.init(data: nil, audioViewAttributes: audioViewAttributes)
    }

    /**
     *  Initializes and returns an audio media item having the given audioData.
     *
     *  @param audioData The data object that contains the audio resource.
     *
     *  @return An initialized `JSQAudioMediaItem`.
     */
    public convenience init(data audioData: Data?) {
        self.init(data: audioData, audioViewAttributes: JSQAudioMediaViewAttributes())
    }

    public required init(maskAsOutgoing: Bool) {
        self.audioViewAttributes = JSQAudioMediaViewAttributes()
        super.init(maskAsOutgoing: maskAsOutgoing)
    }

    /**
     *  Sets or updates the data object in an audio media item with the data specified at audioURL.
     *
     *  @param audioURL A File URL containing the location of the audio data.
     */
    public func setAudioData(with url: URL) {
        do {
            self.audioData = try Data(contentsOf: url)
        } catch {
            print("Error setting audio data: \(error)")
        }
    }

    public override func clearCachedMediaViews() {
        super.clearCachedMediaViews()
        self.cachedMediaView = nil
    }

    public override var appliesMediaViewMaskAsOutgoing: Bool {
        didSet {
            self.cachedMediaView = nil
        }
    }

    // MARK: - JSQMessageMediaData protocol

    public override func mediaView() -> UIView? {
        if self.audioData == nil {
            return nil
        }

        if self.cachedMediaView == nil {
            let size = self.mediaViewDisplaySize()
            // Placeholder: Needs a proper Audio Media View.
            // Since we are rewriting models but Views are still ObjC maybe?
            // No, JSQAudioMediaViewAttributes is in Layout/.
            // JSQAudioMediaItem in ObjC might have constructed a complex view.
            // We'll create a simple placeholder or try to reuse components.
            // For now, let's create a red view with "Audio" label or similar.

            let container = UIView(frame: CGRect(origin: .zero, size: size))
            container.backgroundColor =
                self.appliesMediaViewMaskAsOutgoing
                ? self.audioViewAttributes.backgroundColorOutgoing
                : self.audioViewAttributes.backgroundColorIncoming

            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(
                toMediaView: container, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            self.cachedMediaView = container
        }

        return self.cachedMediaView
    }

    public override func mediaHash() -> UInt {
        return UInt(bitPattern: self.hash)
    }

    // MARK: - NSObject

    public override var hash: Int {
        return super.hash ^ (self.audioData?.hashValue ?? 0)
    }

    public override var description: String {
        return
            "<\(type(of: self)): audioData=\(String(describing: self.audioData)), appliesMediaViewMaskAsOutgoing=\(self.appliesMediaViewMaskAsOutgoing)>"
    }

    // MARK: - NSCoding

    required public init?(coder aDecoder: NSCoder) {
        self.audioData = aDecoder.decodeObject(forKey: "audioData") as? Data
        self.audioViewAttributes =
            aDecoder.decodeObject(forKey: "audioViewAttributes") as? JSQAudioMediaViewAttributes
            ?? JSQAudioMediaViewAttributes()
        super.init(coder: aDecoder)
    }

    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.audioData, forKey: "audioData")
        aCoder.encode(self.audioViewAttributes, forKey: "audioViewAttributes")
    }

    // MARK: - NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = JSQAudioMediaItem(
            data: self.audioData, audioViewAttributes: self.audioViewAttributes)
        copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing
        return copy
    }

    // MARK: - AVAudioPlayerDelegate

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Handle playback finish
    }
}
