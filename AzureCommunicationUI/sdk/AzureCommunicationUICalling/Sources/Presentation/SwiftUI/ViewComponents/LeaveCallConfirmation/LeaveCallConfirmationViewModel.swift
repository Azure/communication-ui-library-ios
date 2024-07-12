//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

internal class LeaveCallConfirmationViewModel: ObservableObject {
    @Published var isDisplayed = false
    @Published var options: [BaseDrawerItemViewModel]

    let endCall: () -> Void
    let dismissConfirmation: () -> Void

    init(state: AppState,
         localizationProvider: LocalizationProviderProtocol,
         endCall: @escaping () -> Void,
         dismissConfirmation: @escaping() -> Void) {
        self.isDisplayed = state.navigationState.endCallConfirmationVisible

        let title = localizationProvider.getLocalizedString(LocalizationKey.leaveCallListHeader)
        let leaveText = localizationProvider.getLocalizedString(LocalizationKey.leaveCall)
        let cancelText = localizationProvider.getLocalizedString(LocalizationKey.cancel)

        self.options = [
            TitleDrawerListItemViewModel(title: title,
                                         accessibilityIdentifier: AccessibilityIdentifier
                .leaveCallConfirmTitleAccessibilityID
                .rawValue),
            DrawerGenericItemViewModel(
                title: leaveText,
                accessibilityIdentifier: AccessibilityIdentifier.leaveCallAccessibilityID.rawValue,
                action: {
                    endCall()
                },
                startIcon: .endCallRegular),

            DrawerGenericItemViewModel(
                title: cancelText,
                accessibilityIdentifier: AccessibilityIdentifier.cancelAccessibilityID.rawValue,
                action: {
                    dismissConfirmation()
                },
                startIcon: .dismiss)
        ]
        self.endCall = endCall
        self.dismissConfirmation = dismissConfirmation
    }

    func update(state: AppState) {
        self.isDisplayed = state.navigationState.endCallConfirmationVisible
        && state.visibilityState.currentStatus == .visible
    }
}
