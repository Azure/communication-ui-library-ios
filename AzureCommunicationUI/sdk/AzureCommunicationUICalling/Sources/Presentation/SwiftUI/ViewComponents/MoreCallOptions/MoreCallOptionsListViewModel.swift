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
         isSupportFormAvailable: Bool,
         isDisplayed: Bool
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isDisplayed = isDisplayed

        let title = TitleDrawerListItemViewModel(title: "More Options", accessibilityIdentifier: "Title")

        let shareDebugInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .share,
            title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo),
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            action: showSharingViewAction)

        var items = [title, shareDebugInfoModel]

        if isSupportFormAvailable {
            let reportErrorInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
                icon: .personFeedback,
                title: localizationProvider.getLocalizedString(.supportFormReportIssueTitle),
                accessibilityIdentifier: AccessibilityIdentifier.reportIssueAccessibilityID.rawValue,
                action: showSupportFormAction)

            items.append(reportErrorInfoModel)
        }
        self.items = items
    }

    func setIsDisplayed(isDisplayed: Bool) {
        self.isDisplayed = isDisplayed
    }
}
