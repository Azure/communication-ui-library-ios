//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol OverlayViewModelProtocol {
    var title: String { get }
    var subtitle: String? { get }
    var actionTitle: String? { get }
    var action: ()? { get }
}

struct LobbyOverlayViewModel: OverlayViewModelProtocol {
    let localizationProvider: LocalizationProviderProtocol

    var title: String {
        return localizationProvider.getLocalizedString(.waitingForHost)
    }

    var subtitle: String? {
        return localizationProvider.getLocalizedString(.waitingDetails)
    }

    var actionTitle: String?

    var action: ()?
}

struct OnHoldOverlayViewModel: OverlayViewModelProtocol {
    let localizationProvider: LocalizationProviderProtocol

    var title: String {
        return localizationProvider.getLocalizedString(.onHoldTitle)
    }

    var subtitle: String? {
        return localizationProvider.getLocalizedString(.onHoldMessage)
    }

    var actionTitle: String?

    var action: ()?
}
