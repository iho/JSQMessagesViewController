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

/// The `JSQMessage` class is a concrete class for message model objects that represents a single user message.
/// The message can be a text message or media message, depending on how it is initialized.
/// It implements the `JSQMessageData` protocol and it contains the senderId, senderDisplayName,
/// and the date that the message was sent. If initialized as a media message it also contains a media attachment,
/// otherwise it contains the message text.
@objc public class JSQMessage: NSObject, JSQMessageData, NSCoding, NSCopying {

    /**
     *  Returns the string identifier that uniquely identifies the user who sent the message.
     */
    @objc public let senderId: String

    /**
     *  Returns the display name for the user who sent the message. This value does not have to be unique.
     */
    @objc public let senderDisplayName: String

    /**
     *  Returns the date that the message was sent.
     */
    @objc public let date: Date

    /**
     *  Returns a boolean value specifying whether or not the message contains media.
     *  If `NO`, the message contains text. If `YES`, the message contains media.
     *  The value of this property depends on how the object was initialized.
     */
    @objc public let isMediaMessage: Bool

    /**
     *  Returns the body text of the message, or `nil` if the message is a media message.
     *  That is, if `isMediaMessage` is equal to `YES` then this value will be `nil`.
     */
    @objc public let text: String?

    /**
     *  Returns the media item attachment of the message, or `nil` if the message is not a media message.
     *  That is, if `isMediaMessage` is equal to `NO` then this value will be `nil`.
     */
    @objc public let media: JSQMessageMediaData?

    // MARK: - Initialization

    /**
     *  Initializes and returns a message object having the given senderId, displayName, text,
     *  and current system date.
     *
     *  @param senderId    The unique identifier for the user who sent the message. This value must not be `nil`.
     *  @param displayName The display name for the user who sent the message. This value must not be `nil`.
     *  @param text        The body text of the message. This value must not be `nil`.
     *
     *  @discussion Initializing a `JSQMessage` with this method will set `isMediaMessage` to `NO`.
     *
     *  @return An initialized `JSQMessage` object.
     */
    @objc public convenience init(senderId: String, displayName: String, text: String) {
        self.init(senderId: senderId, senderDisplayName: displayName, date: Date(), text: text)
    }

    /**
     *  Initializes and returns a message object having the given senderId, senderDisplayName, date, and text.
     *
     *  @param senderId          The unique identifier for the user who sent the message. This value must not be `nil`.
     *  @param senderDisplayName The display name for the user who sent the message. This value must not be `nil`.
     *  @param date              The date that the message was sent. This value must not be `nil`.
     *  @param text              The body text of the message. This value must not be `nil`.
     *
     *  @discussion Initializing a `JSQMessage` with this method will set `isMediaMessage` to `NO`.
     *
     *  @return An initialized `JSQMessage` object.
     */
    @objc public init(senderId: String, senderDisplayName: String, date: Date, text: String) {
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.date = date
        self.text = text
        self.isMediaMessage = false
        self.media = nil
        super.init()
    }

    /**
     *  Initializes and returns a message object having the given senderId, displayName, media,
     *  and current system date.
     *
     *  @param senderId    The unique identifier for the user who sent the message. This value must not be `nil`.
     *  @param displayName The display name for the user who sent the message. This value must not be `nil`.
     *  @param media       The media data for the message. This value must not be `nil`.
     *
     *  @discussion Initializing a `JSQMessage` with this method will set `isMediaMessage` to `YES`.
     *
     *  @return An initialized `JSQMessage` object.
     */
    @objc public convenience init(senderId: String, displayName: String, media: JSQMessageMediaData)
    {
        self.init(senderId: senderId, senderDisplayName: displayName, date: Date(), media: media)
    }

