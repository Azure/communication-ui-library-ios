//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class LoadingOverlayViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProviderMocking!
    private var storeFactory: StoreFactoryMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
        storeFactory = StoreFactoryMocking()
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
        storeFactory = nil
    }

    func test_loadingOverlayViewModel_displays_title_from_AppLocalization() {
        let sut = makeSUT()
        XCTAssertEqual(sut.title, "Joining call…")
    }

    func test_loadingOverlayViewModel_displays_false_for_init() {
        let sut = makeSUT()
        XCTAssertEqual(sut.isDisplayed, false)
    }

    func test_loadingOverlayViewModel_displays_true_for_connecting() {
        let sut = makeSUT()
        let callingState = CallingState(status: .connecting,
                                        operationStatus: .skipSetupRequested,
                                        isRecordingActive: true,
                                        isTranscriptionActive: true)
        let appState = AppState(callingState: callingState)
        sut.receive(appState)
        XCTAssertEqual(sut.isDisplayed, true)
    }

    func test_loadingOverlayViewModel_displays_true_for_connected() {
        let sut = makeSUT()
        let callingState = CallingState(status: .connected,
                                        operationStatus: .skipSetupRequested,
                                        isRecordingActive: true,
                                        isTranscriptionActive: true)
        let appState = AppState(callingState: callingState)
        sut.receive(appState)
        XCTAssertEqual(sut.isDisplayed, false)
    }
}

extension LoadingOverlayViewModelTests {
    func makeSUT(localizationProvider: LocalizationProviderMocking? = nil) -> LoadingOverlayViewModel {
        return LoadingOverlayViewModel(localizationProvider: localizationProvider ?? LocalizationProvider(logger: LoggerMocking()),
                                     accessibilityProvider: AccessibilityProviderMocking(),
                                       networkManager: NetworkManager(),
                                       audioSessionManager: AudioSessionManager(store: storeFactory.store, logger: LoggerMocking(), isCallKitEnabled: false),
                                       themeOptions: MockThemeOptions(),
                                       store: storeFactory.store,
                                       callType: .groupCall
        )
    }

    func makeSUTLocalizationMocking() -> LoadingOverlayViewModel {
        return makeSUT(localizationProvider: localizationProvider)
    }
}
