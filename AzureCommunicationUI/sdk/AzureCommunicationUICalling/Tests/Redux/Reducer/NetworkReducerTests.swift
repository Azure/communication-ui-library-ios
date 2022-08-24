//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class NetworkReducerTests: XCTestCase {

    func test_networkReducer_reduce_when_NetworkLost_shouldHaveStateNetworkOffline() {
        let state = NetworkState()
        let action = NetworkAction.networkLost
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.status, .offline)
    }

    func test_networkReducer_reduce_when_NetworkRestored_shouldHaveStateNetworkOnline() {
        let state = NetworkState()
        let action = NetworkAction.networkRestored
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.status, .online)
    }
}

extension NetworkReducerTests {
    private func getSUT() -> Reducer<NetworkState, NetworkAction> {
        return .liveNetworkReducer
    }
}
