//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct CaptionsRttListView: View {
    @ObservedObject var viewModel: CaptionsRttListViewModel
    let avatarManager: AvatarViewManagerProtocol

    init(viewModel: CaptionsRttListViewModel,
         avatarManager: AvatarViewManagerProtocol) {
        self.viewModel = viewModel
        self.avatarManager = avatarManager
    }

    var body: some View {
        DrawerListView(sections: [DrawerListSection(header: nil, items: viewModel.items)],
                       avatarManager: avatarManager)
    }
}
