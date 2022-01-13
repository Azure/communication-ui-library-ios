//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct DiagnosticConfig {
    var tags = [String]()
    private let callCompositeTagPrefix: String = "aci110"
    private var callCompositeTag: String {
        let version = Bundle(for: CallComposite.self).infoDictionary?["CompositeSemVersion"]
        let versionStr = version as? String ?? "unknown"
        return "\(callCompositeTagPrefix)/\(versionStr)"
    }

    init() {
        tags.append(callCompositeTag)
    }

}
