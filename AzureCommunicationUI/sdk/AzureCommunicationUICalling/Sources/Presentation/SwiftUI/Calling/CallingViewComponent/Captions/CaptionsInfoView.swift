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
                LazyVStack {
                    ForEach(viewModel.captionsData.indices, id: \.self) { index in
                        CaptionsInfoCellView(caption: viewModel.captionsData[index],
                                             avatarViewManager: avatarViewManager)
                            .id(index)
                    }
                }
                .onAppear {
                    scrollView.scrollTo(viewModel.captionsData.count - 1, anchor: .bottom)
                }
                .onChange(of: viewModel.captionsData.count) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            scrollView.scrollTo(viewModel.captionsData.count - 1, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}
