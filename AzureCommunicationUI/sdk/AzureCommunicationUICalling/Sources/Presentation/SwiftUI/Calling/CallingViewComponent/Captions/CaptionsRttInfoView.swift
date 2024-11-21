//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct CaptionsRttInfoView: View {
    @ObservedObject var viewModel: CaptionsRttInfoViewModel
    var avatarViewManager: AvatarViewManagerProtocol
    @State private var isLastItemVisible = true
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        if viewModel.isLoading {
            loadingView
        } else {
            ScrollViewReader { scrollView in
                List {
                    ForEach(viewModel.captionsRttData.indices, id: \.self) { index in
                        CaptionsInfoCellView(caption: viewModel.captionsRttData[index],
                                             avatarViewManager: avatarViewManager)
                        .id(viewModel.captionsRttData[index].id)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear) // Explicitly setting background color
                        .onAppear {
                            if index == viewModel.captionsRttData.indices.last {
                                isLastItemVisible = true
                            }
                        }
                        .onDisappear {
                             if index == viewModel.captionsRttData.indices.last {
                                 isLastItemVisible = false
                             }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color(StyleProvider.color.drawerColor))
                .frame(maxWidth: 480)
                .onAppear {
                    scrollToLastItem(scrollView)
                }
                .onChange(of: viewModel.captionsRttData) { newCaptions in
                    // Check if the last item has changed
                      _ = newCaptions.last?.id
                      if isLastItemVisible {
                        scrollToLastItem(scrollView)
                    }
                }
            }
        }
    }

    private func scrollToLastItem(_ scrollView: ScrollViewProxy) {
//        if let lastID = viewModel.captionsRttData.last?.id {
//            withAnimation {
//                scrollView.scrollTo(lastID, anchor: .bottom)
//            }
//        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ActivityIndicator(size: .small)
                    .isAnimating(true)
                Text(viewModel.loadingMessage)
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textSecondary))
                Spacer()
            }
            Spacer()
        }
    }
}
