//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Combine
import Foundation
import XCTest

@testable import AzureCommunicationUICalling

class CallingServiceTests: XCTestCase {

    var logger: LoggerMocking!
    var callingSDKWrapper: CallingSDKWrapperMocking!
    var callingService: CallingService!
    var cancellable: CancelBag!

    override func setUp() {
        super.setUp()
        cancellable = CancelBag()
        logger = LoggerMocking()
        callingSDKWrapper = CallingSDKWrapperMocking()
        callingService = CallingService(logger: logger, callingSDKWrapper: callingSDKWrapper)
    }

    override func tearDown() {
        super.tearDown()
        cancellable = nil
        logger = nil
        callingSDKWrapper = nil
        callingService = nil
    }

    func test_callingService_setupCall_shouldCallcallingSDKWrapperSetupCall() async throws {
        _ = try await callingService.setupCall()

        XCTAssertTrue(callingSDKWrapper.setupCallWasCalled())
    }

    func test_callingService_startCall_shouldCallcallingSDKWrapperStartCall() async throws {
        _ = try await callingService.startCall(isCameraPreferred: false, isAudioPreferred: false)

        XCTAssertTrue(callingSDKWrapper.startCallWasCalled())
    }

    func test_callingService_endCall_shouldCallCallingGatewayEndCall() async throws {
        _ = try await callingService.endCall()

        XCTAssertTrue(callingSDKWrapper.endCallWasCalled())
    }

    func test_callingService_mute_when_startCall_then_callWasMutedTrue() async throws {
        _ = try await callingService.startCall(isCameraPreferred: false, isAudioPreferred: false)
        _ = try await callingService.muteLocalMic()

        XCTAssertTrue(callingSDKWrapper.muteWasCalled())
    }

    func test_callingService_unmute_when_startCallAndMute_then_callWasUnmutedTrue() async throws {
        _ = try await callingService.startCall(isCameraPreferred: false, isAudioPreferred: false)
        _ = try await callingService.muteLocalMic()

        XCTAssertTrue(callingSDKWrapper.muteWasCalled())

        _ = try await callingService.unmuteLocalMic()

        XCTAssertTrue(callingSDKWrapper.unmuteWasCalled())
    }

    func test_callingService_startCall_when_joinCallCameraOptionOn_then_videoWasEnabled() async throws {
        _ = try await callingService.startCall(isCameraPreferred: true, isAudioPreferred: false)

        XCTAssertTrue(callingSDKWrapper.videoEnabledWhenJoinCall())
    }

    func test_callingService_startCall_when_joinCallCameraOptionOff_then_videoWasDisabled() async throws {
        _ = try await callingService.startCall(isCameraPreferred: false, isAudioPreferred: false)

        XCTAssertFalse(callingSDKWrapper.videoEnabledWhenJoinCall())
    }

    func test_callingService_startCall_when_joinCallMicOptionOn_then_callWasUnmuted() async throws {
        _ = try await callingService.startCall(isCameraPreferred: false, isAudioPreferred: true)

        XCTAssertFalse(callingSDKWrapper.mutedWhenJoinCall())
    }

    func test_callingService_startCall_when_joinCallMicOptionOff_then_callWasMuted() async throws {
        _ = try await callingService.startCall(isCameraPreferred: false, isAudioPreferred: false)

        XCTAssertTrue(callingSDKWrapper.mutedWhenJoinCall())
    }

    func test_callingService_switchCamera_then_switchCameraWasCalled() async throws {
        _ = try await callingService.switchCamera()

        XCTAssertTrue(callingSDKWrapper.switchCameraWasCalled())
    }

    func test_callService_requestCameraPreviewOn_then_startPreviewVideoStreamCalled() async throws {
        _ = try await callingService.requestCameraPreviewOn()
        XCTAssertTrue(callingSDKWrapper.startPreviewVideoStreamCalled)
    }

    func test_callingService_holdCall_then_holdCallWasCalled() async throws {
        _ = try await callingService.holdCall()

        XCTAssertTrue(callingSDKWrapper.holdCallCalled)
    }

    func test_callingService_resumeCall_then_resumeCallWasCalled() async throws {
        _ = try await callingService.resumeCall()

        XCTAssertTrue(callingSDKWrapper.resumeCallCalled)
    }
}
