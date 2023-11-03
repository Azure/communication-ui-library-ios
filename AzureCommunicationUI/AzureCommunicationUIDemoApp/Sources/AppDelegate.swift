//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AppCenter
import AppCenterCrashes
import CallKit
import AzureCommunicationUICalling
import AzureCommunicationCommon
import PushKit
import AzureCommunicationCalling

@main
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate, UNUserNotificationCenterDelegate {

    static var orientationLock: UIInterfaceOrientationMask = .all

    let envConfigSubject = EnvConfigSubject()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        AppCenter.start(withAppSecret: envConfigSubject.appCenterSecret, services: [Crashes.self])
        self.setupNotifications(application: application)
        return true
    }

    public func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        CallCompositeHandler.shared.setupCallComposite(deviceToken: pushCredentials.token)
    }

    func setupNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.voipRegistration()
    }
    // Register for VoIP notifications
    func voipRegistration() {
        let mainQueue = DispatchQueue.main

        // Create a push registry object
        let voipRegistry = PKPushRegistry(queue: mainQueue)
        // Set the registry's delegate to self
        voipRegistry.delegate = self
        // Set the push type to VoIP
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
}
