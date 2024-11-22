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
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer() // Pushes content to the bottom

                        ForEach(viewModel.captionsRttData.indices, id: \.self) { index in
                            CaptionsInfoCellView(
                                caption: viewModel.captionsRttData[index],
                                avatarViewManager: avatarViewManager
                            )
                            .id(viewModel.captionsRttData[index].id)
                            .background(
                                GeometryReader { geometry in
                                    if index == viewModel.captionsRttData.indices.last {
                                        Color.clear
                                            .onAppear {
                                                checkLastItemVisibility(geometry: geometry)
                                            }
                                            .onChange(of: viewModel.captionsRttData) { _ in
                                                checkLastItemVisibility(geometry: geometry)
                                            }
                                    }
                                }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity) // Ensures full width
                }
                .background(Color(StyleProvider.color.drawerColor))
                .onAppear {
                    scrollToBottom(scrollView)
                }
                .onChange(of: viewModel.captionsRttData) { _ in
                    if isLastItemVisible {
                        scrollToBottom(scrollView)
                    }
                }
            }
        }
    }

    private func scrollToBottom(_ scrollView: ScrollViewProxy) {
        if let lastID = viewModel.captionsRttData.last?.id {
            withAnimation {
                scrollView.scrollTo(lastID, anchor: .bottom)
            }
        }
    }

    private func checkLastItemVisibility(geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height

        // Check if the bottom of the last item (adjusted for padding) is visible
        let isVisible = frame.maxY <= screenHeight
        if isLastItemVisible != isVisible {
            isLastItemVisible = isVisible
        }
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
