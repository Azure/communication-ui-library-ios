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

        // Obtain version string from the library's bundle
        let version = Bundle(for: Self.self).infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "Version not found"

        // Create a new DrawerListItemViewModel for the version
        let versionInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .checkmark,  // Use an appropriate icon for version information
            title: "Library version: \(version)",
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            action: {})  // You may not need an action for this, but if you do, provide one

        // Add both models to the items array
        items = [versionInfoModel, shareDebugInfoModel]
    }
}
