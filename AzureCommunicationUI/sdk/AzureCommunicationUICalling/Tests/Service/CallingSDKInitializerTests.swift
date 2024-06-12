//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
import AzureCommunicationCalling
@testable import AzureCommunicationUICalling

class CallingSDKInitializerTests: XCTestCase {
    static func getCommunicationToken() -> TokenRefresher {
        return { completionHandler in
            struct TokenResponse: Decodable {
                let token: String
            }
            completionHandler("abc", nil)
        }
    }

    private func onCallAdded(callId: String) {
    }

    func test_callingsdkinitializer_callclient_creation() async {
        let communicationTokenRefreshOptions = CommunicationTokenRefreshOptions(refreshProactively: true,
                                                                                tokenRefresher: CallingSDKInitializerTests.getCommunicationToken())
        let credential = try? CommunicationTokenCredential(withOptions: communicationTokenRefreshOptions)
        let events = CallComposite().events
        let callingSDKInitializer = CallingSDKInitializer(tags: ["abc"],
                                                          credential: credential!,
                                                          callKitOptions: nil,
                                                          displayName: "abc",
                                                          disableInternalPushForIncomingCall: true,
                                                          logger: DefaultLogger(),
                                                          events: events,
                                                          onCallAdded: onCallAdded)
        XCTAssertNil(callingSDKInitializer.getIncomingCall())
        XCTAssertNotNil(callingSDKInitializer.setupCallClient())
    }
}
