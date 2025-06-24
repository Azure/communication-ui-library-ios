//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import SwiftUI
import FluentUI

struct CaptionsRttInfoView: View {
    @ObservedObject var viewModel: CaptionsRttInfoViewModel
    var avatarViewManager: AvatarViewManagerProtocol
    @AccessibilityFocusState private var isListFocused: Bool
    @State private var focusedId: String?
    @State private var isUserAtBottom = true

    var body: some View {
        GeometryReader { geometry in
            if viewModel.isLoading {
                loadingView
            } else {
                ScrollViewReader { proxy in
                    List {
                        // Render only the first .rttInfo item if it exists
                      if let rttInfo = viewModel.displayData.first(where: { $0.captionsRttType == .rttInfo }) {
                            rttInfoCell()
                                .id("rttInfoCell") // Stable ID to avoid view reuse issues
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .background(Color.clear)
                        }
                        // Render all other items
                        ForEach(viewModel.displayData.filter { $0.captionsRttType != .rttInfo }) { item in
                            renderRow(for: item, in: geometry)
                                .id(item.id)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .background(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .padding(.zero)
                    .background(Color(StyleProvider.color.drawerColor))
                    .coordinateSpace(name: "scroll")
                    .onChange(of: viewModel.displayData) { newData in
                        // Always scroll to the last item
                        print("Updated displayData:")
                        newData.forEach { print($0) }

                        if isUserAtBottom {
                            scrollToBottom(proxy)
                        }
                        if isListFocused,
                           let finalItem = viewModel.displayData.last(where: { $0.isFinal }) {
                            focusedId = finalItem.id
                        }
                    }
                    .accessibilityFocused($isListFocused)
                    .background(Color(StyleProvider.color.drawerColor))
                }
            }
        }
    }

    @ViewBuilder
    private func renderRow(for item: CaptionsRttRecord, in geometry: GeometryProxy) -> some View {
        let isLastItem = item.id == viewModel.displayData.last?.id
        if item.captionsRttType == .rttInfo {
            rttInfoCell()
                .id("rttInfoCell")
        } else {
            CaptionsRttInfoCellView(
                displayData: item,
                avatarViewManager: avatarViewManager,
                localizationProvider: viewModel.localizationProvider,
                isListFocused: $isListFocused
            )
            .id(item.id)
            .background(
                isLastItem ? Color.clear
                    .onAppear {
                        isUserAtBottom = true
                    }
                    .onDisappear {
                        isUserAtBottom = false
                    }
                    : nil
            )
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
            warningMessage
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.top, .trailing, .bottom], 10)
        }
        .background(Color(StyleProvider.color.surface))
        .cornerRadius(8)
        .padding(.horizontal, 10)
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let lastId = viewModel.displayData.last?.id
        else {
            return
        }

        DispatchQueue.main.async {
            withAnimation {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
            isUserAtBottom = true
        }
    }

    private var warningMessage: some View {
        Group {
            Text(viewModel.rttInfoMessage)
            + Text(" ")
            + Text(viewModel.localizationProvider.getLocalizedString(.rttLinkLearnMore))
                .foregroundColor(Color(StyleProvider.color.primaryColor))
        }.accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isLink)
            .onTapGesture {
                if let url = URL(string: StringConstants.rttLearnMoreLink) {
                    UIApplication.shared.open(url)
                }
            }
    }
}
