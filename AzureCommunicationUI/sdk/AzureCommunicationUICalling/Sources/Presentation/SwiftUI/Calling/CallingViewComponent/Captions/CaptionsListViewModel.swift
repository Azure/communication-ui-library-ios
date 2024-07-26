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
    @Published var items: [DrawerGenericItemViewModel] = []

    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let showCaptionsLanguage: () -> Void
    private let showSpokenLanguage: () -> Void
    private let dispatch: ActionDispatch
    private let captionsOptions: CaptionsOptions
    var isDisplayed: Bool

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         captionsOptions: CaptionsOptions,
         state: AppState,
         dispatchAction: @escaping ActionDispatch,
         showSpokenLanguage: @escaping () -> Void,
         showCaptionsLanguage: @escaping () -> Void,
         isDisplayed: Bool
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.dispatch = dispatchAction
        self.showSpokenLanguage = showSpokenLanguage
        self.showCaptionsLanguage = showCaptionsLanguage
        self.isDisplayed = isDisplayed
        self.isToggleEnabled = state.captionsState.isStarted
        self.captionsOptions = captionsOptions

        setupItems(state: state)
    }

    private func setupItems(state: AppState) {
        items.removeAll()

        let enableCaptionsInfoModel = compositeViewModelFactory.makeToggleListItemViewModel(
            title: localizationProvider.getLocalizedString(.captionsListTitile),
            isToggleOn: Binding(get: { self.isToggleEnabled }, set: toggleCaptions),
            showToggle: true,
            accessibilityIdentifier: "",
            startIcon: .closeCaptions,
            action: {})

        let spokenLanguageInfoModel = compositeViewModelFactory.makeLanguageListItemViewModel(
            title: localizationProvider.getLocalizedString(.captionsSpokenLanguage),
            subtitle: languageDisplayName(for: state.captionsState.spokenLanguage ?? "en-US"),
            accessibilityIdentifier: "",
            startIcon: .personVoice,
            endIcon: .rightChevron,
            isEnabled: self.isToggleEnabled,
            action: self.isToggleEnabled ? showSpokenLanguage : {})

        let captionsLanguageInfoModel = compositeViewModelFactory.makeLanguageListItemViewModel(
            title: localizationProvider.getLocalizedString(.captionsCaptionLanguage),
            subtitle: languageDisplayName(for: state.captionsState.captionLanguage ?? "en"),
            accessibilityIdentifier: "",
            startIcon: .localLanguage,
            endIcon: .rightChevron,
            isEnabled: self.isToggleEnabled,
            action: self.isToggleEnabled ? showCaptionsLanguage : {})
        if state.captionsState.activeType == .teams {
            items = [enableCaptionsInfoModel, spokenLanguageInfoModel, captionsLanguageInfoModel]
        } else {
            items = [enableCaptionsInfoModel, spokenLanguageInfoModel]
        }

    }
    func update(state: AppState) {
        isDisplayed = state.navigationState.captionsViewVisible
        isToggleEnabled = state.captionsState.isStarted
        setupItems(state: state)
    }

    private func toggleCaptions(newValue: Bool) {
        isToggleEnabled = newValue
        let language = captionsOptions.spokenLanguage?.lowercased() ?? ""
        if isToggleEnabled {
            dispatch(.captionsAction(.turnOnCaptions(language: language)))
        } else {
            dispatch(.captionsAction(.turnOffCaptions))
        }
    }

    private func languageDisplayName(for code: String) -> String {
        let locale = Locale(identifier: code)
        return Locale.current.localizedString(forIdentifier: locale.identifier) ?? ""
    }
}
