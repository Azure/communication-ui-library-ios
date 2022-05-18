//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol OverlayViewModel {
    var title: String { get }
    var subtitle: String? { get set }
    var actionTitle: String? { get set }
    var action: ()? { get set }
}

struct LobbyOverlayViewModel: OverlayViewModel {
    var title: String

    var subtitle: String?

    var actionTitle: String?

    var action: ()?
//    let localizationProvider: LocalizationProviderProtocol
//
//    var title: String {
//        return localizationProvider.getLocalizedString(.waitingForHost)
//    }
//
//    var subtitle: String {
//        return localizationProvider.getLocalizedString(.waitingDetails)
//    }
}
