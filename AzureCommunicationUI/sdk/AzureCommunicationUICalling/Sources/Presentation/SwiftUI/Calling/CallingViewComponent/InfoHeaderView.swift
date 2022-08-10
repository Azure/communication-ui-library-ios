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
    let avatarViewManager: AvatarViewManager
    let foregroundColor: Color = .white
    let shapeCornerRadius: CGFloat = 5
    let infoLabelHorizontalPadding: CGFloat = 16.0
    let hStackHorizontalPadding: CGFloat = 20.0

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
            Text(viewModel.infoLabel)
                .padding(EdgeInsets(top: infoLabelHorizontalPadding,
                                    leading: 0,
                                    bottom: infoLabelHorizontalPadding,
                                    trailing: 0))
                .foregroundColor(foregroundColor)
                .lineLimit(1)
                .font(Fonts.caption1.font)
                .accessibilityLabel(Text(viewModel.accessibilityLabel))
                .accessibilitySortPriority(1)
                .minimumScaleFactor(sizeCategory.isAccessibilityCategory ? 0.1 : 0.75)
            Spacer()
            participantListButton
        }
        .padding(EdgeInsets(top: 0,
                            leading: hStackHorizontalPadding,
                            bottom: 0,
                            trailing: hStackHorizontalPadding / 2.0))
        .background(Color(StyleProvider.color.surfaceDarkColor))
        .clipShape(RoundedRectangle(cornerRadius: shapeCornerRadius))
    }

    var participantListButton: some View {
        IconButton(viewModel: viewModel.participantListButtonViewModel)
            .background(SourceViewSpace(sourceView: participantsListButtonSourceView))
    }

    var participantsListView: some View {
        CompositeParticipantsList(isPresented: $viewModel.isParticipantsListDisplayed,
                                  isInfoHeaderDisplayed: $viewModel.isInfoHeaderDisplayed,
                                  isVoiceOverEnabled: $viewModel.isVoiceOverEnabled,
                                  viewModel: viewModel.participantsListViewModel,
                                  avatarViewManager: avatarViewManager,
                                  sourceView: participantsListButtonSourceView)
            .modifier(LockPhoneOrientation())
    }
}
