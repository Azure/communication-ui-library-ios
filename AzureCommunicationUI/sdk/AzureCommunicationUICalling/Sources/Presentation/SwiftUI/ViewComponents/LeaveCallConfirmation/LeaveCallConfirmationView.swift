//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct LeaveCallConfirmationView: View {
    @ObservedObject var viewModel: LeaveCallConfirmationViewModel
    let avatarManager: AvatarViewManagerProtocol
    init(viewModel: LeaveCallConfirmationViewModel,
         avatarManager: AvatarViewManagerProtocol) {
        self.viewModel = viewModel
        self.avatarManager = avatarManager
    }

    var body: some View {
        DrawerListView(items: viewModel.options, avatarManager: avatarManager)
    }
}
