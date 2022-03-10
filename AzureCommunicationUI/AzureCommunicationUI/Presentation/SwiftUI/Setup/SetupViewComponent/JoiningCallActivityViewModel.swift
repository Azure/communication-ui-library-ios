//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class JoiningCallActivityViewModel {
    let title: String
    private let localizationProvider: LocalizationProvider

    init(localizationProvider: LocalizationProvider) {
        self.localizationProvider = localizationProvider
        self.title = localizationProvider.getLocalizedString(.joiningCall)
    }
}
