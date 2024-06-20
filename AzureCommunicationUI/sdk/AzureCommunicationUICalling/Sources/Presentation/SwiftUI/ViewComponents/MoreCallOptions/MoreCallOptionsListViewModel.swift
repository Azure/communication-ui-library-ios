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
    let items: [DrawerListItemViewModel]
    var isDisplayed: Bool

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         showSharingViewAction: @escaping () -> Void,
         showSupportFormAction: @escaping () -> Void,
         showCaptionsViewAction: @escaping() -> Void,
         isSupportFormAvailable: Bool,
         isDisplayed: Bool
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isDisplayed = isDisplayed

        let captionsInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .closeCaptions,
            title: localizationProvider.getLocalizedString(.captionsListTitile),
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            titleTrailingAccessoryView: .rightChevron,
            action: showCaptionsViewAction)
        var items = [captionsInfoModel]

        let shareDebugInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .share,
            title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo),
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            titleTrailingAccessoryView: nil,
            action: showSharingViewAction)

        items.append(shareDebugInfoModel)

        if isSupportFormAvailable {
            let reportErrorInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
                icon: .personFeedback,
                title: localizationProvider.getLocalizedString(.supportFormReportIssueTitle),
                accessibilityIdentifier: AccessibilityIdentifier.reportIssueAccessibilityID.rawValue,
                titleTrailingAccessoryView: nil,
                action: showSupportFormAction)

            items.append(reportErrorInfoModel)
        }
        self.items = items
    }

    func update(navigationState: NavigationState, visibilityState: VisibilityState) {
        isDisplayed = visibilityState.currentStatus == .visible && navigationState.moreOptionsVisible
    }
}
