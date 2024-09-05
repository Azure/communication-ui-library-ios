//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class CallScreenInfoHeaderManager {
    private let store: Store<AppState, Action>
    init(store: Store<AppState, Action>) {
        self.store = store
    }

    func titleDidUpdate(title: String) {
        store.dispatch(action: .callScreenInfoHeaderAction(.updateTitle(title: title)))
    }

    func subtitleDidUpdate(subtitle: String) {
        store.dispatch(action: .callScreenInfoHeaderAction(.updateSubtitle(subtitle: subtitle)))
    }
}
