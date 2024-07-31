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

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         showSharingViewAction: @escaping () -> Void,
         showSupportFormAction: @escaping () -> Void,
         onUserReportedIssue: ((CallCompositeUserReportedIssue) -> Void)?,
         controlBarOptions: CallScreenControlBarOptions?
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider

        var items: [DrawerListItemViewModel] = []

        if controlBarOptions?.shareDiagnosticsButtonOptions?.visible ?? true {

            let shareDebugInfoModel =
            if let shareDiagnosticsButtonOptions = controlBarOptions?.shareDiagnosticsButtonOptions {
                compositeViewModelFactory.makeDrawerListItemViewModel(
                    icon: .share,
                    title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo),
                    isEnabled: shareDiagnosticsButtonOptions.enabled,
                    accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
                    action: {
                        shareDiagnosticsButtonOptions.onClick?(shareDiagnosticsButtonOptions)
                        showSharingViewAction()
                    })

            } else {
                compositeViewModelFactory.makeDrawerListItemViewModel(
                    icon: .share,
                    title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo),
                    accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
                    action: showSharingViewAction)
            }

            items.append(shareDebugInfoModel)
        }

        if onUserReportedIssue != nil &&
            controlBarOptions?.reportIssueButtonOptions?.visible ?? true {
            let reportErrorInfoModel = if let reportIssueButtonOptions = controlBarOptions?.reportIssueButtonOptions {
                compositeViewModelFactory.makeDrawerListItemViewModel(
                    icon: .personFeedback,
                    title: localizationProvider.getLocalizedString(.supportFormReportIssueTitle),
                    isEnabled: reportIssueButtonOptions.enabled,
                    accessibilityIdentifier: AccessibilityIdentifier.reportIssueAccessibilityID.rawValue,
                    action: {
                        reportIssueButtonOptions.onClick?(reportIssueButtonOptions)
                        showSupportFormAction()
                    })
            } else {
                compositeViewModelFactory.makeDrawerListItemViewModel(
                    icon: .personFeedback,
                    title: localizationProvider.getLocalizedString(.supportFormReportIssueTitle),
                    accessibilityIdentifier: AccessibilityIdentifier.reportIssueAccessibilityID.rawValue,
                    action: showSupportFormAction)
            }

            items.append(reportErrorInfoModel)
        }
        self.items = items
    }
}
