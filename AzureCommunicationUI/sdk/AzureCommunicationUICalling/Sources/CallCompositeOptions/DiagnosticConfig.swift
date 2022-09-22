//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct DiagnosticConfig {
    var tags = [String]()
    private let compositeTagPrefix: String = "aci110"
    private var compositeTag: String {
        let version = Bundle(for: CallComposite.self).infoDictionary?["UILibrarySemVersion"]
        let versionStr = version as? String ?? "unknown"
        return "\(compositeTagPrefix)/\(versionStr)"
    }

    init(diagnosticsOptions: DiagnosticsOptions?) {
        tags.append(compositeTag)

        guard let diagnosticsTags = diagnosticsOptions?.tags else {
            return
        }
        tags.append(contentsOf: diagnosticsTags)
    }

}
