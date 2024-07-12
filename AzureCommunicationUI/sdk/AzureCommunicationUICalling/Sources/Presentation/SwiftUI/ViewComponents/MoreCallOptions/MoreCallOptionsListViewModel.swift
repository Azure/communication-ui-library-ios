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
         isSupportFormAvailable: Bool,
         isDisplayed: Bool
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isDisplayed = isDisplayed

        let shareDebugInfoModel = DrawerGenericItemViewModel(
            title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo),
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            action: showSharingViewAction,
            startIcon: .share
        )

        var items = [shareDebugInfoModel]

        if isSupportFormAvailable {
            let reportErrorInfoModel = DrawerGenericItemViewModel(
                title: localizationProvider.getLocalizedString(.supportFormReportIssueTitle),
                accessibilityIdentifier: AccessibilityIdentifier.reportIssueAccessibilityID.rawValue,
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
