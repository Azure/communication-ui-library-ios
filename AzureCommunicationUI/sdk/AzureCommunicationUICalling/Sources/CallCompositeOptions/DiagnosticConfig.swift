//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct DiagnosticConfig {
    var tags = [String]()
    // Tag template is: acXYYY/<version>
    // Where:
    // - X describes a platform, [r: web, i: iOS, a: Android]
    // - YYY describes what's running on this platform (optional):
    //      Y[0] is high-level artifact,
    //          [0: undefined, 1: AzureCommunicationLibrary, 2: ACS SampleApp]
    //      Y[1] is specific implementation,
    //          [0: undefined, 1: Call Composite, 2: Chat Composite, 3: CallWithChatComposite, 4: UI Components]
    //      Y[2] is reserved for implementation details,
    //          [0: undefined]
    private let callCompositeTagPrefix: String = "aci110"
    private var callCompositeTag: String {
        let version = Bundle(for: CallComposite.self).infoDictionary?["UILibrarySemVersion"]
        let versionStr = version as? String ?? "unknown"
        return "\(callCompositeTagPrefix)/\(versionStr)"
    }

    init() {
        tags.append(callCompositeTag)
    }
}
