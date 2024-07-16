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
    let items: [DrawerGenericItemViewModel]
    var isDisplayed: Bool

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         showSharingViewAction: @escaping () -> Void,
         showSupportFormAction: @escaping () -> Void,
         showCaptionsViewAction: @escaping() -> Void,
         isCaptionsAvailable: Bool,
         isSupportFormAvailable: Bool,
         isDisplayed: Bool
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isDisplayed = isDisplayed
        var items: [DrawerListItemViewModel] = []

        if isCaptionsAvailable {
            let captionsInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
                startIcon: .closeCaptions,
                title: localizationProvider.getLocalizedString(.captionsListTitile),
                accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
                titleTrailingAccessoryView: .rightChevron,
                action: showCaptionsViewAction)
            items = [captionsInfoModel]
        }

        let shareDebugInfoModel = DrawerGenericItemViewModel(
            title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo),
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            titleTrailingAccessoryView: nil,
            action: showSharingViewAction,
            startIcon: .share
        )

        items.append(shareDebugInfoModel)

        if isSupportFormAvailable {
            let reportErrorInfoModel = DrawerGenericItemViewModel(
                title: localizationProvider.getLocalizedString(.supportFormReportIssueTitle),
                accessibilityIdentifier: AccessibilityIdentifier.reportIssueAccessibilityID.rawValue,
                titleTrailingAccessoryView: nil,
                action: showSupportFormAction,
                startIcon: .personFeedback)

            items.append(reportErrorInfoModel)
        }
        self.items = items
    }

    func update(navigationState: NavigationState, visibilityState: VisibilityState) {
        isDisplayed = visibilityState.currentStatus == .visible && navigationState.moreOptionsVisible
    }
}
