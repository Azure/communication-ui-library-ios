//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class CaptionsLanguageListViewModel: ObservableObject {
    @Published var supportedLanguages: [SelectableDrawerListItemViewModel] = []
    @Published var activeLanguage: String?
    @Published var isDisplayed = false

    private var captionsState: CaptionsState
    private let dispatch: ActionDispatch
    private let localizationProvider: LocalizationProviderProtocol
    private var cancellables = Set<AnyCancellable>()

    init(isDisplayed: Bool,
         dispatchAction: @escaping ActionDispatch,
         captionsState: CaptionsState,
         localizationProvider: LocalizationProviderProtocol) {
        self.dispatch = dispatchAction
        self.captionsState = captionsState
        self.localizationProvider = localizationProvider
        loadLanguages()
    }

    private func loadLanguages() {
        // First, check if supportedSpokenLanguages is nil and provide an empty array as a default
        var supportedLanguageList = captionsState.supportedSpokenLanguages

        // Check if the list is nil or empty
        if supportedLanguageList?.isEmpty ?? true {
            supportedLanguageList = SupportedCaptionsLocale.values.map { $0.identifier }
        }
        supportedLanguages = supportedLanguageList?.compactMap {language ->
            SelectableDrawerListItemViewModel? in
            SelectableDrawerListItemViewModel(
                icon: .checkmark, // Assume you have defined this icon somewhere as an enum or similar
                title: language,
                accessibilityIdentifier: language,
                isSelected: language == captionsState.activeSpokenLanguage,
                action: {}
            )
        } ?? []
    }

    func selectLanguage(at index: Int) {
        supportedLanguages = supportedLanguages.enumerated().map { idx, language in
            let updatedLanguage = language
            updatedLanguage.isSelected = idx == index
            return updatedLanguage
        }
    }

    private func refreshSelections() {
        supportedLanguages = supportedLanguages.map {
            let newItem = $0
            newItem.isSelected = $0.title == captionsState.activeSpokenLanguage
            return newItem
        }
    }

    func update(state: AppState) {
        isDisplayed = state.navigationState.spokenLanguageViewVisible
    }

    func hideForm() {
        dispatch(.hideSpokenLanguageView)
    }
}
