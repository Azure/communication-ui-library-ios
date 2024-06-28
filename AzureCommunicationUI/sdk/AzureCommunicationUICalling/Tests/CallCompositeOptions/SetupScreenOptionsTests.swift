//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
import AzureCommunicationCalling
@testable import AzureCommunicationUICalling

class SetupScreenOptionsTests: XCTestCase {
    func test_setupscreenoptions_default_controlsEbabled() {
        let setupScreenOptions = SetupScreenOptions()

        XCTAssertTrue(setupScreenOptions.cameraButtonEnabled)
        XCTAssertTrue(setupScreenOptions.microphoneButtonEnabled)
    }

    func test_setupscreenoptions_disabled() {
        let setupScreenOptions = SetupScreenOptions(cameraButtonEnabled: false, microphoneButtonEnabled: false)

        XCTAssertFalse(setupScreenOptions.cameraButtonEnabled)
        XCTAssertFalse(setupScreenOptions.microphoneButtonEnabled)
    }}
