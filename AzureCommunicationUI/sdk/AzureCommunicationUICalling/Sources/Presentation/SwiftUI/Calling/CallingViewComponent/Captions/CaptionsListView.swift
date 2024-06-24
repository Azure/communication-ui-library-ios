//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct CaptionsListView: View {
    @ObservedObject var viewModel: CaptionsListViewModel

    init(viewModel: CaptionsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        DrawerListContent(items: viewModel.items)
    }
}
