//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import Combine

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true:
            self.hidden()
        case false:
            self
        }
    }

    func supportedOrientations(_ supportedOrientations: UIInterfaceOrientationMask) -> some View {
        // When rendered, export the requested orientations upward to Root
        preference(key: SupportedOrientationsPreferenceKey.self, value: supportedOrientations)
    }

    func proximitySensorEnabled(_ proximityEnabled: Bool) -> some View {
        preference(key: ProximitySensorPreferenceKey.self, value: proximityEnabled)
    }

    // Controls the application's preferred home indicator auto-hiding when this view is shown.
    func prefersHomeIndicatorAutoHidden(_ value: Bool) -> some View {
        preference(key: PrefersHomeIndicatorAutoHiddenPreferenceKey.self, value: value)
    }

    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }

    var keyboardWillShow: AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).map { _ in }
        // 0.5 delay added to allow Bottom Bar View to finish updating its position
        // so scroll view can move up by (keyboard height + Bottom Bar View height)
        .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
	}

    func flippedUpsideDown() -> some View {
        modifier(FlippedUpsideDown())
    }
}

struct FlippedUpsideDown: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.radians(Double.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}
