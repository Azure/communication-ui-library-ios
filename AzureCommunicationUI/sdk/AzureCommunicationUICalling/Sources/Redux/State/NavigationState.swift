//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum NavigationStatus {
    case setup
    case inCall
    case exit
}

struct NavigationState: Equatable {

    let status: NavigationStatus
    let supportFormVisible: Bool
    let captionsViewVisible: Bool
    let captionsLanguageViewVisible: Bool
    let spokenLanguageViewVisible: Bool

    init(status: NavigationStatus = .setup,
         supportFormVisible: Bool = false,
         captionsViewVisible: Bool = false,
         captionsLanguageViewVisible: Bool = false,
         spokenLanguageViewVisible: Bool = false) {
        self.status = status
        self.supportFormVisible = supportFormVisible
        self.captionsViewVisible = captionsViewVisible
        self.captionsLanguageViewVisible = captionsLanguageViewVisible
        self.spokenLanguageViewVisible = spokenLanguageViewVisible
    }

    static func == (lhs: NavigationState, rhs: NavigationState) -> Bool {
        return lhs.status == rhs.status
    }
}
