//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class CaptionsLanguageListViewModel: ObservableObject {
    @Published var items: [DrawerListItemViewModel] = []
    @Published var isDisplayed = false

    private var selectedLanguageStatus: LocalUserState.LanguageState
    private var captionsState: CaptionsState
    private let dispatch: ActionDispatch
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private var isSpokenLanguage = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         dispatchAction: @escaping ActionDispatch,
         state: AppState,
         localizationProvider: LocalizationProviderProtocol) {
        self.dispatch = dispatchAction
        self.selectedLanguageStatus = state.localUserState.languageState
        self.captionsState = state.captionsState
        self.localizationProvider = localizationProvider
        self.compositeViewModelFactory = compositeViewModelFactory
        self.isSpokenLanguage = state.navigationState.spokenLanguageViewVisible

        loadLanguages()
    }

    func update(languageState: LocalUserState.LanguageState,
                navigationState: NavigationState,
                visibilityState: VisibilityState) {
        self.isSpokenLanguage = navigationState.spokenLanguageViewVisible
        isDisplayed = visibilityState.currentStatus == .visible && (isSpokenLanguage ?
                                                                    navigationState.spokenLanguageViewVisible :
                                                                        navigationState.captionsLanguageViewVisible)
        if isDisplayed {
            loadLanguages()
        }
    }

    private func loadLanguages() {
        var newItems: [DrawerListItemViewModel] = []
        let titleKey = isSpokenLanguage ? LocalizationKey.captionsSpokenLanguage :
        LocalizationKey.captionsCaptionLanguage
        let title = localizationProvider.getLocalizedString(titleKey)
        let titleItem =
        TitleDrawerListItemViewModel(title: title,
                                     accessibilityIdentifier:
                                        AccessibilityIdentifier.leaveCallConfirmTitleAccessibilityID.rawValue)

        newItems.append(titleItem)
        let languageIdentifiers = (isSpokenLanguage ?
                                   captionsState.supportedSpokenLanguages :
                                    captionsState.supportedCaptionLanguages) ?? []
        let supportedLanguages = languageIdentifiers.isEmpty ?
        SupportedCaptionsLocale.values : languageIdentifiers.compactMap(Locale.init)
        supportedLanguages.forEach { locale in
            newItems.append(createLanguageOption(language: locale))
        }
        items = newItems
    }

    private func createLanguageOption(language: Locale) -> SelectableDrawerListItemViewModel {
        let languageName = Locale.current.localizedString(forIdentifier: language.identifier) ?? "Unknown"
        let isSelected = true
        return compositeViewModelFactory.makeSelectableDrawerListItemViewModel(
            icon: .none,
            title: languageName,
            isSelected: isSelected,
            onSelectedAction: { [weak self] in
                self?.selectLanguage(language.identifier)
            }
        )
    }

    private func selectLanguage(_ languageIdentifier: String) {
//        if isSpokenLanguage {
//            selectedLanguageStatus.selectedSpokenLanguage = languageIdentifier
//        } else {
//            selectedLanguageStatus.selectedCaptionLanguage = languageIdentifier
//        }
        dispatch(.captionsAction(.setSpokenLanguageRequested(language: languageIdentifier)))
    }
}
