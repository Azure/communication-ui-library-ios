//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct ParticipantMenuView: View {
    @ObservedObject var viewModel: ParticipantMenuViewModel
    let avatarManager: AvatarViewManagerProtocol

    init(viewModel: ParticipantMenuViewModel,
         avatarManager: AvatarViewManagerProtocol) {
        self.viewModel = viewModel
        self.avatarManager = avatarManager
    }

    var body: some View {
        DrawerListView(items: viewModel.items,
                       avatarManager: avatarManager)
    }
}
