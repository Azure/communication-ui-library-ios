//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

class AvatarViewManagerMocking: AvatarViewManager {
    var updateStorage: (([String]) -> Void)?

    override func updateStorage(with removedParticipantsIds: [String]) {
        updateStorage?(removedParticipantsIds)
    }
}
