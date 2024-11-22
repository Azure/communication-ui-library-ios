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
        GeometryReader { geometry in
            let drawerHeight = geometry.size.height
            if viewModel.isLoading {
                loadingView
            } else {
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack(spacing: 0) {
                            if viewModel.isRttDisplayed {
                                rttInfoView
                                    .padding(.horizontal, 10)
                                    .padding(.bottom, 8)
                                    .transition(.move(edge: .bottom))
                            }
                            ForEach(viewModel.captionsRttData.indices, id: \.self) { index in
                                CaptionsInfoCellView(
                                    caption: viewModel.captionsRttData[index],
                                    avatarViewManager: avatarViewManager
                                )
                                .id(viewModel.captionsRttData[index].id)
                                .background(
                                    GeometryReader { geo in
                                        if index == viewModel.captionsRttData.indices.last {
                                            Color.clear
                                                .onAppear {
                                                    checkLastItemVisibility(geometry: geo)
                                                }
                                                .onChange(of: viewModel.captionsRttData) { _ in
                                                    checkLastItemVisibility(geometry: geo)
                                                }
                                        }
                                    }
                                )
                            }
                        }
                        .frame(minHeight: drawerHeight, alignment: .bottom)
                        .frame(maxWidth: .infinity)
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
    }

    private func scrollToBottom(_ scrollView: ScrollViewProxy) {
        if let lastID = viewModel.captionsRttData.last?.id {
            withAnimation {
                scrollView.scrollTo(lastID, anchor: .bottom)
            }
        } else if viewModel.isRttDisplayed {
            withAnimation {
                scrollView.scrollTo("RTTInfoView", anchor: .bottom)
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

    private var rttInfoView: some View {
        return HStack(alignment: .top, spacing: 12) {
            Icon(name: CompositeIcon.rtt, size: DrawerListConstants.iconSize)
                .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                .accessibilityHidden(true)
                .padding([.top, .leading], 10)
            Text(viewModel.rttInfoMessage)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.top, .trailing, .bottom], 10)
        }
        .background(Color(StyleProvider.color.surface))
        .cornerRadius(8)
        .padding(.horizontal, 10)
        .id("RTTInfoView")
    }
}
