//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import Combine
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

    func test_callingService_setupCall_shouldCallcallingSDKWrapperSetupCall() {
        _ = callingService.setupCall()

        XCTAssertTrue(callingSDKWrapper.setupCallWasCalled())
    }

    func test_callingService_startCall_shouldCallcallingSDKWrapperStartCall() {
        _ = callingService.startCall(isCameraPreferred: false, isAudioPreferred: false)

        XCTAssertTrue(callingSDKWrapper.startCallWasCalled())
    }

    func test_callingService_endCall_shouldCallCallingGatewayEndCall() {
        _ = callingService.endCall()

        XCTAssertTrue(callingSDKWrapper.endCallWasCalled())
    }

    func test_callingService_mute_when_startCall_then_callWasMutedTrue() {
        _ = callingService.startCall(isCameraPreferred: false, isAudioPreferred: false)
        _ = callingService.muteLocalMic()

        XCTAssertTrue(callingSDKWrapper.muteWasCalled())
    }

    func test_callingService_unmute_when_startCallAndMute_then_callWasUnmutedTrue() {
        _ = callingService.startCall(isCameraPreferred: false, isAudioPreferred: false)
        _ = callingService.muteLocalMic()

        XCTAssertTrue(callingSDKWrapper.muteWasCalled())

        _ = callingService.unmuteLocalMic()

        XCTAssertTrue(callingSDKWrapper.unmuteWasCalled())
    }

    func test_callingService_startCall_when_joinCallCameraOptionOn_then_videoWasEnabled() {
        _ = callingService.startCall(isCameraPreferred: true, isAudioPreferred: false)

        XCTAssertTrue(callingSDKWrapper.videoEnabledWhenJoinCall())
    }

    func test_callingService_startCall_when_joinCallCameraOptionOff_then_videoWasDisabled() {
        _ = callingService.startCall(isCameraPreferred: false, isAudioPreferred: false)

        XCTAssertFalse(callingSDKWrapper.videoEnabledWhenJoinCall())
    }

    func test_callingService_startCall_when_joinCallMicOptionOn_then_callWasUnmuted() {
        _ = callingService.startCall(isCameraPreferred: false, isAudioPreferred: true)

        XCTAssertFalse(callingSDKWrapper.mutedWhenJoinCall())
    }

    func test_callingService_startCall_when_joinCallMicOptionOff_then_callWasMuted() {
        _ = callingService.startCall(isCameraPreferred: false, isAudioPreferred: false)

        XCTAssertTrue(callingSDKWrapper.mutedWhenJoinCall())
    }

    func test_callingService_switchCamera_then_switchCameraWasCalled() {
        _ = callingService.switchCamera()

        XCTAssertTrue(callingSDKWrapper.switchCameraWasCalled())
    }

    func test_callService_requestCameraPreviewOn_then_startPreviewVideoStreamCalled() {
        _ = callingService.requestCameraPreviewOn()
        XCTAssertTrue(callingSDKWrapper.startPreviewVideoStreamCalled)
    }

    func test_callingService_holdCall_then_holdCallWasCalled() {
        _ = callingService.holdCall()

        XCTAssertTrue(callingSDKWrapper.holdCallCalled)
    }

    func test_callingService_resumeCall_then_resumeCallWasCalled() {
        _ = callingService.resumeCall()

        XCTAssertTrue(callingSDKWrapper.resumeCallCalled)
    }
}
