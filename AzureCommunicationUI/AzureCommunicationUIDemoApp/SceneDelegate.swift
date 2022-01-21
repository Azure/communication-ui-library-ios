//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let envConfigSubject = EnvConfigSubject()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let entryViewController = EntryViewController(envConfigSubject: envConfigSubject)
        let rootNavController = UINavigationController(rootViewController: entryViewController)
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootNavController
        self.window = window
        window.makeKeyAndVisible()

        //Handle deep link jump from re-launch
        let urlContexts = connectionOptions.urlContexts
        if let queryDict = urlContexts.first?.url.toEnvConfigureDictionary() {
            print("------------------scene openURL")
            envConfigSubject.update(from: queryDict)
        }

    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {

        if let queryDict = URLContexts.first?.url.toEnvConfigureDictionary() {
            print("------------------scene openURL")
            envConfigSubject.update(from: queryDict)
        }
    }
}
