//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

final class CallDiagnosticsReducerTests: XCTestCase {

    func test_callDiagnosticsReducer_reduce_when_a_media_diagnostic_action_is_received_then_stateUpdated() {
        let model = MediaDiagnosticModel(diagnostic: .speakingWhileMicrophoneIsMuted, value: true)
        let action = Action.callDiagnosticAction(.media(diagnostic: model))
        let sut = makeSUT()
        let state = CallDiagnosticsState()
        let result = sut.reduce(state, action)

        XCTAssertNotNil(result.mediaDiagnostic)
        XCTAssertEqual(model, result.mediaDiagnostic)

        XCTAssertNil(result.networkQualityDiagnostic)
        XCTAssertNil(result.networkDiagnostic)
    }

    func test_callDiagnosticsReducer_reduce_when_a_network_diagnostic_action_is_received_then_stateUpdated() {
        let model = NetworkDiagnosticModel(diagnostic: .networkUnavailable, value: true)
        let action = Action.callDiagnosticAction(.network(diagnostic: model))
        let sut = makeSUT()
        let state = CallDiagnosticsState()
        let result = sut.reduce(state, action)

        XCTAssertNil(result.mediaDiagnostic)
        XCTAssertNil(result.networkQualityDiagnostic)
        XCTAssertNotNil(result.networkDiagnostic)
        XCTAssertEqual(model, result.networkDiagnostic)
    }

    func test_callDiagnosticsReducer_reduce_when_a_network_quality_diagnostic_action_is_received_then_stateUpdated() {
        let model = NetworkQualityDiagnosticModel(diagnostic: .networkReceiveQuality, value: .bad)
        let action = Action.callDiagnosticAction(.networkQuality(diagnostic: model))
        let sut = makeSUT()
        let state = CallDiagnosticsState()
        let result = sut.reduce(state, action)

        XCTAssertNil(result.mediaDiagnostic)
        XCTAssertNil(result.networkDiagnostic)
        XCTAssertNotNil(result.networkQualityDiagnostic)
        XCTAssertEqual(model, result.networkQualityDiagnostic)
    }

    func test_callDiagnosticsReducer_reduce_when_a_media_diagnostic_dismiss_action_is_received_then_stateUpdated() {
        let model = MediaDiagnosticModel(diagnostic: .speakingWhileMicrophoneIsMuted, value: true)
        let action = Action.callDiagnosticAction(.media(diagnostic: model))
        let sut = makeSUT()
        let state = CallDiagnosticsState()
        let result = sut.reduce(state, action)

        XCTAssertNotNil(result.mediaDiagnostic)
        XCTAssertEqual(model, result.mediaDiagnostic)

        XCTAssertNil(result.networkQualityDiagnostic)
        XCTAssertNil(result.networkDiagnostic)

        let dismissAction = Action.callDiagnosticAction(.dismissMedia(diagnostic: .speakingWhileMicrophoneIsMuted))
        let resultDismiss = sut.reduce(result, dismissAction)

        XCTAssertNil(resultDismiss.mediaDiagnostic)
        XCTAssertNil(resultDismiss.networkDiagnostic)
        XCTAssertNil(resultDismiss.networkQualityDiagnostic)
    }

    func test_callDiagnosticsReducer_reduce_when_a_network_diagnostic_dismiss_action_is_received_then_stateUpdated() {
        let model = NetworkDiagnosticModel(diagnostic: .networkUnavailable, value: true)
        let action = Action.callDiagnosticAction(.network(diagnostic: model))
        let sut = makeSUT()
        let state = CallDiagnosticsState()
        let result = sut.reduce(state, action)

        XCTAssertNil(result.mediaDiagnostic)
        XCTAssertNil(result.networkQualityDiagnostic)
        XCTAssertNotNil(result.networkDiagnostic)
        XCTAssertEqual(model, result.networkDiagnostic)

        let dismissAction = Action.callDiagnosticAction(.dismissNetwork(diagnostic: .networkUnavailable))
        let resultDismiss = sut.reduce(result, dismissAction)

        XCTAssertNil(resultDismiss.mediaDiagnostic)
        XCTAssertNil(resultDismiss.networkDiagnostic)
        XCTAssertNil(resultDismiss.networkQualityDiagnostic)
    }

    func test_callDiagnosticsReducer_reduce_when_a_network_quality_diagnostic_dismiss_action_is_received_then_stateUpdated() {
        let model = NetworkQualityDiagnosticModel(diagnostic: .networkReceiveQuality, value: .bad)
        let action = Action.callDiagnosticAction(.networkQuality(diagnostic: model))
        let sut = makeSUT()
        let state = CallDiagnosticsState()
        let result = sut.reduce(state, action)

        XCTAssertNil(result.mediaDiagnostic)
        XCTAssertNil(result.networkDiagnostic)
        XCTAssertNotNil(result.networkQualityDiagnostic)
        XCTAssertEqual(model, result.networkQualityDiagnostic)

        let dismissAction = Action.callDiagnosticAction(.dismissNetworkQuality(diagnostic: .networkReceiveQuality))
        let resultDismiss = sut.reduce(result, dismissAction)

        XCTAssertNil(resultDismiss.mediaDiagnostic)
        XCTAssertNil(resultDismiss.networkDiagnostic)
        XCTAssertNil(resultDismiss.networkQualityDiagnostic)
    }
}

extension CallDiagnosticsReducerTests {
    private func makeSUT() -> Reducer<CallDiagnosticsState, Action> {
        return .liveDiagnosticsReducer
    }
}
