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
    @State private var previousDrawerHeight: CGFloat = 0 // Track the previous height
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            var contentHeight = geometry.size.height
            let parentFrame = geometry
            if viewModel.isLoading {
                loadingView
            } else {
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack(spacing: 0) {
//                            if viewModel.isRttDisplayed {
//                                rttInfoView
//                                    .padding(.horizontal, 10)
//                                    .padding(.bottom, 8)
//                                    .transition(.move(edge: .bottom))
//                            }
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
                                                    contentHeight = geo.size.height
                                                    checkLastItemVisibility(
                                                        geometry: geo,
                                                        parentFrame: parentFrame
                                                    )
                                                }
                                                .onChange(of: viewModel.captionsRttData) { _ in
                                                    checkLastItemVisibility(
                                                        geometry: geo,
                                                        parentFrame: parentFrame
                                                    )
                                                    contentHeight = geo.size.height
                                                }
                                        }
                                    }
                                )
                            }
                        }
                        .frame(minHeight: geometry.size.height, alignment: .bottom)
                        .frame(maxWidth: .infinity)
                    }
                    .background(Color(StyleProvider.color.drawerColor))
                    .onChange(of: viewModel.captionsRttData) { _ in
                        if isLastItemVisible {
                            scrollToBottom(scrollView)
                        }
                    }
                    .onChange(of: contentHeight) { newHeight in
                        if newHeight != previousDrawerHeight {
                            previousDrawerHeight = newHeight
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

    private func checkLastItemVisibility(geometry: GeometryProxy, parentFrame: GeometryProxy) {
        let itemFrame = geometry.frame(in: .global)
        let parentBounds = parentFrame.frame(in: .global)

        // Check if the last item's frame intersects with the parent bounds
        let isVisible = itemFrame.maxY > parentBounds.minY && itemFrame.minY < parentBounds.maxY

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
