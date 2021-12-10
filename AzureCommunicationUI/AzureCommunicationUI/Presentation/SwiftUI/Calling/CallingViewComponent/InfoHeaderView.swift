//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct InfoHeaderView: View {
    @ObservedObject var viewModel: InfoHeaderViewModel

    let participantsListButtonSourceView = UIView()
    let foregroundColor: Color = .white
    let shapeCornerRadius: CGFloat = 5
    let infoLabelHorizontalPadding: CGFloat = 16.0
    let hStackHorizontalPadding: CGFloat = 20.0

    var body: some View {
        if viewModel.isInfoHeaderDisplayed {
            HStack {
                Text(viewModel.infoLabel)
                    .padding(EdgeInsets(top: infoLabelHorizontalPadding,
                                        leading: 0,
                                        bottom: infoLabelHorizontalPadding,
                                        trailing: 0))
                    .foregroundColor(foregroundColor)
                    .font(Fonts.caption1.font)
                Spacer()
                participantListButton
            }
            .padding(EdgeInsets(top: 0,
                                leading: hStackHorizontalPadding,
                                bottom: 0,
                                trailing: hStackHorizontalPadding / 2.0))
            .background(Color(StyleProvider.color.surfaceDarkColor))
            .clipShape(RoundedRectangle(cornerRadius: shapeCornerRadius))
            .modifier(PopupModalView(isPresented: viewModel.isParticipantsListDisplayed) {
                participantsListView
            })
        } else {
            EmptyView()
        }
    }

    var participantListButton: some View {
        IconButton(viewModel: viewModel.participantListButtonViewModel)
            .background(SourceViewSpace(sourceView: participantsListButtonSourceView))
    }

    var participantsListView: some View {
        CompositeParticipantsList(isPresented: $viewModel.isParticipantsListDisplayed,
                                  isInfoHeaderDisplayed: $viewModel.isInfoHeaderDisplayed,
                                  viewModel: viewModel.participantsListViewModel,
                                  sourceView: participantsListButtonSourceView)
            .modifier(LockPhoneOrientation())
    }
}
