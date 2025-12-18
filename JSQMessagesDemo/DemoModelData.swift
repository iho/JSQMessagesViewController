//
//  DemoModelData.swift
//  JSQMessagesDemo
//

import CoreLocation
import Foundation
import JSQMessages
import UIKit

class DemoModelData {

    var messages: [JSQMessage] = []

    var avatars: [String: JSQMessagesAvatarImage] = [:]
    var users: [String: String] = [:]

    var outgoingBubbleImageData: JSQMessagesBubbleImage
    var incomingBubbleImageData: JSQMessagesBubbleImage

    static let kJSQDemoAvatarDisplayNameSquires = "Jesse Squires"
    static let kJSQDemoAvatarDisplayNameCook = "Tim Cook"
    static let kJSQDemoAvatarDisplayNameJobs = "Jobs"
    static let kJSQDemoAvatarDisplayNameWoz = "Steve Wozniak"

    static let kJSQDemoAvatarIdSquires = "053496-4509-289"
    static let kJSQDemoAvatarIdCook = "468-768355-23123"
    static let kJSQDemoAvatarIdJobs = "707-8956784-57"
    static let kJSQDemoAvatarIdWoz = "309-41802-93823"

    init() {
        // Init bubbles first
        let bubbleFactory = JSQMessagesBubbleImageFactory()

        self.outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleLightGray())
        self.incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleGreen())

        // Init users and avatars
        self.users = [
            DemoModelData.kJSQDemoAvatarIdSquires: DemoModelData.kJSQDemoAvatarDisplayNameSquires,
            DemoModelData.kJSQDemoAvatarIdCook: DemoModelData.kJSQDemoAvatarDisplayNameCook,
            DemoModelData.kJSQDemoAvatarIdJobs: DemoModelData.kJSQDemoAvatarDisplayNameJobs,
            DemoModelData.kJSQDemoAvatarIdWoz: DemoModelData.kJSQDemoAvatarDisplayNameWoz,
        ]

        let factory = JSQMessagesAvatarImageFactory()
        let jsqImage = factory.avatarImage(with: UIImage(named: "demo_avatar_jobs")!)
        let cookImage = factory.avatarImage(with: UIImage(named: "demo_avatar_cook")!)
        let jobsImage = factory.avatarImage(with: UIImage(named: "demo_avatar_jobs")!)
        let wozImage = factory.avatarImage(with: UIImage(named: "demo_avatar_woz")!)

        self.avatars = [
            DemoModelData.kJSQDemoAvatarIdSquires: jsqImage,
            DemoModelData.kJSQDemoAvatarIdCook: cookImage,
            DemoModelData.kJSQDemoAvatarIdJobs: jobsImage,
            DemoModelData.kJSQDemoAvatarIdWoz: wozImage,
        ]

        if !UserDefaults.emptyMessagesSetting() {
            self.loadFakeMessages()
        }
    }

    func loadFakeMessages() {
        self.messages = [
            JSQMessage(
                senderId: DemoModelData.kJSQDemoAvatarIdSquires,
                displayName: DemoModelData.kJSQDemoAvatarDisplayNameSquires,
                text: "Welcome to JSQMessages: A messaging UI framework for iOS."),
            JSQMessage(
                senderId: DemoModelData.kJSQDemoAvatarIdWoz,
                displayName: DemoModelData.kJSQDemoAvatarDisplayNameWoz,
                text:
                    "It is simple, elegant, and modular. It gives you absolute control over your messaging UI."
            ),
            JSQMessage(
                senderId: DemoModelData.kJSQDemoAvatarIdSquires,
                displayName: DemoModelData.kJSQDemoAvatarDisplayNameSquires,
                text: "It is available for you, for free, under the MIT license."),
            JSQMessage(
                senderId: DemoModelData.kJSQDemoAvatarIdJobs,
                displayName: DemoModelData.kJSQDemoAvatarDisplayNameJobs,
                text: "It is open source and easy to use."),
        ]

        // Add more fake messages matching ObjC implementation including dates if needed,
        // but for simplicity we rely on default Date() which is 'now'.
        // To match ObjC perfectly we might want to iterate dates.

        let today = Date()
        self.messages.append(
            JSQMessage(
                senderId: DemoModelData.kJSQDemoAvatarIdSquires,
                senderDisplayName: DemoModelData.kJSQDemoAvatarDisplayNameSquires, date: today,
                text: "4 години, з вас 500 баксів."))
        self.messages.append(
            JSQMessage(
                senderId: DemoModelData.kJSQDemoAvatarIdCook,
                senderDisplayName: DemoModelData.kJSQDemoAvatarDisplayNameCook, date: today,
                text: "Краще ніж в Апола."))
        self.messages.append(
            JSQMessage(
                senderId: DemoModelData.kJSQDemoAvatarIdSquires,
                senderDisplayName: DemoModelData.kJSQDemoAvatarDisplayNameSquires, date: today,
                text: "Ну це вже не шось подібно."))
        self.messages.append(
            JSQMessage(
                senderId: DemoModelData.kJSQDemoAvatarIdSquires,
                senderDisplayName: DemoModelData.kJSQDemoAvatarDisplayNameSquires, date: today,
                text: "Заєбок!"))

        self.addPhotoMediaMessage()
        self.addAudioMediaMessage()

        if UserDefaults.extraMessagesSetting() {
            let copy = self.messages
            for _ in 0..<4 {
                self.messages.append(contentsOf: copy)
            }
        }

        if UserDefaults.longMessageSetting() {
            let longText =
                "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? END Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? END"
            let msg = JSQMessage(
                senderId: DemoModelData.kJSQDemoAvatarIdSquires,
                displayName: DemoModelData.kJSQDemoAvatarDisplayNameSquires, text: longText)
            self.messages.append(msg)
        }
    }

    func addAudioMediaMessage() {
        guard let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
        else { return }
        guard let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample)) else { return }
        let audioItem = JSQAudioMediaItem(data: audioData)
        let audioMessage = JSQMessage(
            senderId: DemoModelData.kJSQDemoAvatarIdSquires,
            displayName: DemoModelData.kJSQDemoAvatarDisplayNameSquires, media: audioItem)
        self.messages.append(audioMessage)
    }

    func addPhotoMediaMessage() {
        let photoItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
        let photoMessage = JSQMessage(
            senderId: DemoModelData.kJSQDemoAvatarIdSquires,
            displayName: DemoModelData.kJSQDemoAvatarDisplayNameSquires, media: photoItem)
        self.messages.append(photoMessage)
    }

    func addLocationMediaMessage(completion: @escaping JSQLocationMediaItemCompletionBlock) {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF, withCompletionHandler: completion)

        let locationMessage = JSQMessage(
            senderId: DemoModelData.kJSQDemoAvatarIdSquires,
            displayName: DemoModelData.kJSQDemoAvatarDisplayNameSquires, media: locationItem)
        self.messages.append(locationMessage)
    }

    func addVideoMediaMessage() {
        let videoURL = URL(string: "file://")!
        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
        let videoMessage = JSQMessage(
            senderId: DemoModelData.kJSQDemoAvatarIdSquires,
            displayName: DemoModelData.kJSQDemoAvatarDisplayNameSquires, media: videoItem)
        self.messages.append(videoMessage)
    }

    func addVideoMediaMessageWithThumbnail() {
        let videoURL = URL(string: "file://")!
        let videoItem = JSQVideoMediaItem(
            fileURL: videoURL, isReadyToPlay: true, thumbnailImage: UIImage(named: "goldengate"))
        let videoMessage = JSQMessage(
            senderId: DemoModelData.kJSQDemoAvatarIdSquires,
            displayName: DemoModelData.kJSQDemoAvatarDisplayNameSquires, media: videoItem)
        self.messages.append(videoMessage)
    }
}
