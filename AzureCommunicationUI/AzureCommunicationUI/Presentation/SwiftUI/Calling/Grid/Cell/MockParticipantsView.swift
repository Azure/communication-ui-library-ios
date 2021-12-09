//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

// Mock data
struct  MockParticipantsView: View {
    @ObservedObject var viewModel: MockParticipantsViewModel

    var body: some View {
        GeometryReader { geometry in
            if #available(iOS 14.0, *) {
                let gridItemLayout = Array(repeating: GridItem(.flexible(), spacing: 4), count: 2)
                LazyVGrid(columns: gridItemLayout, spacing: 2) {
                    ForEach((0..<4), id: \.self) {
                        let participantCellViewModel = viewModel.getMockParticipantCellViewModel(
                            index: $0)
                        ParticipantCellView(viewModel: participantCellViewModel)
                        .frame(width: geometry.size.width / 2, height: geometry.size.height / 2, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            } else {
                Text("Grid only available on iOS14")
            }
        }
    }
}
