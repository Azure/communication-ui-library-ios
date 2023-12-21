//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class JoiningCallActivityViewModel: ObservableObject {
    let localizationProvider: LocalizationProviderProtocol
    @Published var title: String = ""

    init(compositeCallType: CompositeCallType,
         localizationProvider: LocalizationProviderProtocol) {
        self.localizationProvider = localizationProvider
        if compositeCallType == CompositeCallType.oneToNCallOutgoing {
            title = localizationProvider.getLocalizedString(.startingCall)
        } else {
            title = localizationProvider.getLocalizedString(.joiningCall)
        }
    }

    func update(callingstatus: CallingStatus) {
        if callingstatus == CallingStatus.ringing {
            title = localizationProvider.getLocalizedString(.ringingCall)
        }
    }
}
