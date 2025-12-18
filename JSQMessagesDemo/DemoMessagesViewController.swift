//
//  DemoMessagesViewController.swift
//  JSQMessagesDemo
//

import CoreLocation
import JSQMessages
import UIKit

protocol JSQDemoViewControllerDelegate: AnyObject {
    func didDismissJSQDemoViewController(_ vc: DemoMessagesViewController)
}

class DemoMessagesViewController: JSQMessagesViewController, UIActionSheetDelegate,
    JSQMessagesComposerTextViewPasteDelegate
{

    // Override to use the parent class's XIB
    override class func messagesViewController() -> JSQMessagesViewController {
        let nibName = String(describing: JSQMessagesViewController.self)
        return self.init(nibName: nibName, bundle: Bundle(for: JSQMessagesViewController.self))
    }

    weak var delegateModal: JSQDemoViewControllerDelegate?
    var demoData: DemoModelData = DemoModelData()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Chat X.509"

        self.inputToolbar.contentView.textView?.composerPasteDelegate = self

        // Load demo data
        // self.demoData is initialized in declaration

        // Note: Cannot set accessory delegate from non-@objc context in Swift

        if !UserDefaults.incomingAvatarSetting(),
            let layout = self.collectionView.collectionViewLayout
                as? JSQMessagesCollectionViewFlowLayout
        {
            layout.incomingAvatarViewSize = .zero
        }

        if !UserDefaults.outgoingAvatarSetting(),
            let layout = self.collectionView.collectionViewLayout
                as? JSQMessagesCollectionViewFlowLayout
        {
            layout.outgoingAvatarViewSize = .zero
        }

        self.showLoadEarlierMessagesHeader = true

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.jsq_defaultTypingIndicator(), style: .plain, target: self,
            action: #selector(receiveMessagePressed(_:)))

        // Register custom menu actions
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(customAction(_:)))
        JSQMessagesCollectionViewCell.registerMenuAction(
            #selector(UIResponderStandardEditActions.delete(_:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.delegateModal != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .stop, target: self, action: #selector(closePressed(_:)))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let layout = self.collectionView.collectionViewLayout
            as? JSQMessagesCollectionViewFlowLayout
        {
            // Enable springiness for bouncy animations
            layout.springinessEnabled = UserDefaults.springinessSetting()
            // Lower resistance = more bouncy (default 1000, max used is 1400)
            // Using 900 for more visible spring effect
            layout.springResistanceFactor = 900
        }
    }

    // MARK: - Custom menu actions

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(customAction(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }

    // Note: performAction is not available to override in Swift UIViewController.
    // The menu actions are handled via canPerformAction and collectionView delegate methods.

    @objc func customAction(_ sender: Any?) {
        print("Custom action received! Sender: \(String(describing: sender))")

        let alert = UIAlertController(title: "Custom Action", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Actions

    @objc func receiveMessagePressed(_ sender: UIBarButtonItem) {
        self.showTypingIndicator = !self.showTypingIndicator
        self.scrollToBottom(animated: true)

        var copyMessage = self.demoData.messages.last?.copy() as? JSQMessage

        if copyMessage == nil {
            copyMessage = JSQMessage(
                senderId: DemoModelData.kJSQDemoAvatarIdJobs,
                displayName: DemoModelData.kJSQDemoAvatarDisplayNameJobs, text: "First received!")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {

            var userIds = Array(self.demoData.users.keys)
            if let index = userIds.firstIndex(of: self.senderId) {
                userIds.remove(at: index)
            }
            let randomUserId = userIds[Int(arc4random_uniform(UInt32(userIds.count)))]

            var newMessage: JSQMessage?
            var newMediaData: JSQMessageMediaData?
            var newMediaAttachmentCopy: Any?

            if copyMessage!.isMediaMessage {
                let copyMediaData = copyMessage!.media

                if let photoItem = copyMediaData as? JSQPhotoMediaItem {
                    let photoItemCopy = photoItem.copy() as! JSQPhotoMediaItem
                    photoItemCopy.appliesMediaViewMaskAsOutgoing = false
                    newMediaAttachmentCopy = UIImage(cgImage: photoItem.image!.cgImage!)
                    photoItemCopy.image = nil
                    newMediaData = photoItemCopy
                } else if let locationItem = copyMediaData as? JSQLocationMediaItem {
                    let locationItemCopy = locationItem.copy() as! JSQLocationMediaItem
                    locationItemCopy.appliesMediaViewMaskAsOutgoing = false
                    newMediaAttachmentCopy = locationItem.location!.copy()
                    locationItemCopy.location = nil
                    newMediaData = locationItemCopy
                } else if let videoItem = copyMediaData as? JSQVideoMediaItem {
                    let videoItemCopy = videoItem.copy() as! JSQVideoMediaItem
                    videoItemCopy.appliesMediaViewMaskAsOutgoing = false
                    newMediaAttachmentCopy = videoItem.fileURL
                    videoItemCopy.fileURL = nil
                    videoItemCopy.isReadyToPlay = false
                    newMediaData = videoItemCopy
                } else if let audioItem = copyMediaData as? JSQAudioMediaItem {
                    let audioItemCopy = audioItem.copy() as! JSQAudioMediaItem
                    audioItemCopy.appliesMediaViewMaskAsOutgoing = false
                    newMediaAttachmentCopy = audioItem.audioData
                    audioItemCopy.audioData = nil
                    newMediaData = audioItemCopy
                } else {
                    print("Error: unrecognized media item")
                }

                newMessage = JSQMessage(
                    senderId: randomUserId, displayName: self.demoData.users[randomUserId]!,
                    media: newMediaData!)
            } else {
                newMessage = JSQMessage(
                    senderId: randomUserId, displayName: self.demoData.users[randomUserId]!,
                    text: copyMessage!.text!)
            }

            self.demoData.messages.append(newMessage!)
            self.finishReceivingMessage(animated: true)

            if newMessage!.isMediaMessage {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if let photoItem = newMediaData as? JSQPhotoMediaItem {
                        photoItem.image = (newMediaAttachmentCopy as! UIImage)
                        self.collectionView.reloadData()
                    } else if let locationItem = newMediaData as? JSQLocationMediaItem {
                        locationItem.setLocation(newMediaAttachmentCopy as? CLLocation) {
                            self.collectionView.reloadData()
                        }
                    } else if let videoItem = newMediaData as? JSQVideoMediaItem {
                        videoItem.fileURL = (newMediaAttachmentCopy as! URL)
                        videoItem.isReadyToPlay = true
                        self.collectionView.reloadData()
                    } else if let audioItem = newMediaData as? JSQAudioMediaItem {
                        audioItem.audioData = (newMediaAttachmentCopy as! Data)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }

    @objc func closePressed(_ sender: UIBarButtonItem) {
        self.delegateModal?.didDismissJSQDemoViewController(self)
    }

    // MARK: - JSQMessagesViewController method overrides

    override func didPressSendButton(
        _ button: UIButton, withMessageText text: String, senderId: String,
        senderDisplayName: String, date: Date
    ) {
        let message = JSQMessage(
            senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.demoData.messages.append(message)
        self.finishSendingMessage(animated: true)
    }

    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView.textView?.resignFirstResponder()

        let sheet = UIAlertController(
            title: "Media messages", message: nil, preferredStyle: .actionSheet)

        sheet.addAction(
            UIAlertAction(
                title: "Send photo", style: .default,
                handler: { _ in
                    self.demoData.addPhotoMediaMessage()
                    self.finishSendingMessage(animated: true)
                }))

        sheet.addAction(
            UIAlertAction(
                title: "Send location", style: .default,
                handler: { _ in
                    self.demoData.addLocationMediaMessage {
                        self.collectionView.reloadData()
                    }
                    self.finishSendingMessage(animated: true)
                }))

        sheet.addAction(
            UIAlertAction(
                title: "Send video", style: .default,
                handler: { _ in
                    self.demoData.addVideoMediaMessage()
                    self.finishSendingMessage(animated: true)
                }))

        sheet.addAction(
            UIAlertAction(
                title: "Send video thumbnail", style: .default,
                handler: { _ in
                    self.demoData.addVideoMediaMessageWithThumbnail()
                    self.finishSendingMessage(animated: true)
                }))

        sheet.addAction(
            UIAlertAction(
                title: "Send audio", style: .default,
                handler: { _ in
                    self.demoData.addAudioMediaMessage()
                    self.finishSendingMessage(animated: true)
                }))

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(sheet, animated: true, completion: nil)
    }

    // MARK: - JSQMessages CollectionView DataSource

    override var senderId: String {
        return DemoModelData.kJSQDemoAvatarIdSquires
    }

    override var senderDisplayName: String {
        return DemoModelData.kJSQDemoAvatarDisplayNameSquires
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath
    ) -> JSQMessageData {
        return self.demoData.messages[indexPath.item]
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView, didDeleteMessageAt indexPath: IndexPath
    ) {
        self.demoData.messages.remove(at: indexPath.item)
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        messageBubbleImageDataForItemAt indexPath: IndexPath
    ) -> JSQMessageBubbleImageDataSource? {
        let message = self.demoData.messages[indexPath.item]

        if message.senderId == self.senderId {
            return self.demoData.outgoingBubbleImageData
        }

        return self.demoData.incomingBubbleImageData
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath
    ) -> JSQMessageAvatarImageDataSource? {
        let message = self.demoData.messages[indexPath.item]

        if message.senderId == self.senderId {
            if !UserDefaults.outgoingAvatarSetting() {
                return nil
            }
        } else {
            if !UserDefaults.incomingAvatarSetting() {
                return nil
            }
        }

        return self.demoData.avatars[message.senderId]
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        attributedTextForCellTopLabelAt indexPath: IndexPath
    ) -> NSAttributedString? {
        if indexPath.item % 3 == 0 {
            let message = self.demoData.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter.attributedTimestamp(
                for: message.date)
        }

        return nil
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath
    ) -> NSAttributedString? {
        let message = self.demoData.messages[indexPath.item]

        if message.senderId == self.senderId {
            return nil
        }

        if indexPath.item - 1 > 0 {
            let previousMessage = self.demoData.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }

        return NSAttributedString(string: message.senderDisplayName)
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        attributedTextForCellBottomLabelAt indexPath: IndexPath
    ) -> NSAttributedString? {
        return nil
    }

    // MARK: - UICollectionView DataSource

    override func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        return self.demoData.messages.count
    }

    override func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell =
            super.collectionView(collectionView, cellForItemAt: indexPath)
            as! JSQMessagesCollectionViewCell

        let msg = self.demoData.messages[indexPath.item]

        if !msg.isMediaMessage {
            if msg.senderId == self.senderId {
                cell.textView?.textColor = .black
            } else {
                cell.textView?.textColor = .white
            }

            cell.textView?.linkTextAttributes = [
                .foregroundColor: cell.textView?.textColor ?? .black,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
        }

        cell.accessoryButton?.isHidden = !self.shouldShowAccessoryButtonForMessage(msg)

        return cell
    }

    func shouldShowAccessoryButtonForMessage(_ message: JSQMessageData) -> Bool {
        return message.isMediaMessage && UserDefaults.accessoryButtonForMediaMessages()
    }

    // MARK: - JSQMessages collection view flow layout delegate

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForCellTopLabelAt indexPath: IndexPath
    ) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForMessageBubbleTopLabelAt indexPath: IndexPath
    ) -> CGFloat {
        let currentMessage = self.demoData.messages[indexPath.item]

        if currentMessage.senderId == self.senderId {
            return 0.0
        }

        if indexPath.item - 1 > 0 {
            let previousMessage = self.demoData.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }

        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForCellBottomLabelAt indexPath: IndexPath
    ) -> CGFloat {
        return 0.0
    }

    // MARK: - Responding to collection view tap events

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        header headerView: JSQMessagesLoadEarlierHeaderView,
        didTapLoadEarlierMessagesButton sender: UIButton
    ) {
        print("Load earlier messages!")
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView,
        didTapAvatarImageView avatarImageView: UIImageView, at indexPath: IndexPath
    ) {
        print("Tapped avatar!")
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath
    ) {
        print("Tapped message bubble!")
    }

    override func collectionView(
        _ collectionView: JSQMessagesCollectionView, didTapCellAt indexPath: IndexPath,
        touchLocation: CGPoint
    ) {
        print("Tapped cell at \(String(describing: touchLocation))!")
    }

    // MARK: - JSQMessagesComposerTextViewPasteDelegate methods

    func composerTextView(
        _ textView: JSQMessagesComposerTextView, shouldPasteWithSender sender: Any?
    ) -> Bool {
        if let image = UIPasteboard.general.image {
            let item = JSQPhotoMediaItem(image: image)
            let message = JSQMessage(
                senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(),
                media: item)
            self.demoData.messages.append(message)
            self.finishSendingMessage()
            return false
        }
        return true
    }

    // MARK: - JSQMessagesViewAccessoryDelegate methods

    @objc func messageView(
        _ view: JSQMessagesCollectionView, didTapAccessoryButtonAt path: IndexPath
    ) {
        print("Tapped accessory button!")
    }
}
