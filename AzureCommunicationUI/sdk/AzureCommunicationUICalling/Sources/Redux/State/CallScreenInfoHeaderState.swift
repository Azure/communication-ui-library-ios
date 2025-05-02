//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct CallScreenInfoHeaderState {
    let title: String?
    let subtitle: String?
    let showCallDuration: Bool?
    init(title: String? = nil, subtitle: String? = nil, showCallDuration: Bool? = false) {
        self.title = title
        self.subtitle = subtitle
        self.showCallDuration = showCallDuration
    }
}
