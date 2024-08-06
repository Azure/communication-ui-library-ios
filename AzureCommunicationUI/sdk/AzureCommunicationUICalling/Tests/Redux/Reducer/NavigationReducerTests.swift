//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class NavigationReducerTests: XCTestCase {

    func test_navigationReducer_reduce_when_callingActionStateUpdatedNotDisconnected_then_stateNotUpdated() {
        let expectedState = NavigationState(status: .setup)
        let state = NavigationState(status: .setup)
        let action = Action.callingAction(.stateUpdated(status: .connected,
                                                        callEndReasonCode: nil,
                                                        callEndReasonSubCode: nil))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_compositexitaction_then_stateExitUpdated() {
        let expectedState = NavigationState(status: .exit)
        let state = NavigationState(status: .setup)
        let action = Action.compositeExitAction
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_callingViewLaunched_then_stateinCallUpdated() {
        let expectedState = NavigationState(status: .inCall)
        let state = NavigationState(status: .exit)
        let action = Action.callingViewLaunched
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_action_not_applicable_then_stateNotUpdate() {
        let expectedState = NavigationState(status: .inCall)
        let action = Action.audioSessionAction(.audioInterruptEnded)
        let sut = makeSUT()
        let resultState = sut.reduce(expectedState, action)
        XCTAssertEqual(resultState, expectedState)
    }

    func test_navigationReducer_reduce_when_showSupportForm_then_supportFormVisible() {
        let expectedState = NavigationState(supportFormVisible: true)
        let state = NavigationState()
        let action = Action.showSupportForm
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.supportFormVisible, expectedState.supportFormVisible)
        XCTAssertFalse(resultState.supportShareSheetVisible)
        XCTAssertFalse(resultState.audioSelectionVisible)
        XCTAssertFalse(resultState.endCallConfirmationVisible)
        XCTAssertFalse(resultState.moreOptionsVisible)
    }

    func test_navigationReducer_reduce_when_hideSupportForm_then_supportFormNotVisible() {
        let expectedState = NavigationState(supportFormVisible: false)
        let state = NavigationState(supportFormVisible: true)
        let action = Action.hideDrawer
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.supportFormVisible, expectedState.supportFormVisible)
    }

    func test_navigationReducer_reduce_when_showEndCallConfirmation_then_endCallConfirmationVisible() {
        let expectedState = NavigationState(endCallConfirmationVisible: true)
        let state = NavigationState()
        let action = Action.showEndCallConfirmation
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.endCallConfirmationVisible, expectedState.endCallConfirmationVisible)
        XCTAssertFalse(resultState.supportFormVisible)
        XCTAssertFalse(resultState.supportShareSheetVisible)
        XCTAssertFalse(resultState.audioSelectionVisible)
        XCTAssertFalse(resultState.moreOptionsVisible)
    }

    func test_navigationReducer_reduce_when_hideEndCallConfirmation_then_endCallConfirmationNotVisible() {
        let expectedState = NavigationState(endCallConfirmationVisible: false)
        let state = NavigationState(endCallConfirmationVisible: true)
        let action = Action.hideDrawer
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.endCallConfirmationVisible, expectedState.endCallConfirmationVisible)
    }

    func test_navigationReducer_reduce_when_showMoreOptions_then_moreOptionsVisible() {
        let expectedState = NavigationState(moreOptionsVisible: true)
        let state = NavigationState()
        let action = Action.showMoreOptions
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.moreOptionsVisible, expectedState.moreOptionsVisible)
        XCTAssertFalse(resultState.supportFormVisible)
        XCTAssertFalse(resultState.supportShareSheetVisible)
        XCTAssertFalse(resultState.audioSelectionVisible)
        XCTAssertFalse(resultState.endCallConfirmationVisible)
    }

    func test_navigationReducer_reduce_when_hideMoreOptions_then_moreOptionsNotVisible() {
        let expectedState = NavigationState(moreOptionsVisible: false)
        let state = NavigationState(moreOptionsVisible: true)
        let action = Action.hideDrawer
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.moreOptionsVisible, expectedState.moreOptionsVisible)
    }

    func test_navigationReducer_reduce_when_showAudioSelection_then_audioSelectionVisible() {
        let expectedState = NavigationState(audioSelectionVisible: true)
        let state = NavigationState()
        let action = Action.showAudioSelection
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioSelectionVisible, expectedState.audioSelectionVisible)
        XCTAssertFalse(resultState.supportFormVisible)
        XCTAssertFalse(resultState.supportShareSheetVisible)
        XCTAssertFalse(resultState.endCallConfirmationVisible)
        XCTAssertFalse(resultState.moreOptionsVisible)
    }

    func test_navigationReducer_reduce_when_hideAudioSelection_then_audioSelectionNotVisible() {
        let expectedState = NavigationState(audioSelectionVisible: false)
        let state = NavigationState(audioSelectionVisible: true)
        let action = Action.hideDrawer
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioSelectionVisible, expectedState.audioSelectionVisible)
    }

    func test_navigationReducer_reduce_when_showSupportShare_then_supportShareSheetVisible() {
        let expectedState = NavigationState(supportShareSheetVisible: true)
        let state = NavigationState()
        let action = Action.showSupportShare
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.supportShareSheetVisible, expectedState.supportShareSheetVisible)
        XCTAssertFalse(resultState.supportFormVisible)
        XCTAssertFalse(resultState.audioSelectionVisible)
        XCTAssertFalse(resultState.endCallConfirmationVisible)
        XCTAssertFalse(resultState.moreOptionsVisible)
    }

    func test_navigationReducer_reduce_when_hideSupportShare_then_supportShareSheetNotVisible() {
        let expectedState = NavigationState(supportShareSheetVisible: false)
        let state = NavigationState(supportShareSheetVisible: true)
        let action = Action.hideDrawer
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.supportShareSheetVisible, expectedState.supportShareSheetVisible)
    }

    func test_navigationReducer_reduce_when_audioDeviceChangeRequested_then_audioSelectionNotVisible() {
        let expectedState = NavigationState(audioSelectionVisible: false)
        let state = NavigationState(audioSelectionVisible: true)
        let action = Action.localUserAction(.audioDeviceChangeRequested(device: .bluetooth))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.audioSelectionVisible, expectedState.audioSelectionVisible)
    }

    func test_navigationReducer_reduce_when_showCaptionsList_then_captionsListVisible() {
        let expectedState = NavigationState(captionsViewVisible: true)
        let state = NavigationState()
        let action = Action.showCaptionsListView
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.captionsViewVisible, expectedState.captionsViewVisible)
        XCTAssertFalse(resultState.supportFormVisible)
        XCTAssertFalse(resultState.supportShareSheetVisible)
        XCTAssertFalse(resultState.audioSelectionVisible)
        XCTAssertFalse(resultState.endCallConfirmationVisible)
    }

    func test_navigationReducer_reduce_when_hideCaptionsList_then_CaptionsListNotVisible() {
        let expectedState = NavigationState(captionsViewVisible: false)
        let state = NavigationState(captionsViewVisible: true)
        let action = Action.hideDrawer
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.captionsViewVisible, expectedState.captionsViewVisible)
    }

    func test_navigationReducer_reduce_when_showCaptionsLanguageList_then_captionsLanguageListVisible() {
        let expectedState = NavigationState(captionsLanguageViewVisible: true)
        let state = NavigationState()
        let action = Action.showCaptionsLanguageView
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.captionsLanguageViewVisible, expectedState.captionsLanguageViewVisible)
        XCTAssertFalse(resultState.supportFormVisible)
        XCTAssertFalse(resultState.supportShareSheetVisible)
        XCTAssertFalse(resultState.audioSelectionVisible)
        XCTAssertFalse(resultState.endCallConfirmationVisible)
    }

    func test_navigationReducer_reduce_when_hideCaptionsLanguageList_then_captionsLanguageListNotVisible() {
        let expectedState = NavigationState(captionsLanguageViewVisible: false)
        let state = NavigationState(captionsLanguageViewVisible: true)
        let action = Action.hideDrawer
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.captionsLanguageViewVisible, expectedState.captionsLanguageViewVisible)
    }

    func test_navigationReducer_reduce_when_showSpokenLanguageList_then_spokenLanguageListVisible() {
        let expectedState = NavigationState(spokenLanguageViewVisible: true)
        let state = NavigationState()
        let action = Action.showSpokenLanguageView
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.spokenLanguageViewVisible, expectedState.spokenLanguageViewVisible)
        XCTAssertFalse(resultState.supportFormVisible)
        XCTAssertFalse(resultState.supportShareSheetVisible)
        XCTAssertFalse(resultState.audioSelectionVisible)
        XCTAssertFalse(resultState.endCallConfirmationVisible)
    }

    func test_navigationReducer_reduce_when_hideSpokenLanguageList_then_spokenLanguageListNotVisible() {
        let expectedState = NavigationState(spokenLanguageViewVisible: false)
        let state = NavigationState(spokenLanguageViewVisible: true)
        let action = Action.hideDrawer
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.spokenLanguageViewVisible, expectedState.spokenLanguageViewVisible)
    }
}

extension NavigationReducerTests {
    private func makeSUT() -> Reducer<NavigationState, Action> {
        return .liveNavigationReducer
    }
}
