//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class InfoHeaderViewModelTests: XCTestCase {

    typealias ParticipantsListViewModelUpdateStates = (LocalUserState, RemoteParticipantsState, Bool) -> Void
    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var localizationProvider: LocalizationProviderMocking!
    var logger: LoggerMocking!
    var factoryMocking: CompositeViewModelFactoryMocking!

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        localizationProvider = LocalizationProviderMocking()
        logger = LoggerMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store,
                                                          avatarManager: AvatarViewManagerMocking(
                                                            store: storeFactory.store,
                                                            localParticipantId: createCommunicationIdentifier(fromRawId: ""),
                                                            localParticipantViewData: nil),
                                                          updatableOptionsManager: UpdatableOptionsManager(store: storeFactory.store, setupScreenOptions: nil, callScreenOptions: nil))
    }

    override func tearDown() {
        super.tearDown()
        storeFactory = nil
        cancellable = nil
        localizationProvider = nil
        logger = nil
        factoryMocking = nil
    }

    func test_infoHeaderViewModel_update_when_participantInfoListCountSame_then_shouldNotBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should not publish infoLabel")
        expectation.isInverted = true
        sut.$title
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("participantInfoList count is same and infoLabel should not publish")
            }).store(in: cancellable)

        let participantInfoModel: [ParticipantInfoModel] = []
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        sut.update(localUserState: storeFactory.store.state.localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   callScreenInfoHeaderState: CallScreenInfoHeaderState()
                   /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0>
                   ,
                   buttonViewDataState: ButtonViewDataState()
                   </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
                    )

        XCTAssertEqual(sut.title, "Waiting for others to join")
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_update_when_participantInfoListCountChanged_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish infoLabel")
        sut.$title
            .dropFirst()
            .sink(receiveValue: { infoLabel in
                XCTAssertEqual(infoLabel, "Call with 1 person")
                expectation.fulfill()
            }).store(in: cancellable)

        let participantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: [participantInfoModel], lastUpdateTimeStamp: Date(), totalParticipantCount: 1)

        XCTAssertEqual(sut.title, "Waiting for others to join")
        sut.update(localUserState: storeFactory.store.state.localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   callScreenInfoHeaderState: CallScreenInfoHeaderState()
                   /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0>
                   ,
                   buttonViewDataState: ButtonViewDataState()
                   </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
        )
        XCTAssertEqual(sut.title, "Call with 1 person")

        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_update_when_multipleParticipantInfoListCountChanged_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish infoLabel")
        sut.$title
            .dropFirst()
            .sink(receiveValue: { infoLabel in
                XCTAssertEqual(infoLabel, "Call with 2 people")
                expectation.fulfill()
            }).store(in: cancellable)

        var participantList: [ParticipantInfoModel] = []
        let firstParticipantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        participantList.append(firstParticipantInfoModel)

        let secondParticipantInfoModel = ParticipantInfoModel(
            displayName: "Participant 2",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        participantList.append(secondParticipantInfoModel)

        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantList, lastUpdateTimeStamp: Date(), totalParticipantCount: 2)

        XCTAssertEqual(sut.title, "Waiting for others to join")
        sut.update(localUserState: storeFactory.store.state.localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   callScreenInfoHeaderState: CallScreenInfoHeaderState()
                   /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0>
                   ,
                   buttonViewDataState: ButtonViewDataState()
                   </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
        )
        XCTAssertEqual(sut.title, "Call with 2 people")

        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_update_when_multipleParticipantInfoListCountChanged_then_shouldBePublishedWithoutInLobbyNorDisconnected() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish infoLabel")
        sut.$title
            .dropFirst()
            .sink(receiveValue: { infoLabel in
                XCTAssertEqual(infoLabel, "Call with 1 person")
                expectation.fulfill()
            }).store(in: cancellable)

        var participantList: [ParticipantInfoModel] = []

        let participant1 = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        participantList.append(participant1)

        let participant2 = ParticipantInfoModel(
            displayName: "Participant 2",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier2",
            status: .inLobby,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        participantList.append(participant2)

        let participant3 = ParticipantInfoModel(
            displayName: "Participant 3",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier3",
            status: .disconnected,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        participantList.append(participant3)

        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantList, lastUpdateTimeStamp: Date(), totalParticipantCount: 3)

        XCTAssertEqual(sut.title, "Waiting for others to join")
        sut.update(localUserState: storeFactory.store.state.localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   callScreenInfoHeaderState: CallScreenInfoHeaderState()
                   /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0>
                   ,
                   buttonViewDataState: ButtonViewDataState()
                   </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
        )
        XCTAssertEqual(sut.title, "Call with 1 person")

        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_toggleDisplayInfoHeader_when_isInfoHeaderDisplayedFalse_then_shouldBecomeTrueAndPublish() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish isInfoHeaderDisplayed true")
        let cancel = sut.$isInfoHeaderDisplayed
            .dropFirst(2)
            .sink(receiveValue: { isInfoHeaderDisplayed in
                XCTAssertTrue(isInfoHeaderDisplayed)
                expectation.fulfill()
            })

        sut.isInfoHeaderDisplayed = false
        XCTAssertFalse(sut.isInfoHeaderDisplayed)
        sut.toggleDisplayInfoHeaderIfNeeded()
        XCTAssertTrue(sut.isInfoHeaderDisplayed)
        cancel.cancel()
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_toggleDisplayInfoHeader_when_isInfoHeaderDisplayedTrue_then_shouldBecomeFalseAndPublish() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish isInfoHeaderDisplayed false")
        let cancel = sut.$isInfoHeaderDisplayed
            .dropFirst(2)
            .sink(receiveValue: { isInfoHeaderDisplayed in
                XCTAssertFalse(isInfoHeaderDisplayed)
                expectation.fulfill()
            })

        sut.isInfoHeaderDisplayed = true
        XCTAssertTrue(sut.isInfoHeaderDisplayed)
        sut.toggleDisplayInfoHeaderIfNeeded()
        XCTAssertFalse(sut.isInfoHeaderDisplayed)
        cancel.cancel()
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_init_then_subscribedToVoiceOverStatusDidChangeNotification() {
        let expectation = XCTestExpectation(description: "Should subscribe to VoiceOverStatusDidChange notification")
        let accessibilityProvider = AccessibilityProviderMocking()
        accessibilityProvider.subscribeToVoiceOverStatusDidChangeNotificationBlock = { object in
            XCTAssertNotNil(object)
            expectation.fulfill()
        }
        _ = makeSUT(accessibilityProvider: accessibilityProvider)
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_didChangeVoiceOverStatus_when_notificationReceived_and_infoHeadeHidden_then_infoHeaderShown() {
        let accessibilityProvider = AccessibilityProviderMocking()
        accessibilityProvider.isVoiceOverEnabled = false
        let sut = makeSUT(accessibilityProvider: accessibilityProvider)
        sut.toggleDisplayInfoHeaderIfNeeded()
        XCTAssertFalse(sut.isInfoHeaderDisplayed)
        accessibilityProvider.isVoiceOverEnabled = true
        sut.didChangeVoiceOverStatus(NSNotification(name: UIAccessibility.voiceOverStatusDidChangeNotification,
                                                    object: nil))
        XCTAssertTrue(sut.isInfoHeaderDisplayed)
    }

    func test_infoHeaderViewModel_display_infoHeaderLabel0Participant_from_LocalizationMocking() {
        let sut = makeSUTLocalizationMocking()
        let expectation = XCTestExpectation(description: "Should not publish infoLabel")
        expectation.isInverted = true
        sut.$title
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("participantInfoList count is same and infoLabel should not publish")
            }).store(in: cancellable)

        let participantInfoModel: [ParticipantInfoModel] = []
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        sut.update(localUserState: storeFactory.store.state.localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   callScreenInfoHeaderState: CallScreenInfoHeaderState()
                   /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0>
                   ,
                   buttonViewDataState: ButtonViewDataState()
                   </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
        )
        let expectedInfoHeaderlabel0ParticipantKey = "AzureCommunicationUICalling.CallingView.InfoHeader.WaitingForOthersToJoin"
        XCTAssertEqual(sut.title, expectedInfoHeaderlabel0ParticipantKey)
        XCTAssertTrue(localizationProvider.isGetLocalizedStringCalled)
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_display_infoHeaderLabel2Participant_from_LocalizationMocking() {
        let sut = makeSUTLocalizationMocking()
        let expectation = XCTestExpectation(description: "Should publish infoLabel")
        let expectedInfoHeaderlabel0ParticipantKey = "AzureCommunicationUICalling.CallingView.InfoHeader.WaitingForOthersToJoin"
        let expectedInfoHeaderlabelNParticipantKey = "AzureCommunicationUICalling.CallingView.InfoHeader.CallWithNPeople"

        sut.$title
            .dropFirst()
            .sink(receiveValue: { infoLabel in
                XCTAssertEqual(infoLabel, expectedInfoHeaderlabelNParticipantKey)
                expectation.fulfill()
            }).store(in: cancellable)

        var participantList: [ParticipantInfoModel] = []
        let firstParticipantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        participantList.append(firstParticipantInfoModel)

        let secondParticipantInfoModel = ParticipantInfoModel(
            displayName: "Participant 2",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        participantList.append(secondParticipantInfoModel)

        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantList, lastUpdateTimeStamp: Date(), totalParticipantCount: 2)

        XCTAssertEqual(sut.title, expectedInfoHeaderlabel0ParticipantKey)
        XCTAssertTrue(localizationProvider.isGetLocalizedStringCalled)
        sut.update(localUserState: storeFactory.store.state.localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   callScreenInfoHeaderState: CallScreenInfoHeaderState()
                   /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0>
                   ,
                   buttonViewDataState: ButtonViewDataState()
                   </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
        )
        XCTAssertEqual(sut.title, expectedInfoHeaderlabelNParticipantKey)
        XCTAssertTrue(localizationProvider.isGetLocalizedStringWithArgsCalled)

        wait(for: [expectation], timeout: 1)
    }
    /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0>
    func test_infoHeaderViewModel_display_infoHeader_customButtonsDisplayed() {
        let sut = makeSUTLocalizationMocking()
        let expectation = XCTestExpectation(description: "Should display custom button")

        let customButton1 = CustomButtonState(id: "1", enabled: true, visible: true, image: UIImage(), title: "Button 1")

        sut.$customButton1ViewModel
            .dropFirst()
            .sink(receiveValue: { iconButtonViewModel in
                XCTAssertEqual(customButton1.image, iconButtonViewModel?.icon)
                XCTAssertEqual(customButton1.title, iconButtonViewModel?.accessibilityLabel)
                XCTAssertEqual(!customButton1.enabled, iconButtonViewModel?.isDisabled)
                XCTAssertEqual(customButton1.visible, iconButtonViewModel?.isVisible)
                expectation.fulfill()
            }).store(in: cancellable)

        let buttonState = ButtonViewDataState(callScreenHeaderCustomButtonsState: [customButton1])

        sut.update(localUserState: storeFactory.store.state.localUserState,
                   remoteParticipantsState: RemoteParticipantsState(),
                   callingState: CallingState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   callScreenInfoHeaderState: CallScreenInfoHeaderState()
                   /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0>
                   ,
                   buttonViewDataState: buttonState
                   </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
        )

        wait(for: [expectation], timeout: 1)
    }
    </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
}

extension InfoHeaderViewModelTests {
    func makeSUT(
                 accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProvider(),
                 localizationProvider: LocalizationProviderMocking? = nil) -> InfoHeaderViewModel {
        return InfoHeaderViewModel(compositeViewModelFactory: factoryMocking,
                                   logger: logger,
                                   localUserState: LocalUserState(),
                                   localizationProvider: localizationProvider ?? LocalizationProvider(logger: logger),
                                   accessibilityProvider: accessibilityProvider,
                                   dispatchAction: storeFactory.store.dispatch,
                                   enableMultitasking: true,
                                   enableSystemPipWhenMultitasking: true,
                                   callScreenInfoHeaderState: CallScreenInfoHeaderState()
                                   /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0>
                                   ,
                                   buttonViewDataState: ButtonViewDataState(),
                                   controlHeaderViewData: nil
                                   </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
        )
    }

    func makeSUTLocalizationMocking() -> InfoHeaderViewModel {
        return makeSUT(localizationProvider: localizationProvider)
    }
}
