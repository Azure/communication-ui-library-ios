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
    @Published var items: [DrawerListItemViewModel] = []

    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private var state: AppState
    private let showCaptionsLanguage: () -> Void
    private let showSpokenLanguage: () -> Void
    private let dispatch: ActionDispatch
    var isDisplayed: Bool

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         state: AppState,
         dispatchAction: @escaping ActionDispatch,
         showSpokenLanguage: @escaping () -> Void,
         showCaptionsLanguage: @escaping () -> Void,
         isDisplayed: Bool
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.state = state
        self.dispatch = dispatchAction
        self.showSpokenLanguage = showSpokenLanguage
        self.showCaptionsLanguage = showCaptionsLanguage
        self.isDisplayed = isDisplayed
        self.isToggleEnabled = state.captionsState.isStarted ?? false
        setupItems()
    }

    private func setupItems() {
        items.removeAll()

        let enableCaptionsInfoModel = compositeViewModelFactory.makeToggleListItemViewModel(
            icon: .closeCaptions,
            title: localizationProvider.getLocalizedString(.captionsListTitile),
            isToggleOn: Binding(get: { self.isToggleEnabled }, set: toggleCaptions),
            showToggle: true,
            accessibilityIdentifier: "",
            action: {})

        let spokenLanguageInfoModel = compositeViewModelFactory.makeLanguageListItemViewModel(
            icon: .personVoice,
            title: localizationProvider.getLocalizedString(.captionsSpokenLanguage),
            subtitle: languageDisplayName(for: state.captionsState.activeSpokenLanguage ?? "en-US"),
            accessibilityIdentifier: "",
            titleTrailingAccessoryView: .rightChevron,
            isEnabled: self.isToggleEnabled,
            action: self.isToggleEnabled ? showSpokenLanguage : {})

        let captionsLanguageInfoModel = compositeViewModelFactory.makeLanguageListItemViewModel(
            icon: .localLanguage,
            title: localizationProvider.getLocalizedString(.captionsCaptionLanguage),
            subtitle: languageDisplayName(for: state.captionsState.activeCaptionLanguage ?? "en-US"),
            accessibilityIdentifier: "",
            titleTrailingAccessoryView: .rightChevron,
            isEnabled: self.isToggleEnabled,
            action: self.isToggleEnabled ? showCaptionsLanguage : {})

        items = [enableCaptionsInfoModel, spokenLanguageInfoModel, captionsLanguageInfoModel]
    }
    func update(state: AppState) {
        self.state = state
        isDisplayed = state.navigationState.captionsViewVisible
        isToggleEnabled = state.captionsState.isStarted ?? false
        setupItems()
    }

    func toggleCaptions(newValue: Bool) {
        isToggleEnabled = newValue
        if isToggleEnabled {
            dispatch(.captionsAction(.startRequested(language: "en-us")))
        } else {
            dispatch(.captionsAction(.stopRequested))
        }
        setupItems()
    }

    func languageDisplayName(for code: String) -> String {
        let locale = Locale(identifier: code)
        return Locale.current.localizedString(forIdentifier: locale.identifier) ?? "English (United States)"
    }
}
