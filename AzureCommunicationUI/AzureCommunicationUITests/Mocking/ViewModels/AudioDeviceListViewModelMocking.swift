//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class AudioDeviceListViewModelMocking: AudioDeviceListViewModel {
    var updateState: ((LocalUserState.AudioDeviceSelectionStatus) -> Void)?

    override func update(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus) {
        updateState?(audioDeviceStatus)
    }
}
