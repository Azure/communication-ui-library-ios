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
    private var state: AppState
    private let showCaptionsLanguage: () -> Void
    private let showSpokenLanguage: () -> Void
    @Published var items: [DrawerListItemViewModel] = []
    var isDisplayed: Bool

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         state: AppState,
         showSpokenLanguage: @escaping () -> Void,
         showCaptionsLanguage: @escaping () -> Void,
         isDisplayed: Bool
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isDisplayed = isDisplayed
        self.isToggleEnabled = false
        self.state = state
        self.showSpokenLanguage = showSpokenLanguage
        self.showCaptionsLanguage = showCaptionsLanguage
        setupItems(showCaptionsLanguage: showCaptionsLanguage, showSpokenLanguage: showSpokenLanguage)
    }

    private func setupItems(showCaptionsLanguage: @escaping () -> Void, showSpokenLanguage: @escaping () -> Void) {

        let isToggleEnabledBinding = Binding(
            get: { self.isToggleEnabled },
            set: { self.isToggleEnabled = $0 }
        )
        let currentSpokenLanguage = languageDisplayName(for: state.captionsState.activeSpokenLanguage ?? "en-US")
        let currentCaptionsLanguage = languageDisplayName(for: state.captionsState.activeCaptionLanguage ?? "en-US")
        let enableCaptionsInfoModel = compositeViewModelFactory.makeToggleListItemViewModel(
            icon: .closeCaptions,
            title: localizationProvider.getLocalizedString(.captionsListTitile),
            isToggleOn: isToggleEnabledBinding,
            showToggle: true,
            accessibilityIdentifier: "",
            action: {self.toggleCaptions()})

        let spokenLanguageInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .personVoice,
            title: localizationProvider.getLocalizedString(.captionsSpokenLanguage),
            subtitle: currentSpokenLanguage,
            accessibilityIdentifier: "",
            titleTrailingAccessoryView: .rightChevron,
            action: showSpokenLanguage)

        let captionsLanguageInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .localLanguage,
            title: localizationProvider.getLocalizedString(.captionsCaptionLanguage),
            subtitle: currentCaptionsLanguage,
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            titleTrailingAccessoryView: .rightChevron,
            action: showCaptionsLanguage)

        items = [enableCaptionsInfoModel, spokenLanguageInfoModel, captionsLanguageInfoModel]
    }

    func update(state: AppState) {
        self.state = state
        isDisplayed = state.navigationState.captionsViewVisible
        isToggleEnabled = state.captionsState.isEnabled ?? true
        setupItems(showCaptionsLanguage: self.showCaptionsLanguage,
                   showSpokenLanguage: self.showSpokenLanguage)
    }

    func toggleCaptions() {
        isToggleEnabled.toggle()
    }

    func languageDisplayName(for code: String) -> String {
        let locale = Locale(identifier: code)
        return Locale.current.localizedString(forIdentifier: locale.identifier) ?? "English (US)"
    }
}
