//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI
import Intents

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    fileprivate func assignCallID(_ callID: String, _ appDelegate: AppDelegate) {
        if callID.contains("http") {
            appDelegate.envConfigSubject.teamsMeetingLink = callID
            appDelegate.envConfigSubject.selectedMeetingType = .teamsMeeting
        } else {
            appDelegate.envConfigSubject.groupCallId = callID
            appDelegate.envConfigSubject.selectedMeetingType = .groupCall
        }
    }

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene),
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let entryViewController = EntryViewController(envConfigSubject: appDelegate.envConfigSubject)
        let rootNavController = UINavigationController(rootViewController: entryViewController)
        let userActivity = connectionOptions.userActivities.first
        if let intent = userActivity?.interaction?.intent as? INStartCallIntent,
           let callID = intent.contacts?.first?.personHandle?.value {
            assignCallID(callID, appDelegate)
        }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootNavController
        self.window = window
        window.makeKeyAndVisible()

        // Handle deep link jump from re-launch
        let urlContexts = connectionOptions.urlContexts
        if let queryDict = urlContexts.first?.url.toQueryDictionary() {
           appDelegate.envConfigSubject.update(from: queryDict)
        } else {
            appDelegate.envConfigSubject.load()
        }
    }

    func scene(_ scene: UIScene,
               openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let queryDict = URLContexts.first?.url.toQueryDictionary(),
           let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.envConfigSubject.update(from: queryDict)
        } else {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.envConfigSubject.load()
            }
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let intent = userActivity.interaction?.intent as? INStartCallIntent,
           let callID = intent.contacts?.first?.personHandle?.value,
           let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            assignCallID(callID, appDelegate)
        }
    }
}
