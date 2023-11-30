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
         showSharingViewAction: @escaping () -> Void) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider

        let shareDebugInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .share,
            title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo),
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            action: showSharingViewAction)
        let reportErrorInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .share,
            title: "Report an error",
            accessibilityIdentifier: "Report an error", action: showSharingViewAction)
        items = [shareDebugInfoModel, reportErrorInfoModel]
    }
}
