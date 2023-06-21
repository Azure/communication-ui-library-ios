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
    let avatarViewManager: AvatarViewManagerProtocol

    private enum Constants {
        static let shapeCornerRadius: CGFloat = 5
        static let infoLabelHorizontalPadding: CGFloat = 16.0
        static let hStackHorizontalPadding: CGFloat = 20.0
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
        ZStack {
            if viewModel.isInfoHeaderDisplayed {
                infoHeader
            } else {
                EmptyView()
            }
        }
        .onAppear(perform: {
            viewModel.isPad = UIDevice.current.userInterfaceIdiom == .pad
        })
        .modifier(PopupModalView(isPresented: viewModel.isParticipantsListDisplayed) {
            participantsListView
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isModal)
        })
    }

    var infoHeader: some View {
        HStack {
            // correct dismissButtonAccessibilityID
            IconButton(viewModel: viewModel.dismissButtonViewModel)
                .flipsForRightToLeftLayoutDirection(true)
                .accessibilityIdentifier(AccessibilityIdentifier.dismissButtonAccessibilityID.rawValue)

            Text(viewModel.infoLabel)
                .padding(EdgeInsets(top: Constants.infoLabelHorizontalPadding,
                                    leading: 0,
                                    bottom: Constants.infoLabelHorizontalPadding,
                                    trailing: 0))
                .foregroundColor(Constants.foregroundColor)
                .lineLimit(1)
                .font(Fonts.caption1.font)
                .accessibilityLabel(Text(viewModel.accessibilityLabel))
                .accessibilitySortPriority(1)
                .scaledToFill()
                .minimumScaleFactor(sizeCategory.isAccessibilityCategory ?
                                    Constants.accessibilityFontScale :
                                        Constants.defaultFontScale)
            Spacer()
            participantListButton
        }
        .padding(EdgeInsets(top: 0,
                            leading: Constants.hStackHorizontalPadding / 2.0,
                            bottom: 0,
                            trailing: Constants.hStackHorizontalPadding / 2.0))
        .background(Color(StyleProvider.color.surfaceDarkColor))
        .clipShape(RoundedRectangle(cornerRadius: Constants.shapeCornerRadius))
    }

    var participantListButton: some View {
        IconButton(viewModel: viewModel.participantListButtonViewModel)
            .background(SourceViewSpace(sourceView: participantsListButtonSourceView))
    }

    var participantsListView: some View {
        return Group {
            if let avatarManager = avatarViewManager as? AvatarViewManager {
                CompositeParticipantsList(isPresented: $viewModel.isParticipantsListDisplayed,
                                          isInfoHeaderDisplayed: $viewModel.isInfoHeaderDisplayed,
                                          isVoiceOverEnabled: $viewModel.isVoiceOverEnabled,
                                          viewModel: viewModel.participantsListViewModel,
                                          avatarViewManager: avatarManager,
                                          sourceView: participantsListButtonSourceView)
                .modifier(LockPhoneOrientation())
            } else {
                EmptyView()
            }
        }
    }
}
