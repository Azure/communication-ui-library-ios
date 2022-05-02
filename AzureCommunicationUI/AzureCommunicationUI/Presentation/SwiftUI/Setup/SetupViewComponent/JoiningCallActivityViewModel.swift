//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct JoiningCallActivityViewModel {
    let localizationProvider: LocalizationProviderProtocol

    var title: String {
        return localizationProvider.getLocalizedString(.joiningCall)
    }
}
