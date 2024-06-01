//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

internal class LeaveCallConfirmationViewModel: ObservableObject {
    @Published var isDisplayed = false
    @Published var options: [DrawerListItemViewModel]

    let endCall: () -> Void
    let dismissConfirmation: () -> Void

    init(state: AppState, endCall: @escaping () -> Void, dismissConfirmation: @escaping() -> Void) {
        self.isDisplayed = state.navigationState.endCallConfirmationVisible
        self.options = [
            DrawerListItemViewModel(
                icon: .endCallRegular,
                title: "Leave",
                accessibilityIdentifier: "Leave") {
                    endCall()
            },
            DrawerListItemViewModel(
                icon: .dismiss,
                title: "Cancel",
                accessibilityIdentifier: "Cancel") {
                    dismissConfirmation()
            }
        ]
        self.endCall = endCall
        self.dismissConfirmation = dismissConfirmation
    }

    func update(state: AppState) {
        self.isDisplayed = state.navigationState.endCallConfirmationVisible
    }
}
