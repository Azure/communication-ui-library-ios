//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class AvModeTests: XCTestCase {
    
    func test_audio_only_enum_values() {
        XCTAssertEqual(CallCompositeAvMode.normal.rawValue, "normal")
        XCTAssertEqual(CallCompositeAvMode.audioOnly.rawValue, "audioOnly")
    }
}
