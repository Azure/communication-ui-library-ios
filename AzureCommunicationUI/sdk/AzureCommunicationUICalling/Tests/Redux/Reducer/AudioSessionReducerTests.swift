//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation
import XCTest

@testable import AzureCommunicationUICalling

// class AudioSessionReducerTests: XCTestCase {
//
//    func test_audioSessionReducer_reduce_when_audioInterrupted_then_stateUpdated() {
//        let expectedAudioStatus: AudioSessionStatus = .interrupted
//        let currentAudioStatus: AudioSessionStatus = .active
//        let currentAudioState = AudioSessionState(status: currentAudioStatus)
//        let action = AudioSessionAction.audioInterrupted
//        let sut = getSUT()
//        let resultState = sut.reduce(currentAudioState, action)
//        XCTAssertEqual(resultState.status, expectedAudioStatus)
//    }
//
//    func test_audioSessionReducer_reduce_when_audioInterruptionEnded_then_stateUpdated() {
//        let expectedAudioStatus: AudioSessionStatus = .active
//        let currentAudioStatus: AudioSessionStatus = .interrupted
//        let currentAudioState = AudioSessionState(status: currentAudioStatus)
//        let action = AudioSessionAction.audioInterruptEnded
//        let sut = getSUT()
//        let resultState = sut.reduce(currentAudioState, action)
//
//        XCTAssertEqual(resultState.status, expectedAudioStatus)
//    }
//
//    func test_audioSessionReducer_reduce_when_audioEngaged_then_stateUpdated() {
//        let expectedAudioStatus: AudioSessionStatus = .active
//        let currentAudioStatus: AudioSessionStatus = .interrupted
//        let currentAudioState = AudioSessionState(status: currentAudioStatus)
//        let action = AudioSessionAction.audioEngaged
//        let sut = getSUT()
//        let resultState = sut.reduce(currentAudioState, action)
//
//        XCTAssertEqual(resultState.status, expectedAudioStatus)
//    }
//
//    func test_audioSessionReducer_reduce_when_audioEngaged_then_stateNotUpdate() {
//        let expectedAudioStatus: AudioSessionStatus = .active
//        let currentAudioStatus = expectedAudioStatus
//        let currentAudioState = AudioSessionState(status: currentAudioStatus)
//        let action = AudioSessionAction.audioEngaged
//        let sut = getSUT()
//        let resultState = sut.reduce(currentAudioState, action)
//
//        XCTAssertEqual(resultState.status, expectedAudioStatus)
//    }
// }
//
// extension AudioSessionReducerTests {
//    func getSUT() -> Reducer<AudioSessionState, AudioSessionAction> {
//        return .liveAudioSessionReducer
//    }
// }
