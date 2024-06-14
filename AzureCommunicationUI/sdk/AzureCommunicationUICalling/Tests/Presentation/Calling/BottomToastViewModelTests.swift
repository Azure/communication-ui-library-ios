//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class BottomToastDiagnosticViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProviderMocking!
    private var accessibilityProvider: AccessibilityProviderProtocol!
    private var storeFactory: StoreFactoryMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
        accessibilityProvider = AccessibilityProviderMocking()
        storeFactory = StoreFactoryMocking()
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
        accessibilityProvider = nil
        storeFactory = nil
    }

    func test_that_presenting_handled_media_diagnostics_shows_title_and_icon() {
        let expectedTextAndIcon: [ToastNotificationKind: (String, CompositeIcon)] = [
            .speakingWhileMicrophoneIsMuted: ("AzureCommunicationUICalling.Diagnostics.Text.YouAreMuted",
                                              CompositeIcon.micOff),
            .cameraStartFailed: ("AzureCommunicationUICalling.Diagnostics.Text.CameraNotStarted",
                                 CompositeIcon.videoOffRegular),
            .cameraStartTimedOut: ("AzureCommunicationUICalling.Diagnostics.Text.CameraNotStarted",
                                   CompositeIcon.videoOffRegular),
            .networkUnavailable: ("AzureCommunicationUICalling.Diagnostics.Text.NetworkLost",
                                   CompositeIcon.wifiWarning),
            .networkRelaysUnreachable: ("AzureCommunicationUICalling.Diagnostics.Text.NetworkLost",
                                   CompositeIcon.wifiWarning),
            .networkReceiveQuality: ("AzureCommunicationUICalling.Diagnostics.Text.NetworkQualityLow",
                                   CompositeIcon.wifiWarning),
            .networkSendQuality: ("AzureCommunicationUICalling.Diagnostics.Text.NetworkQualityLow",
                                   CompositeIcon.wifiWarning),
            .networkReconnectionQuality: ("AzureCommunicationUICalling.Diagnostics.Text.NetworkReconnect",
                                   CompositeIcon.wifiWarning),
            .someFeaturesGained: ("AzureCommunicationUICalling.CallingView.Toast.FeaturesGained",
                                   CompositeIcon.warning),
            .someFeaturesLost: ("AzureCommunicationUICalling.CallingView.Toast.FeaturesLost",
                                   CompositeIcon.warning)
        ]

        for expected in expectedTextAndIcon {
            let sut = makeSUT(toastNotificationKind: expected.key)

            guard let (text, icon) = expectedTextAndIcon[expected.key] else {
                return XCTFail("Value not verified")
            }

            XCTAssertEqual(sut.text, text)
            XCTAssertEqual(sut.icon, icon)
        }
    }

}

extension BottomToastDiagnosticViewModelTests {
    func makeSUT(toastNotificationKind: ToastNotificationKind) -> BottomToastViewModel {
        return BottomToastViewModel(dispatchAction: storeFactory.store.dispatch,
                                    localizationProvider: localizationProvider,
                                    accessibilityProvider: accessibilityProvider,
                                    toastNotificationState: ToastNotificationState(status: toastNotificationKind))
    }
}
