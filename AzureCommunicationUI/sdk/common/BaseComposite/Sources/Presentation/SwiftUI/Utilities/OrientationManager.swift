//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import Combine

@propertyWrapper struct Orientation: DynamicProperty {
    @StateObject private var manager: OrientationManager = .shared

    var wrappedValue: UIDeviceOrientation {
        manager.type
    }
}

class OrientationManager: ObservableObject {
    @Published var type: UIDeviceOrientation = .unknown
    static let shared = OrientationManager()
    private var cancellables: Set<AnyCancellable> = []

    init() {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let sceneDelegate = scene as? UIWindowScene else {
            return
        }

        let orientation = sceneDelegate.interfaceOrientation

        switch orientation {
        case .portrait:
            type = .portrait
        case .portraitUpsideDown:
            type = .portraitUpsideDown
        case .landscapeLeft:
            type = .landscapeLeft
        case .landscapeRight:
            type = .landscapeRight
        default:
            type = .unknown
        }

        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                self?.type = UIDevice.current.orientation
            }
            .store(in: &cancellables)
    }
}
