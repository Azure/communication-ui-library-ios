//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct DiagnosticConfig {
    var tags = [String]()
    private let callCompositeTagPrefix: String = "aci110"
    private let semVersionString: String = "1.0.0-alpha.2"
    private var callCompositeTag: String {
        return "\(callCompositeTagPrefix)/\(semVersionString)"
    }

    init() {
        tags.append(callCompositeTag)
    }

}
