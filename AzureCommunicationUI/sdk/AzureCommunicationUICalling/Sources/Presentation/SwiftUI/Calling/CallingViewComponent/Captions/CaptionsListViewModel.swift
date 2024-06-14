//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation
import Combine

class CaptionsListViewModel: ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    let items: [DrawerListItemViewModel]
    var isDisplayed: Bool

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         showCaptionsLanguage: @escaping () -> Void,
         showSpokenLanguage: @escaping () -> Void,
         isDisplayed: Bool
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isDisplayed = isDisplayed

        let spokenLanguageInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .share,
            title: localizationProvider.getLocalizedString(.captionsSpokenLanguage),
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            action: showSpokenLanguage)

        var items = [spokenLanguageInfoModel]

        let captionsLanguageInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .share,
            title: localizationProvider.getLocalizedString(.captionsCaptionLanguage),
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            action: showCaptionsLanguage)
        items.append(captionsLanguageInfoModel)
        self.items = items
    }

    func update(state: AppState) {
        isDisplayed = state.navigationState.captionsViewVisible
    }
}
