//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import UIKit

internal struct CaptionsLanguageListView: View {
    @ObservedObject var viewModel: CaptionsLanguageListViewModel

    init(viewModel: CaptionsLanguageListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        DrawerListContent(items: viewModel.items)
    }
}
