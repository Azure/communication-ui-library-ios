//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class UITestSettingsOverlayViewModel: OverlayViewModelProtocol, ObservableObject {
    var title: String {
        return "UITest Settings Page"
    }
    var action: ((Action) -> Void)

    @Published var isDisplayed: Bool = true

    init(store: Store<AppState>,
         action: @escaping (Action) -> Void) {
        self.action = action
    }
}
