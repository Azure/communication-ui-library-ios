//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct LobbyOverlayViewModel: OverlayViewModelProtocol {
    private let localizationProvider: LocalizationProviderProtocol

    init(localizationProvider: LocalizationProviderProtocol) {
        self.localizationProvider = localizationProvider
    }

    var title: String {
        return localizationProvider.getLocalizedString(.waitingForHost)
    }

    var subtitle: String? {
        return localizationProvider.getLocalizedString(.waitingDetails)
    }

    var getActionButtonViewModel: PrimaryButtonViewModel?
}
