//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class SharingActivityViewModel: ObservableObject {
    private let activityItems: [Any]

    init(activityItems: [Any]) {
        self.activityItems = activityItems
    }
}
