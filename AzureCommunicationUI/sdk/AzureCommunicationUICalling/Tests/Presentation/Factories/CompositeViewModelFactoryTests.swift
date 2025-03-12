//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon

@testable import AzureCommunicationUICalling

class CompositeViewModelFactoryTests: XCTestCase {

    func test_compositeViewModelFactory_getCallingViewModel_when_setupViewModelNotNil_then_getSetupViewModel_shouldReturnDifferentSetupViewModel() {
        let videoViewManager = VideoViewManagerMocking()
        let sut = makeSUT()
        let setupViewModel1 = sut.getSetupViewModel()
        let setupViewModel2 = sut.getSetupViewModel()
        XCTAssertEqual(setupViewModel1.id, setupViewModel2.id)

        _ = sut.getCallingViewModel(rendererViewManager: videoViewManager)
        let setupViewModel3 = sut.getSetupViewModel()
        XCTAssertNotEqual(setupViewModel1.id, setupViewModel3.id)
    }

    func test_compositeViewModelFactory_getSetupViewModel_when_callingViewModelNotNil_then_getCallingViewModel_shouldReturnDifferentCallingViewModel() {
        let sut = makeSUT()
        let videoViewManager = VideoViewManagerMocking()
        let callingViewModel1 = sut.getCallingViewModel(rendererViewManager: videoViewManager)
        let callingViewModel2 = sut.getCallingViewModel(rendererViewManager: videoViewManager)
        XCTAssertEqual(callingViewModel1.id, callingViewModel2.id)

        _ = sut.getSetupViewModel()
        let callingViewModel3 = sut.getCallingViewModel(rendererViewManager: videoViewManager)
        XCTAssertNotEqual(callingViewModel1.id, callingViewModel3.id)
    }
}

extension CompositeViewModelFactoryTests {
    func makeSUT() -> CompositeViewModelFactory {
        let mockStoreFactory = StoreFactoryMocking()
        let logger = LoggerMocking()
        return CompositeViewModelFactory(logger: logger,
                                         store: mockStoreFactory.store,
                                         networkManager: NetworkManager(),
                                         audioSessionManager: AudioSessionManager(store: mockStoreFactory.store, logger: logger, isCallKitEnabled: false),
                                         localizationProvider: LocalizationProviderMocking(),
                                         accessibilityProvider: AccessibilityProviderMocking(),
                                         debugInfoManager: DebugInfoManagerMocking(),
                                         captionsRttDataManager: CaptionsRttDataManager(
                                            store: mockStoreFactory.store,
                                            callingSDKWrapper: CallingSDKWrapperMocking()
                                         ),
                                         enableMultitasking: true,
                                         enableSystemPipWhenMultitasking: true,
                                         eventsHandler: CallComposite.Events(),
                                         leaveCallConfirmationMode: LeaveCallConfirmationMode.alwaysEnabled,
                                         callType: .groupCall,
                                         setupScreenOptions: nil,
                                         callScreenOptions: CallScreenOptions(),
                                         capabilitiesManager: CapabilitiesManager(callType: .groupCall),
                                         avatarManager: AvatarViewManagerMocking(
                                            store: mockStoreFactory.store,
                                            localParticipantId: createCommunicationIdentifier(fromRawId: ""),
                                            localParticipantViewData: nil),
                                         themeOptions: MockThemeOptions(),
                                         updatableOptionsManager: UpdatableOptionsManager(store: mockStoreFactory.store, setupScreenOptions: nil, callScreenOptions: nil),
                                         retrieveLogFiles: { return [] })
    }
}

extension SetupViewModel: Identifiable {}

extension CallingViewModel: Identifiable {}
