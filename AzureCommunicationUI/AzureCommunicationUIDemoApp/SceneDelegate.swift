//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var entryViewController = EntryViewController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let rootNC = UINavigationController(rootViewController: entryViewController)
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootNC// Your RootViewController in here
        self.window = window
        window.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {

        // Group call = acsui://calling?acstoken={}&name={}&groupid={}
        // Teams call = acsui://calling?acstoken={}&name={}&teamsurl={}
        let queryDict = URLContexts.first?.url.queryDictionary ?? [:]
        lazy var deepLinkCoordinator = DeepLinkData()
        let swiftUiDemoView = SwiftUIDemoView()
            .environment(\.deepLinkCoordinator, deepLinkCoordinator)
        deepLinkCoordinator.deepLinkValues = queryDict
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: swiftUiDemoView)
        self.window = window
        window.makeKeyAndVisible()
    }
}

class DeepLinkData {
    @Published var deepLinkValues: [String:String] = [:]
}

struct DeepLinkKey: EnvironmentKey {
    static let defaultValue: DeepLinkData = DeepLinkData()
}

extension EnvironmentValues {
    var deepLinkCoordinator: DeepLinkData {
        get { self[DeepLinkKey.self] }
        set { self[DeepLinkKey.self] = newValue }
    }
}
