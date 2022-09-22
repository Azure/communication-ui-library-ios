//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct DiagnosticConfig {
    var tags = [String]()
    private let compositeTagPrefix: String = "aci130"
    private var compositeTag: String {
        let version = Bundle(for: CallWithChatComposite.self).infoDictionary?["UILibrarySemVersion"]
        let versionStr = version as? String ?? "unknown"
        return "\(compositeTagPrefix)/\(versionStr)"
    }

    init() {
        tags.append(compositeTag)
    }

}
