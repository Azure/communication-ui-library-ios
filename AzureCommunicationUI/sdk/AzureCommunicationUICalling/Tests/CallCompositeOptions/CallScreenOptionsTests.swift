//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
import AzureCommunicationCalling
@testable import AzureCommunicationUICalling

class CallScreenOptionsTests: XCTestCase {
    func test_callscreenoptions_controlbaroptions_alwaysenabled() {
        let callScreenControlBarOptions = CallScreenControlBarOptions(leaveCallConfirmationMode: .alwaysEnabled)
        let callScrenOptions = CallScreenOptions(controlBarOptions: callScreenControlBarOptions)

        XCTAssertEqual(callScrenOptions.controlBarOptions?.leaveCallConfirmationMode, .alwaysEnabled)
    }

    func test_callscreenoptions_controlbaroptions_alwaysdisabled() {
        let callScreenControlBarOptions = CallScreenControlBarOptions(leaveCallConfirmationMode: .alwaysDisabled)
        let callScrenOptions = CallScreenOptions(controlBarOptions: callScreenControlBarOptions)

        XCTAssertEqual(callScrenOptions.controlBarOptions?.leaveCallConfirmationMode, .alwaysDisabled)
    }
}
