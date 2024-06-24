//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct AudioDevicesListView: View {
    @ObservedObject var viewModel: AudioDevicesListViewModel

    init(viewModel: AudioDevicesListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        DrawerListContent(items: viewModel.audioDevicesList)
    }
}
