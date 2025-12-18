//
//  AppDelegate.swift
//  JSQMessagesDemo
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        UserDefaults.saveIncomingAvatarSetting(true)
        UserDefaults.saveOutgoingAvatarSetting(true)

        // Create window and load initial view controller from storyboard
        self.window = UIWindow(frame: UIScreen.main.bounds)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()

        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()

        return true
    }
}