    /**
     *  Initializes and returns a message object having the given senderId, displayName, date, and media.
     *
     *  @param senderId          The unique identifier for the user who sent the message. This value must not be `nil`.
     *  @param senderDisplayName The display name for the user who sent the message. This value must not be `nil`.
     *  @param date              The date that the message was sent. This value must not be `nil`.
     *  @param media             The media data for the message. This value must not be `nil`.
     *
     *  @discussion Initializing a `JSQMessage` with this method will set `isMediaMessage` to `YES`.
     *
     *  @return An initialized `JSQMessage` object.
     */
    @objc public init(
        senderId: String, senderDisplayName: String, date: Date, media: JSQMessageMediaData
    ) {
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.date = date
        self.media = media
        self.isMediaMessage = true
        self.text = nil
        super.init()
    }

    // Internal designated initializer for simpler init logic if needed, but the public ones above are sufficient.

    // MARK: - JSQMessageData Protocol

    @objc public var messageHash: UInt {
        // Simple hash combining implementation
        // Use bitPattern to handle negative hashValue safely
        let contentHash: UInt =
            self.isMediaMessage
            ? self.media?.mediaHash() ?? 0
            : UInt(bitPattern: self.text?.hashValue ?? 0)
        return UInt(bitPattern: self.senderId.hashValue)
            ^ UInt(bitPattern: self.date.hashValue)
            ^ contentHash
    }

    // Note: Other protocol methods (senderId, etc.) are satisfied by properties.

    // MARK: - NSObject

    @objc public override func isEqual(_ object: Any?) -> Bool {
        if self === object as AnyObject {
            return true
        }

        guard let aMessage = object as? JSQMessage else {
            return false
        }

        if self.isMediaMessage != aMessage.isMediaMessage {
            return false
        }

        let hasEqualContent =
            self.isMediaMessage
            ? (self.media?.isEqual(aMessage.media) ?? false) : (self.text == aMessage.text)

        return self.senderId == aMessage.senderId
            && self.senderDisplayName == aMessage.senderDisplayName
            && (self.date == aMessage.date)
            && hasEqualContent
    }

    @objc public override var hash: Int {
        return Int(self.messageHash)
    }

    @objc public override var description: String {
        return
            "<\(type(of: self)): senderId=\(self.senderId), senderDisplayName=\(self.senderDisplayName), date=\(self.date), isMediaMessage=\(self.isMediaMessage), text=\(String(describing: self.text)), media=\(String(describing: self.media))>"
    }

    @objc func debugQuickLookObject() -> Any? {
        return self.media?.mediaView() ?? self.media?.mediaPlaceholderView()
    }

    // MARK: - NSCoding

    @objc public required init?(coder aDecoder: NSCoder) {
        guard let senderId = aDecoder.decodeObject(forKey: "senderId") as? String,
            let senderDisplayName = aDecoder.decodeObject(forKey: "senderDisplayName") as? String,
            let date = aDecoder.decodeObject(forKey: "date") as? Date
        else {
            return nil
        }

        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.date = date
        self.isMediaMessage = aDecoder.decodeBool(forKey: "isMediaMessage")
        self.text = aDecoder.decodeObject(forKey: "text") as? String
        self.media = aDecoder.decodeObject(forKey: "media") as? JSQMessageMediaData
        super.init()
    }

    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.senderId, forKey: "senderId")
        aCoder.encode(self.senderDisplayName, forKey: "senderDisplayName")
        aCoder.encode(self.date, forKey: "date")
        aCoder.encode(self.isMediaMessage, forKey: "isMediaMessage")
        aCoder.encode(self.text, forKey: "text")
        if let media = self.media, media.conforms(to: NSCoding.self) {
            aCoder.encode(media, forKey: "media")
        }
    }

    // MARK: - NSCopying

    @objc public func copy(with zone: NSZone? = nil) -> Any {
        if self.isMediaMessage, let media = self.media {
            return JSQMessage(
                senderId: self.senderId,
                senderDisplayName: self.senderDisplayName,
                date: self.date,
                media: media)
        } else {
            return JSQMessage(
                senderId: self.senderId,
                senderDisplayName: self.senderDisplayName,
                date: self.date,
                text: self.text ?? "")
        }
    }
}
