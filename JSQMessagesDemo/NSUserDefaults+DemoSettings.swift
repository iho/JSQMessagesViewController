//
//  NSUserDefaults+DemoSettings.swift
//  JSQMessagesDemo
//

import Foundation

extension UserDefaults {
    private static let kJSQDemoSettingsExtraMessages = "kJSQDemoSettingsExtraMessages"
    private static let kJSQDemoSettingsLongMessage = "kJSQDemoSettingsLongMessage"
    private static let kJSQDemoSettingsEmptyMessages = "kJSQDemoSettingsEmptyMessages"
    private static let kJSQDemoSettingsAccessoryButtonForMediaMessages =
        "kJSQDemoSettingsAccessoryButtonForMediaMessages"
    private static let kJSQDemoSettingsSplinginess = "kJSQDemoSettingsSplinginess"
    private static let kJSQDemoSettingsIncomingAvatar = "kJSQDemoSettingsIncomingAvatar"
    private static let kJSQDemoSettingsOutgoingAvatar = "kJSQDemoSettingsOutgoingAvatar"

    static func saveExtraMessagesSetting(_ value: Bool) {
        standard.set(value, forKey: kJSQDemoSettingsExtraMessages)
    }

    static func extraMessagesSetting() -> Bool {
        return standard.bool(forKey: kJSQDemoSettingsExtraMessages)
    }

    static func saveLongMessageSetting(_ value: Bool) {
        standard.set(value, forKey: kJSQDemoSettingsLongMessage)
    }

    static func longMessageSetting() -> Bool {
        return standard.bool(forKey: kJSQDemoSettingsLongMessage)
    }

    static func saveEmptyMessagesSetting(_ value: Bool) {
        standard.set(value, forKey: kJSQDemoSettingsEmptyMessages)
    }

    static func emptyMessagesSetting() -> Bool {
        return standard.bool(forKey: kJSQDemoSettingsEmptyMessages)
    }

    static func saveAccessoryButtonForMediaMessages(_ value: Bool) {
        standard.set(value, forKey: kJSQDemoSettingsAccessoryButtonForMediaMessages)
    }

    static func accessoryButtonForMediaMessages() -> Bool {
        return standard.bool(forKey: kJSQDemoSettingsAccessoryButtonForMediaMessages)
    }

    static func saveSpringinessSetting(_ value: Bool) {
        standard.set(value, forKey: kJSQDemoSettingsSplinginess)
    }

    static func springinessSetting() -> Bool {
        return standard.bool(forKey: kJSQDemoSettingsSplinginess)
    }

    static func saveIncomingAvatarSetting(_ value: Bool) {
        standard.set(value, forKey: kJSQDemoSettingsIncomingAvatar)
    }

    static func incomingAvatarSetting() -> Bool {
        return standard.bool(forKey: kJSQDemoSettingsIncomingAvatar)
    }

    static func saveOutgoingAvatarSetting(_ value: Bool) {
        standard.set(value, forKey: kJSQDemoSettingsOutgoingAvatar)
    }

    static func outgoingAvatarSetting() -> Bool {
        return standard.bool(forKey: kJSQDemoSettingsOutgoingAvatar)
    }
}
