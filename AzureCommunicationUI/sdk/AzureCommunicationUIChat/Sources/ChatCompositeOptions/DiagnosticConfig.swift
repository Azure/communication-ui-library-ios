//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct DiagnosticConfig {
    var tags = [String]()
    private let compositeTagPrefix: String = "aci120"
    private var compositeTag: String {
        let version = Bundle(for: ChatComposite.self).infoDictionary?["UILibrarySemVersion"]
        let versionStr = version as? String ?? "unknown"
        return "\(compositeTagPrefix)/\(versionStr)"
    }

    init() {
        tags.append(compositeTag)
    }

}
