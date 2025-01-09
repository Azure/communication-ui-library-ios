//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import SwiftUI
import FluentUI

struct CaptionsAndRttInfoView: View {
    @ObservedObject var viewModel: CaptionsAndRttInfoViewModel
    var avatarViewManager: AvatarViewManagerProtocol
    @State private var isLastItemVisible = true
    @State private var previousDrawerHeight: CGFloat = 0
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            if viewModel.isLoading {
                loadingView
            } else {
                contentView(geometry: geometry)
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func contentView(geometry: GeometryProxy) -> some View {
        let containerHeight: CGFloat = geometry.size.height

        ScrollViewReader { scrollView in
            ScrollView {
                contentListView(scrollView: scrollView, parentGeometry: geometry)
                    .frame(minHeight: containerHeight, alignment: .bottom)
                    .frame(maxWidth: .infinity)
            }
            .background(Color(StyleProvider.color.drawerColor))
            .onChange(of: containerHeight) { newHeight in
                if newHeight != previousDrawerHeight {
                    previousDrawerHeight = newHeight
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        scrollToBottom(scrollView)
                    }
                }
            }
            .onChange(of: viewModel.displayData) { _ in
                if isLastItemVisible {
                    scrollToBottom(scrollView)
                }
            }
        }
    }

    @ViewBuilder
    private func contentListView(scrollView: ScrollViewProxy, parentGeometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            ForEach(viewModel.displayData.indices, id: \.self) { index in
                let data = viewModel.displayData[index]
                if data.isRttInfo ?? false {
                    rttInfoCell()
                        .id(data.id)
                } else {
                    CaptionsAndRttInfoCellView(
                        displayData: data,
                        avatarViewManager: avatarViewManager,
                        localizationProvider: viewModel.localizationProvider
                    )
                    .id(viewModel.displayData[index].id)
                    .background(lastItemBackgroundIfNeeded(index: index, parentFrame: parentGeometry))
                }
            }.onAppear {
                if isLastItemVisible {
                    scrollToBottom(scrollView)
                }
            }
        }
    }

    @ViewBuilder
    private func lastItemBackgroundIfNeeded(index: Int, parentFrame: GeometryProxy) -> some View {
        if index == viewModel.displayData.indices.last {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        checkLastItemVisibility(geometry: geo, parentFrame: parentFrame)
                    }
            }
        } else {
            EmptyView()
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

    private func rttInfoCell() -> some View {
        HStack(alignment: .top, spacing: 12) {
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

    // MARK: - Helper Methods

    private func scrollToBottom(_ scrollView: ScrollViewProxy) {
        if let lastID = viewModel.displayData.last?.id {
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
        let isVisible = itemFrame.maxY > parentBounds.minY && itemFrame.minY < parentBounds.maxY

        if isLastItemVisible != isVisible {
            isLastItemVisible = isVisible
        }
    }
}
