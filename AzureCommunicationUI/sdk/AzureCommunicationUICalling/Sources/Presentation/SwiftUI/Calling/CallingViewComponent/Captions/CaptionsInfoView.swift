//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CaptionsInfoView: View {
    @ObservedObject var viewModel: CaptionsInfoViewModel
    var avatarViewManager: AvatarViewManagerProtocol

    var body: some View {
       ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    ForEach(viewModel.captionsData.indices, id: \.self) { index in
                        CaptionsInfoCellView(caption: viewModel.captionsData[index],
                                             avatarViewManager: avatarViewManager )
                            .id(index)
                    }
                }.onChange(of: viewModel.captionsData.count) { _ in
                    withAnimation {
                        scrollView.scrollTo(viewModel.captionsData.count - 1, anchor: .bottom)
                    }
                }
            }
       }
    }
}
