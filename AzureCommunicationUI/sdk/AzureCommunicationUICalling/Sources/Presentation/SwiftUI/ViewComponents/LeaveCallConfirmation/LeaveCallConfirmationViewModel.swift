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

    init(state: AppState,
         localizationProvider: LocalizationProviderProtocol,
         endCall: @escaping () -> Void,
         dismissConfirmation: @escaping() -> Void) {
        self.isDisplayed = state.navigationState.endCallConfirmationVisible

        var title = localizationProvider.getLocalizedString(LocalizationKey.leaveCallListHeader)
        var leaveText = localizationProvider.getLocalizedString(LocalizationKey.leaveCall)
        var cancelText = localizationProvider.getLocalizedString(LocalizationKey.cancel)

        self.options = [
            TitleDrawerListItemViewModel(title: title,
                                         accessibilityIdentifier: title),
            DrawerListItemViewModel(
                icon: .endCallRegular,
                title: leaveText,
                accessibilityIdentifier: leaveText) {
                    endCall()
            },
            DrawerListItemViewModel(
                icon: .dismiss,
                title: cancelText,
                accessibilityIdentifier: cancelText) {
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