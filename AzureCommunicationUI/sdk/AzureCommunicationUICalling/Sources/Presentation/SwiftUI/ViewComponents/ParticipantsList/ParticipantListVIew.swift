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
        var sections: [DrawerListSection] = []

        // Include Lobby Participants if in VM
        if viewModel.lobbyParticipants.count > 0 {
            sections.append(DrawerListSection(
                header: viewModel.lobbyParticipantsTitle,
                items: viewModel.lobbyParticipants))

        }

        sections.append(DrawerListSection(
                header: viewModel.meetingParticipantsTitle,
                items: viewModel.meetingParticipants))

        return DrawerListView(sections: sections,
                       avatarManager: avatarManager)
    }
}
