//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct ParticipantsListView: View {
    @ObservedObject var viewModel: ParticipantsListViewModel

    init(viewModel: ParticipantsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        DrawerListContent(items: viewModel.drawerListItems)
    }
}
