//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
// swiftlint:disable multiline_parameters
import UIKit
import AppCenter
import AppCenterCrashes
import AzureCommunicationUICalling
import AzureCommunicationCommon
import PushKit
import AzureCommunicationCalling

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, PKPushRegistryDelegate {

    let appPubs = AppPubs()

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        appPubs.pushToken = registry.pushToken(for: .voIP) ?? nil
        envConfigSubject.deviceToken = appPubs.pushToken ?? nil
        let callCompositeOptions = CallCompositeOptions(deviceToken: envConfigSubject.deviceToken)
        let callComposite = CallComposite(withOptions: callCompositeOptions)
        let acsToken = envConfigSubject.useExpiredToken ?
                       envConfigSubject.expiredAcsToken : envConfigSubject.acsToken
        if let communicationTokenCredential = try? CommunicationTokenCredential(token: acsToken) {
            DispatchQueue.main.async {
                Task {
                    await callComposite.registerPushNotifications(credential: communicationTokenCredential)
                }
            }
        }
    }

    private func createProviderConfig() -> CXProviderConfiguration {
        let providerConfig = CXProviderConfiguration()
        providerConfig.supportsVideo = true
        providerConfig.maximumCallGroups = 1
        providerConfig.maximumCallsPerCallGroup = 1
        providerConfig.includesCallsInRecents = true
        providerConfig.supportedHandleTypes = [.phoneNumber, .generic]
        return providerConfig
    }

    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType, completion: @escaping () -> Void) {
        let callNotification = PushNotificationInfo.fromDictionary(payload.dictionaryPayload)
        let userDefaults: UserDefaults = .standard
        let callKitOptions = CallKitOptions(with: createProviderConfig())
        let callCompositeOptions = CallCompositeOptions(deviceToken: envConfigSubject.deviceToken)
        let callComposite = CallComposite(withOptions: callCompositeOptions)
        let acsToken = envConfigSubject.useExpiredToken ?
                       envConfigSubject.expiredAcsToken : envConfigSubject.acsToken

        let localOptions = LocalOptions(skipSetupScreen: true)

        callComposite.events.onCallStateChanged = { _ in
            // callComposite.presentUI()
        }

        // when we call this callkit will show notification with accept or decline
        CallClient.reportIncomingCall(with: callNotification, callKitOptions: callKitOptions) { error in
            if error == nil {
                if let communicationTokenCredential = try? CommunicationTokenCredential(token: acsToken) {
                    Task {
                        try await callComposite.launch(remoteOptions: RemoteOptions(for:
                                .incomingCall(pushNotificationInfo: callNotification, acceptIncomingCall: true),
                                                     credential: communicationTokenCredential,
                                                     displayName: "IPS"),
                        localOptions: localOptions,
                        pushNotificationInfo: callNotification)
                    }
                }
                self.appPubs.pushPayload = payload
            }
        }
    }

    static var orientationLock: UIInterfaceOrientationMask = .all

    let envConfigSubject = EnvConfigSubject()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        AppCenter.start(withAppSecret: envConfigSubject.appCenterSecret, services: [Crashes.self])
        self.setupFirebaseNotifications(application: application)
        return true
    }
    func setupFirebaseNotifications(application: UIApplication) {
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

    // MARK: UISceneSession Lifecycle

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

class AppPubs {
    init() {
        self.pushPayload = nil
        self.pushToken = nil
    }

    @Published var pushPayload: PKPushPayload?
    @Published var pushToken: Data?
}
