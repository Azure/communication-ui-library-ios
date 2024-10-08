//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct InfoHeaderView: View {
    @ObservedObject var viewModel: InfoHeaderViewModel
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    @State var participantsListButtonSourceView = UIView()
    @State var participantMenuSourceView = UIView()
    @AccessibilityFocusState var focusedOnParticipantList: Bool
    let avatarViewManager: AvatarViewManagerProtocol

    private enum Constants {
        static let shapeCornerRadius: CGFloat = 5
        static let infoLabelHorizontalPadding: CGFloat = 16.0
        static let hStackHorizontalPadding: CGFloat = 20.0
        static let hStackBottomPadding: CGFloat = 10.0
        static let hSpace: CGFloat = 4
        static let foregroundColor: Color = .white

        // MARK: Font Minimum Scale Factor
        // Under accessibility mode, the largest size is 35
        // so the scale factor would be 9/35 or 0.2
        static let accessibilityFontScale: CGFloat = 0.2
        // UI guideline suggested min font size should be 9.
        // Since Fonts.caption1 has font size of 12,
        // so min scale factor should be 9/12 or 0.75 as default.
        static let defaultFontScale: CGFloat = 0.75
    }

    var body: some View {
        ZStack(
            alignment: .leading
        ) {
            if viewModel.isInfoHeaderDisplayed {
                infoHeader
            } else {
                EmptyView()
            }
        }
        .onAppear(perform: {
            viewModel.isPad = UIDevice.current.userInterfaceIdiom == .pad
        })
        /*
        .modifier(PopupModalView(isPresented:
                                    viewModel.isParticipantsListDisplayed || viewModel.isParticipantMenuDisplayed) {
            if viewModel.isParticipantsListDisplayed {
                participantsListView
                    .accessibilityElement(children: .contain)
                    .accessibilityAddTraits(.isModal)
            }
            if viewModel.isParticipantMenuDisplayed {
                participantMenuView
                    .accessibilityElement(children: .contain)
                    .accessibilityAddTraits(.isModal)
            }
        }) */
        .accessibilityElement(children: .contain)
    }

    var infoHeader: some View {
        HStack {
            // correct dismissButtonAccessibilityID
            if viewModel.enableMultitasking {
                IconButton(viewModel: viewModel.dismissButtonViewModel)
                    .flipsForRightToLeftLayoutDirection(true)
                    .accessibilityIdentifier(AccessibilityIdentifier.dismissButtonAccessibilityID.rawValue)
            }
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .alignmentGuide(.leading) { d in d[.leading] }
                    .foregroundColor(Constants.foregroundColor)
                    .lineLimit(1)
                    .font(Fonts.caption1.font)
                    .accessibilityLabel(Text(viewModel.accessibilityLabelTitle))
                    .accessibilitySortPriority(1)
                    .scaledToFit()
                    .minimumScaleFactor(sizeCategory.isAccessibilityCategory ?
                                        Constants.accessibilityFontScale :
                                            Constants.defaultFontScale)
                /* <TIMER_TITLE_FEATURE> */
                if !viewModel.subtitle!.isEmpty {
                    Text(viewModel.subtitle!.trimmingCharacters(in: .whitespacesAndNewlines))
                        .alignmentGuide(.leading) { d in d[.leading] }
                        .foregroundColor(Constants.foregroundColor)
                        .lineLimit(1)
                        .font(Fonts.caption1.font)
                        .accessibilityLabel(Text(viewModel.accessibilityLabelSubtitle))
                        .accessibilitySortPriority(2)
                        .scaledToFit()
                        .minimumScaleFactor(sizeCategory.isAccessibilityCategory ?
                                            Constants.accessibilityFontScale :
                                                Constants.defaultFontScale)
                }
                /* </TIMER_TITLE_FEATURE> */
            }
            Spacer()
            participantListButton
        }
        .padding(EdgeInsets(top: 0,
                            leading: Constants.hStackHorizontalPadding / 2.0,
                            bottom: 0,
                            trailing: 0))
        .background(Color(StyleProvider.color.surfaceDarkColor))
        .clipShape(RoundedRectangle(cornerRadius: Constants.shapeCornerRadius))
        .padding(.bottom, Constants.hStackBottomPadding)
        .accessibilityElement(children: .contain)
    }

    var participantListButton: some View {
        IconButton(viewModel: viewModel.participantListButtonViewModel)
            .background(SourceViewSpace(sourceView: participantsListButtonSourceView))
            .accessibilityFocused($focusedOnParticipantList, equals: true)
    }
}
