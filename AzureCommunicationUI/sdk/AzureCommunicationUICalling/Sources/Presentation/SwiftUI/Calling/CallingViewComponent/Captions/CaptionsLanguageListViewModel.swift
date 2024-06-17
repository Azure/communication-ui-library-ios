//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class CaptionsLanguageListViewModel: ObservableObject {
    @Published var languageOptions: [SelectableDrawerListItemViewModel] = []
    @Published var isDisplayed = false

    private var selectedLanguageStatus: LocalUserState.LanguageState
    private let dispatch: ActionDispatch
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         dispatchAction: @escaping ActionDispatch,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol) {
        self.dispatch = dispatchAction
        self.selectedLanguageStatus = localUserState.languageState
        self.localizationProvider = localizationProvider
        self.compositeViewModelFactory = compositeViewModelFactory
        loadLanguages()
    }

    func update(languageState: LocalUserState.LanguageState,
                navigationState: NavigationState,
                visibilityState: VisibilityState) {
        if languageState.selectedLanguage != selectedLanguageStatus.selectedLanguage || languageOptions.isEmpty {
            self.selectedLanguageStatus = languageState
            self.languageOptions = getAvailableLanguages(selectedLanguage: languageState.selectedLanguage)
        }
        isDisplayed = visibilityState.currentStatus == .visible &&
        navigationState.spokenLanguageViewVisible
    }

    private func loadLanguages() {
        let supportedLanguages = SupportedCaptionsLocale.values
        languageOptions = supportedLanguages.map { locale in
            createLanguageOption(language: locale)
        }
    }

    private func getAvailableLanguages(selectedLanguage: String) -> [SelectableDrawerListItemViewModel] {
        // Assuming this might involve some filtering or additional logic based on availability
        return SupportedCaptionsLocale.values.map { createLanguageOption(language: $0) }
    }

    private func createLanguageOption(language: Locale) -> SelectableDrawerListItemViewModel {
        let languageName = Locale.current.localizedString(forIdentifier: language.identifier) ?? "Unknown"
        let isSelected = (language.identifier == selectedLanguageStatus.selectedLanguage)
        return compositeViewModelFactory.makeSelectableDrawerListItemViewModel(
            icon: .checkmark,
            title: languageName,
            isSelected: isSelected,
            onSelectedAction: { [weak self] in
                self?.selectLanguage(language.identifier)
            }
        )
    }

    private func selectLanguage(_ languageIdentifier: String) {
        selectedLanguageStatus.selectedLanguage = languageIdentifier
        dispatch(.captionsAction(.setSpokenLanguageRequested(language: languageIdentifier)))
        languageOptions = languageOptions.map { option in
            var updatedOption = option
            updatedOption.isSelected = (option.title ==
                                        Locale.current.localizedString(forIdentifier: languageIdentifier) ?? "Unknown")
            return updatedOption
        }
    }
}
