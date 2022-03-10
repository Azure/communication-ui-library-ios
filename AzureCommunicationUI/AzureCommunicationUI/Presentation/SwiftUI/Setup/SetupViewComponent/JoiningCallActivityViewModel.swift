//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct JoiningCallActivityViewModel {
    let localizationProvider: LocalizationProvider

    var title: String {
        return localizationProvider.getLocalizedString(.joiningCall)
    }
}
