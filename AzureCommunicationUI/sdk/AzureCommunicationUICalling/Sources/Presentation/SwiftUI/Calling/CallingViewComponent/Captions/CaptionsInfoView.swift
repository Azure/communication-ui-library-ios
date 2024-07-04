//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CaptionsInfoView: View {
    @ObservedObject var viewModel: CaptionsInfoViewModel
    var avatarViewManager: AvatarViewManagerProtocol
    @State private var isLastItemVisible = true

    var body: some View {
        ScrollViewReader { scrollView in
            List {
                ForEach(viewModel.captionsData.indices, id: \.self) { index in
                    CaptionsInfoCellView(caption: viewModel.captionsData[index],
                                         avatarViewManager: avatarViewManager)
                        .id(viewModel.captionsData[index].id)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear) // Explicitly setting background color
                        .background(GeometryReader { geometry -> Color in
                            DispatchQueue.main.async {
                                // Update visibility state based on the geometry of the last item
                                if index == viewModel.captionsData.indices.last {
                                   isLastItemVisible = geometry.frame(in: .global).maxY <=
                                    UIScreen.main.bounds.height
                                }
                            }
                            return Color.clear
                        })
                }
            }
            .listStyle(PlainListStyle())
            .background(Color(StyleProvider.color.backgroundColor))
            .frame(maxWidth: 480)
            .onAppear {
                scrollToLastItem(scrollView)
            }
            .onChange(of: viewModel.captionsData) { _ in
                if isLastItemVisible {
                    scrollToLastItem(scrollView)
                }
            }
        }
    }

    private func scrollToLastItem(_ scrollView: ScrollViewProxy) {
        if let lastID = viewModel.captionsData.last?.id {
            withAnimation {
                scrollView.scrollTo(lastID, anchor: .bottom)
            }
        }
    }
}
