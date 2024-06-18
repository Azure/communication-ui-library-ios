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
    private let state: AppState
    private let showCaptionsLanguage: () -> Void
    private let showSpokenLanguage: () -> Void
    @Published var items: [DrawerListItemViewModel] = []
    var isDisplayed: Bool

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         state: AppState,
         showCaptionsLanguage: @escaping () -> Void,
         showSpokenLanguage: @escaping () -> Void,
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
        let currentSpokenLanguage = languageDisplayName(for:
                                                            state.localUserState
            .languageState.spokenStatus.currentIdentifier)
        let currentCaptionsLanguage = languageDisplayName(for:
                                                            state.localUserState
            .languageState.captionsStatus.currentIdentifier)
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
            subtitle: currentSpokenLanguage,
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
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
        isDisplayed = state.navigationState.captionsViewVisible
        isToggleEnabled = state.captionsState.isEnabled ?? true
        setupItems(showCaptionsLanguage: self.showCaptionsLanguage,
                   showSpokenLanguage: self.showCaptionsLanguage)
    }

    func toggleCaptions() {
        isToggleEnabled.toggle()
    }

    func languageDisplayName(for code: String?) -> String {
        guard let code = code, !code.isEmpty else {
            return "Unknown Language"
        }
        return Locale.current.localizedString(forLanguageCode: code) ?? "Unknown Language"
    }

}
