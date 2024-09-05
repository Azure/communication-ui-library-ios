//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class CaptionsLanguageListViewModel: ObservableObject {
    @Published var items: [BaseDrawerItemViewModel] = []
    @Published var isDisplayed = false

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
        self.captionsState = state.captionsState
        self.localizationProvider = localizationProvider
        self.compositeViewModelFactory = compositeViewModelFactory
        self.isSpokenLanguage = state.navigationState.spokenLanguageViewVisible

        loadLanguages()
    }

    func update(state: AppState) {
        let navigationState = state.navigationState
        self.isSpokenLanguage = navigationState.spokenLanguageViewVisible
        self.captionsState = state.captionsState
        isDisplayed = state.visibilityState.currentStatus == .visible && (isSpokenLanguage ?
                                                                    navigationState.spokenLanguageViewVisible :
                                                                        navigationState.captionsLanguageViewVisible)
        loadLanguages()
    }

    private func loadLanguages() {
        var newItems: [BaseDrawerItemViewModel ] = []
        newItems.append(createTitleItem())
        let languageIdentifiers = (isSpokenLanguage ?
                                   captionsState.supportedSpokenLanguages :
                                    captionsState.supportedCaptionLanguages) ?? []
        let supportedLanguages = languageIdentifiers.compactMap(Locale.init)
        supportedLanguages.forEach { locale in
            newItems.append(createLanguageOption(language: locale))
        }
        items = newItems
    }

    private func createTitleItem() -> TitleDrawerListItemViewModel {
        let titleKey = self.isSpokenLanguage ? LocalizationKey.captionsSpokenLanguage :
        LocalizationKey.captionsCaptionLanguage
        let title = localizationProvider.getLocalizedString(titleKey)
        return TitleDrawerListItemViewModel(title: title,
                                            accessibilityIdentifier: "")
    }

    private func createLanguageOption(language: Locale) -> DrawerSelectableItemViewModel {
        let languageName = Locale.current.localizedString(forIdentifier: language.identifier) ?? "Unknown"

        let isSelected = (language.identifier == currentSelectedIdentifier)
        return compositeViewModelFactory.makeCaptionsLangaugeCellViewModel(
            title: languageName,
            isSelected: isSelected,
            accessibilityLabel: isSelected ?
            localizationProvider.getLocalizedString(.selected, languageName) : languageName,
            onSelectedAction: { [weak self] in
                self?.selectLanguage(language.identifier)
            }
        )
    }

    private var currentSelectedIdentifier: String? {
        isSpokenLanguage ? captionsState.spokenLanguage :
        captionsState.captionLanguage
    }

    private func selectLanguage(_ languageIdentifier: String) {
        let language = convertLocaleIdentifierToLowercaseRegionCode(languageIdentifier)
        if isSpokenLanguage {
            dispatch(.captionsAction(.setSpokenLanguageRequested(language: language)))
        } else {
            dispatch(.captionsAction(.setCaptionLanguageRequested(language: languageIdentifier)))
        }
    }

    private func convertLocaleIdentifierToLowercaseRegionCode(_ identifier: String) -> String {
        let components = identifier.split(separator: "-")
        guard components.count == 2 else {
            return identifier
        }
        return "\(components[0])-\(components[1].lowercased())"
    }
}
