//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct LobbyOverlayViewModel {
    let localizationProvider: LocalizationProviderProtocol

    var title: String {
        return localizationProvider.getLocalizedString(.waitingForHost)
    }

    var subtitle: String {
        return localizationProvider.getLocalizedString(.waitingDetails)
    }
}
