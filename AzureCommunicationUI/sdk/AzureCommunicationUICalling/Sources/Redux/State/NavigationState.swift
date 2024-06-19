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
    let endCallConfirmationVisible: Bool
    let audioSelectionVisible: Bool
    let moreOptionsVisible: Bool
    let supportShareSheetVisible: Bool
    init(status: NavigationStatus = .setup,
         supportFormVisible: Bool = false,
         captionsViewVisible: Bool = false,
         captionsLanguageViewVisible: Bool = false,
         spokenLanguageViewVisible: Bool = false,
         endCallConfirmationVisible: Bool = false,
         audioSelectionVisible: Bool = false,
         moreOptionsVisible: Bool = false,
         supportShareSheetVisible: Bool = false
    ) {
        self.status = status
        self.supportFormVisible = supportFormVisible
        self.captionsViewVisible = captionsViewVisible
        self.captionsLanguageViewVisible = captionsLanguageViewVisible
        self.spokenLanguageViewVisible = spokenLanguageViewVisible
        self.endCallConfirmationVisible = endCallConfirmationVisible
        self.audioSelectionVisible = audioSelectionVisible
        self.moreOptionsVisible = moreOptionsVisible
        self.supportShareSheetVisible = supportShareSheetVisible
    }

    static func == (lhs: NavigationState, rhs: NavigationState) -> Bool {
        return lhs.status == rhs.status
            && lhs.supportFormVisible == rhs.supportFormVisible
            && lhs.captionsLanguageViewVisible == rhs.captionsLanguageViewVisible
            && lhs.spokenLanguageViewVisible == rhs.spokenLanguageViewVisible
            && lhs.captionsViewVisible == rhs.captionsViewVisible
            && lhs.endCallConfirmationVisible == rhs.endCallConfirmationVisible
            && lhs.audioSelectionVisible == rhs.audioSelectionVisible
            && lhs.moreOptionsVisible == rhs.moreOptionsVisible
            && lhs.supportShareSheetVisible == rhs.supportShareSheetVisible
    }
}
