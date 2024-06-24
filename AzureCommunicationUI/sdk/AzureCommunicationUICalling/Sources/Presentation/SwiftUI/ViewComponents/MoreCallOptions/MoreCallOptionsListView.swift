//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct MoreCallOptionsListView: View {
    @ObservedObject var viewModel: MoreCallOptionsListViewModel

    init(viewModel: MoreCallOptionsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        DrawerListContent(items: viewModel.items)
    }
}
