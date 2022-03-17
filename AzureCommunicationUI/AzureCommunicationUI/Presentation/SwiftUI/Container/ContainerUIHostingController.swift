//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

class ContainerUIHostingController: UIHostingController<ContainerUIHostingController.Root> {
    class EnvironmentProperty {
        @Published var supportedOrientations: UIInterfaceOrientationMask
        @Published var isProximitySensorOn: Bool

        init() {
            self.supportedOrientations = UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown
            self.isProximitySensorOn = false
        }
    }

    private let callComposite: CallComposite
    private let environmentProperties: EnvironmentProperty
    private let cancelBag = CancelBag()

    init(rootView: ContainerView,
         callComposite: CallComposite,
         isRightToLeft: Bool) {
        let environmentProperties = EnvironmentProperty()
        let environmentRoot = Root(containerView: rootView,
                                   environmentProperties: environmentProperties)
        self.callComposite = callComposite
        self.environmentProperties = environmentProperties
        super.init(rootView: environmentRoot)
        subscribeEnvironmentProperties()
        UIView.appearance().semanticContentAttribute = isRightToLeft ?
            .forceRightToLeft : .forceLeftToRight
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        resetUIDeviceSetup()
        super.viewDidDisappear(animated)
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        self.environmentProperties.supportedOrientations
    }

    private func subscribeEnvironmentProperties() {
        environmentProperties
            .$supportedOrientations
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink(receiveValue: { orientation in
                let portrait = orientation == .portrait
                let landscape = orientation == .landscapeLeft || orientation == .landscapeRight
                if  portrait || landscape {
                    // Apply a delay here to allow the previous orientation change to finish,
                    // then reset orientations
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let rotateOrientation: UIInterfaceOrientation = orientation == .portrait ?
                            .portrait : (orientation == .landscapeLeft ? .landscapeRight : .landscapeLeft)
                        UIDevice.current.rotateTo(oritation: rotateOrientation)
                        UIDevice.current.endGeneratingDeviceOrientationNotifications()
                    }
                } else if (orientation == .all || orientation == .allButUpsideDown)
                            && !UIDevice.current.isGeneratingDeviceOrientationNotifications {
                    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                }
            }).store(in: cancelBag)

        environmentProperties
            .$isProximitySensorOn
            .receive(on: RunLoop.main)
            .sink(receiveValue: { isEnable in
                UIDevice.current.toggleProximityMonitoringStatus(isEnabled: isEnable)
            }).store(in: cancelBag)
    }

    private func resetUIDeviceSetup() {
        UIApplication.shared.isIdleTimerDisabled = false
        UIDevice.current.toggleProximityMonitoringStatus(isEnabled: false)

        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
    }

    struct Root: View {
        let containerView: ContainerView
        let environmentProperties: EnvironmentProperty

        var body: some View {
            containerView
                .onPreferenceChange(SupportedOrientationsPreferenceKey.self) {
                    // Update the binding to set the value on the root controller.
                    self.environmentProperties.supportedOrientations = $0
                }
                .onPreferenceChange(ProximitySensorPreferenceKey.self) {
                    self.environmentProperties.isProximitySensorOn = $0
                }
        }
    }
}
