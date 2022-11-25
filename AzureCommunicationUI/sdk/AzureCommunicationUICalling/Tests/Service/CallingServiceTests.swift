//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import Combine
@testable import AzureCommunicationUICalling
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

class CallingServiceTests: XCTestCase {

    var callingSDKWrapper: CallingSDKWrapperMocking!

    override func setUp() {
        super.setUp()
        callingSDKWrapper = CallingSDKWrapperMocking()
    }

    override func tearDown() {
        super.tearDown()
        callingSDKWrapper = nil
    }

    func test_callingService_setupCall_shouldCallcallingSDKWrapperSetupCall() async throws {
        let sut = makeSUT()
        _ = try await sut.setupCall()

        XCTAssertTrue(callingSDKWrapper.setupCallWasCalled())
    }

    func test_callingService_startCall_shouldCallcallingSDKWrapperStartCall() async throws {
        let sut = makeSUT()
        _ = try await sut.startCall(isCameraPreferred: false, isAudioPreferred: false)

        XCTAssertTrue(callingSDKWrapper.startCallWasCalled())
    }

    func test_callingService_endCall_shouldCallCallingGatewayEndCall() async throws {
        let sut = makeSUT()
        _ = try await sut.endCall()

        XCTAssertTrue(callingSDKWrapper.endCallWasCalled())
    }

    func test_callingService_mute_when_startCall_then_callWasMutedTrue() async throws {
        let sut = makeSUT()
        _ = try await sut.startCall(isCameraPreferred: false, isAudioPreferred: false)
        _ = try await sut.muteLocalMic()

        XCTAssertTrue(callingSDKWrapper.muteWasCalled())
    }

    func test_callingService_unmute_when_startCallAndMute_then_callWasUnmutedTrue() async throws {
        let sut = makeSUT()
        _ = try await sut.startCall(isCameraPreferred: false, isAudioPreferred: false)
        _ = try await sut.muteLocalMic()

        XCTAssertTrue(callingSDKWrapper.muteWasCalled())

        _ = try await sut.unmuteLocalMic()

        XCTAssertTrue(callingSDKWrapper.unmuteWasCalled())
    }

    func test_callingService_startCall_when_joinCallCameraOptionOn_then_videoWasEnabled() async throws {
        let sut = makeSUT()
        _ = try await sut.startCall(isCameraPreferred: true, isAudioPreferred: false)

        XCTAssertTrue(callingSDKWrapper.videoEnabledWhenJoinCall())
    }

    func test_callingService_startCall_when_joinCallCameraOptionOff_then_videoWasDisabled() async throws {
        let sut = makeSUT()
        _ = try await sut.startCall(isCameraPreferred: false, isAudioPreferred: false)

        XCTAssertFalse(callingSDKWrapper.videoEnabledWhenJoinCall())
    }

    func test_callingService_startCall_when_joinCallMicOptionOn_then_callWasUnmuted() async throws {
        let sut = makeSUT()
        _ = try await sut.startCall(isCameraPreferred: false, isAudioPreferred: true)

        XCTAssertFalse(callingSDKWrapper.mutedWhenJoinCall())
    }

    func test_callingService_startCall_when_joinCallMicOptionOff_then_callWasMuted() async throws {
        let sut = makeSUT()
        _ = try await sut.startCall(isCameraPreferred: false, isAudioPreferred: false)

        XCTAssertTrue(callingSDKWrapper.mutedWhenJoinCall())
    }

    func test_callingService_switchCamera_then_switchCameraWasCalled() async throws {
        let sut = makeSUT()
        _ = try await sut.switchCamera()

        XCTAssertTrue(callingSDKWrapper.switchCameraWasCalled())
    }

    func test_callService_requestCameraPreviewOn_then_startPreviewVideoStreamCalled() async throws {
        let sut = makeSUT()
        _ = try await sut.requestCameraPreviewOn()
        XCTAssertTrue(callingSDKWrapper.startPreviewVideoStreamCalled)
    }

    func test_callingService_holdCall_then_holdCallWasCalled() async throws {
        let sut = makeSUT()
        _ = try await sut.holdCall()

        XCTAssertTrue(callingSDKWrapper.holdCallCalled)
    }

    func test_callingService_resumeCall_then_resumeCallWasCalled() async throws {
        let sut = makeSUT()
        _ = try await sut.resumeCall()

        XCTAssertTrue(callingSDKWrapper.resumeCallCalled)
    }
}

extension CallingServiceTests {
    func makeSUT() -> CallingService {
        let logger = LoggerMocking()
        return CallingService(logger: logger, callingSDKWrapper: callingSDKWrapper)
    }
}
