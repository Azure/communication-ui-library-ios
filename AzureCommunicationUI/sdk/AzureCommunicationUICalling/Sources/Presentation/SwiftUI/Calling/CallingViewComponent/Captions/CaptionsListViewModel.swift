//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI

class CaptionsListViewModel: ObservableObject {
    @Published private var isToggleEnabled = false
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    @Published var items: [DrawerListItemViewModel] = []
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
        self.isToggleEnabled = false
        setupItems(showCaptionsLanguage: showCaptionsLanguage, showSpokenLanguage: showSpokenLanguage)
    }

    private func setupItems(showCaptionsLanguage: @escaping () -> Void, showSpokenLanguage: @escaping () -> Void) {

        let isToggleEnabledBinding = Binding(
            get: { self.isToggleEnabled },
            set: { self.isToggleEnabled = $0 }
        )
        let enableCaptionsInfoModel = compositeViewModelFactory.makeToggleListItemViewModel(
            icon: .closeCaptions,
            title: localizationProvider.getLocalizedString(.captionsListTitile),
            isToggleOn: isToggleEnabledBinding,
            showToggle: true,
            accessibilityIdentifier:
                AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            action: {self.toggleCaptions()})

        let spokenLanguageInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .personVoice,
            title: localizationProvider.getLocalizedString(.captionsSpokenLanguage),
            subtitle: "",
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            titleTrailingAccessoryView: .rightChevron,
            action: showSpokenLanguage)

        let captionsLanguageInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .localLanguage,
            title: localizationProvider.getLocalizedString(.captionsCaptionLanguage),
            subtitle: "",
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            titleTrailingAccessoryView: .rightChevron,
            action: showCaptionsLanguage)

        items = [enableCaptionsInfoModel, spokenLanguageInfoModel, captionsLanguageInfoModel]
    }

    func update(state: AppState) {
        isDisplayed = state.navigationState.captionsViewVisible
        isToggleEnabled = state.captionsState.isEnabled ?? true
    }

    func toggleCaptions() {
        isToggleEnabled.toggle()
    }
}
