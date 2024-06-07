//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class CaptionsLanguageListCellViewModel {
    let localizationProvider: LocalizationProviderProtocol
    let language: String

    init(language: String,
         localizationProvider: LocalizationProviderProtocol) {
        self.localizationProvider = localizationProvider
        self.language = language
    }

    func getCellLanguageName(with language: String) -> String {
        let languageName = language
        return languageName
//        ? localizationProvider.getLocalizedString(.unnamedParticipant)
//        : name
//        return isLocalParticipant
//        ? localizationProvider.getLocalizedString(.localeParticipantWithSuffix, displayName)
//        : displayName
    }
}
