//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct AudioDevicesListView: View {
    @ObservedObject var viewModel: AudioDevicesListViewModel
    let avatarManager: AvatarViewManagerProtocol

    init(viewModel: AudioDevicesListViewModel,
         avatarManager: AvatarViewManagerProtocol) {
        self.viewModel = viewModel
        self.avatarManager = avatarManager
    }

    var body: some View {
        DrawerListView(items: viewModel.audioDevicesList,
                       avatarManager: avatarManager)
    }
}
