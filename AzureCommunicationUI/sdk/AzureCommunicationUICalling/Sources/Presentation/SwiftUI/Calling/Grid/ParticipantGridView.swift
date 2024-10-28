//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ParticipantGridView: View {
    let viewModel: ParticipantGridViewModel
    let avatarViewManager: AvatarViewManagerProtocol
    let screenSize: ScreenSizeClassType
    @State var gridsCount: Int = 0
    var body: some View {
        return Group {
            ParticipantGridLayoutView(cellViewModels: viewModel.participantsCellViewModelArr,
                                      rendererViewManager: viewModel.rendererViewManager,
                                      avatarViewManager: avatarViewManager,
                                      screenSize: screenSize)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(gridsCount)
            .onReceive(viewModel.$gridsCount) {
                gridsCount = $0
            }
    }
}
