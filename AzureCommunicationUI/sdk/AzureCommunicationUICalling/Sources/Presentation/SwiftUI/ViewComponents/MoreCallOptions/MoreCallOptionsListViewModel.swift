//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation
import Combine

class MoreCallOptionsListViewModel: ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let dispatchAction: ActionDispatch
    let items: [DrawerGenericItemViewModel]
    var isDisplayed: Bool

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         showSharingViewAction: @escaping () -> Void,
         showSupportFormAction: @escaping () -> Void,
         showCaptionsViewAction: @escaping() -> Void,
         controlBarOptions: CallScreenControlBarOptions?,
         isCaptionsAvailable: Bool,
         isSupportFormAvailable: Bool,
         isDisplayed: Bool,
         dispatchAction: @escaping ActionDispatch
    ) {
        self.dispatchAction = dispatchAction
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isDisplayed = isDisplayed
        var items: [DrawerGenericItemViewModel] = []

        if isCaptionsAvailable && controlBarOptions?.spokenLanguageButtonOptions?.visible ?? true {
            let captionsInfoModel = DrawerGenericItemViewModel(
                title: localizationProvider.getLocalizedString(.captionsListTitile),
                accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
                accessibilityTraits: [.isButton],
                action: showCaptionsViewAction,
                startCompositeIcon: .closeCaptions,
                endIcon: .rightChevron)
            items = [captionsInfoModel]
        }
        if controlBarOptions?.shareDiagnosticsButtonOptions?.visible ?? true {
            let shareDebugInfoModel = DrawerGenericItemViewModel(
                title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo),
                accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
                accessibilityTraits: [.isButton],
                action: showSharingViewAction,
                startCompositeIcon: .share
            )

            items.append(shareDebugInfoModel)
        }

        if isSupportFormAvailable && controlBarOptions?.reportIssueButtonOptions?.visible ?? true {
            let reportErrorInfoModel = DrawerGenericItemViewModel(
                title: localizationProvider.getLocalizedString(.supportFormReportIssueTitle),
                accessibilityIdentifier: AccessibilityIdentifier.reportIssueAccessibilityID.rawValue,
                accessibilityTraits: [.isButton],
                action: showSupportFormAction,
                startCompositeIcon: .personFeedback)

            items.append(reportErrorInfoModel)
        }

        controlBarOptions?.customButtons.forEach({ customButton in
            let customButtonModel = DrawerGenericItemViewModel(
                title: customButton.title,
                accessibilityIdentifier: "",
                accessibilityTraits: [.isButton],
                action: {
                    customButton.onClick(customButton)
                    dispatchAction(.hideDrawer)
                },
                startIcon: customButton.image,
                isEnabled: customButton.enabled

            )
            items.append(customButtonModel)
        })
        self.items = items
    }

    func update(navigationState: NavigationState, visibilityState: VisibilityState) {
        isDisplayed = visibilityState.currentStatus == .visible && navigationState.moreOptionsVisible
    }
}
