//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class ParticipantMenuViewModelTests: XCTestCase {
    private var factoryMocking: CompositeViewModelFactoryMocking!
    private var logger: LoggerMocking!
    private var localizationProvider: LocalizationProviderMocking!
    private var storeFactory: StoreFactoryMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
        storeFactory = StoreFactoryMocking()
        logger = LoggerMocking()
        factoryMocking = CompositeViewModelFactoryMocking(
            logger: logger,
            store: storeFactory.store,
            avatarManager: AvatarViewManagerMocking(
                store: storeFactory.store,
                localParticipantId: createCommunicationIdentifier(fromRawId: ""),
                localParticipantViewData: nil
            )
        )
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
        storeFactory = nil
        logger = nil
        factoryMocking = nil
    }

    func test_participantMenuViewModel_showMenu_then_getParticipantName() {
        let sut = createSut()
        let id = "participantId"
        let participantDisplayName = "participantDisplayName"

        sut.update(localUserState: LocalUserState(capabilities: []),
                   isDisplayed: true,
                   participantInfoModel: ParticipantInfoModel(
                    displayName: participantDisplayName,
                    isSpeaking: false,
                    isMuted: false,
                    isRemoteUser: true,
                    userIdentifier: "",
                    status: .connected,
                    screenShareVideoStreamModel: nil,
                    cameraVideoStreamModel: nil))

        XCTAssertEqual(participantDisplayName, sut.getParticipantName())
    }

    func test_participantMenuViewModel_items_then_getParticipantName() {
        let sut = createSut()
        let id = "participantId"
        let participantDisplayName = "participantDisplayName"

        XCTAssertEqual(1, sut.items.count)

        var removeMenu = sut.items[0]
        XCTAssertEqual(false, removeMenu.isEnabled)

        sut.update(localUserState: LocalUserState(capabilities: [.removeParticipant]),
                   isDisplayed: true,
                   participantInfoModel: nil)
        removeMenu = sut.items[0]
        XCTAssertEqual(true, removeMenu.isEnabled)

    }
}

extension ParticipantMenuViewModelTests {
    private func createSut() -> ParticipantMenuViewModel {
        return ParticipantMenuViewModel(
            compositeViewModelFactory: factoryMocking,
            localUserState: LocalUserState(),
            localizationProvider: localizationProvider,
            capabilitiesManager: CapabilitiesManager(callType: .roomsCall),
            onRemoveUser: { _ in},
            isDisplayed: false
        )
    }
}
