//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import Combine
@testable import AzureCommunicationUICalling

class UpdatableOptionsManagerTests: XCTestCase {

    var storeMock: StoreFactoryMocking!
    var updatableOptionsManager: UpdatableOptionsManager!
    var setupScreenOptions: SetupScreenOptions!
    var callScreenOptions: CallScreenOptions!
    var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        storeMock = StoreFactoryMocking()
        setupScreenOptions = SetupScreenOptions()
        callScreenOptions = CallScreenOptions()
        subscriptions = Set<AnyCancellable>()

        // Initialize the UpdatableOptionsManager with the mocks
        updatableOptionsManager = UpdatableOptionsManager(
            store: storeMock.store,
            setupScreenOptions: setupScreenOptions,
            callScreenOptions: callScreenOptions
        )
    }

    override func tearDown() {
        storeMock = nil
        setupScreenOptions = nil
        callScreenOptions = nil
        subscriptions.removeAll()
        super.tearDown()
    }

    func testCallScreenOptionsTitleUpdate() {
        // Given: An initial title
        let newTitle = "New Call Title"

        // When: Title is updated
        callScreenOptions.headerViewData?.title = newTitle

        // Then: Verify that the store dispatches the correct action
        XCTAssertEqual(storeMock.actions.last, .callScreenInfoHeaderAction(.updateTitle(title: newTitle)))
    }

    func testSetupScreenAudioDeviceButtonVisibilityUpdate() {
        // Given: A new visibility state
        let newVisibility = true

        // When: Audio device button visibility changes
        setupScreenOptions.audioDeviceButton?.visible = newVisibility

        // Then: Verify the correct dispatch action
        XCTAssertEqual(storeMock.actions.last, .buttonViewDataAction(.setupScreenAudioDeviceButtonIsVisibleUpdated(visible: newVisibility)))
    }

    func testCallScreenControlBarAudioDeviceButtonEnabledUpdate() {
        // Given: A new enabled state
        let newEnabledState = false

        // When: Control bar audio device button is enabled/disabled
        callScreenOptions.controlBarOptions?.audioDeviceButton?.enabled = newEnabledState

        // Then: Verify that the store dispatches the correct action
        XCTAssertEqual(storeMock.actions.last, .buttonViewDataAction(.callScreenAudioDeviceButtonIsEnabledUpdated(enabled: newEnabledState)))
    }
}
