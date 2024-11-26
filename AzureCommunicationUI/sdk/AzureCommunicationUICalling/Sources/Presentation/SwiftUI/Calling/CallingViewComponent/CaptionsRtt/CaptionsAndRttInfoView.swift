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
    @State private var previousDrawerHeight: CGFloat = 0 // Track the previous height
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            let parentFrame = geometry
            if viewModel.isLoading {
                loadingView
            } else {
                ScrollViewReader { scrollView in
                    ScrollView {
                        content(scrollView: scrollView, parentFrame: parentFrame)
                            .frame(minHeight: geometry.size.height, alignment: .bottom) // fix the height
                            .frame(maxWidth: .infinity)
                            .background(Color(StyleProvider.color.drawerColor))
                    }
                    .onChange(of: viewModel.displayData) { _ in
                        if isLastItemVisible {
                            scrollToBottom(scrollView)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func content(scrollView: ScrollViewProxy, parentFrame: GeometryProxy) -> some View {
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
                    .background(lastItemBackground(index: index, parentFrame: parentFrame))
                }
            }
        }
    }

    @ViewBuilder
    private func lastItemBackground(index: Int, parentFrame: GeometryProxy) -> some View {
        // check last item is visiable on the screen
        if index == viewModel.displayData.indices.last {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        checkLastItemVisibility(geometry: geo, parentFrame: parentFrame)
                    }
                    .onChange(of: viewModel.displayData) { _ in
                        checkLastItemVisibility(geometry: geo, parentFrame: parentFrame)
                    }
            }
        }
    }

    private func scrollToBottom(_ scrollView: ScrollViewProxy) {
        if let lastID = viewModel.displayData.last?.id {
            withAnimation {
                scrollView.scrollTo(lastID, anchor: .bottom)
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
    }
}
