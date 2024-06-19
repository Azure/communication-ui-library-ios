//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct LeaveCallConfirmationView: View {
    @ObservedObject var viewModel: LeaveCallConfirmationViewModel

    init(viewModel: LeaveCallConfirmationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        DrawerListContent(items: viewModel.options)
    }
}
