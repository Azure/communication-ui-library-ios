//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct ParticipantsListView: View {
    @ObservedObject var viewModel: ParticipantsListViewModel
    let avatarManager: AvatarViewManagerProtocol
    init(viewModel: ParticipantsListViewModel,
         avatarManager: AvatarViewManagerProtocol) {
        self.viewModel = viewModel
        self.avatarManager = avatarManager
    }

    var body: some View {
        DrawerListView(sections: [DrawerListSection(
            header: viewModel.meetingParticipantsTitle,
            items: viewModel.meetingParticipants)],
                       avatarManager: avatarManager)
    }
}
