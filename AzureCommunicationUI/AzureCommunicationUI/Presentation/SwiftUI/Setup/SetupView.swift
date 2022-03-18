//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import Combine
import FluentUI

struct SetupView: View {
    @ObservedObject var viewModel: SetupViewModel
    let viewManager: VideoViewManager

    let layoutSpacing: CGFloat = 24
    let horizontalPadding: CGFloat = 16
    let startCallButtonHeight: CGFloat = 52
    let errorHorizontalPadding: CGFloat = 8

    var body: some View {
        ZStack {
            VStack(spacing: layoutSpacing) {
                SetupTitleView(backButtonViewModel: viewModel.dismissButtonViewModel)
                VStack(spacing: layoutSpacing) {
                    ZStack(alignment: .bottom) {
                        PreviewAreaView(viewModel: viewModel.previewAreaViewModel,
                                        viewManager: viewManager)
                        SetupControlBarView(viewModel: viewModel.setupControlBarViewModel)
                    }
                    .background(Color(StyleProvider.color.surface))
                    .cornerRadius(4)
                    joinCallView
                        .padding(.bottom)
                }
                .padding(.horizontal, horizontalPadding)
            }
            errorInfoView
        }
        .onAppear {
            viewModel.setupAudioPermissions()
            viewModel.setupCall()
        }
    }

    var joinCallView: some View {
        Group {
            if viewModel.isJoinRequested {
                JoiningCallActivityView(viewModel: viewModel.joiningCallActivityViewModel)
            } else {
                PrimaryButton(viewModel: viewModel.joinCallButtonViewModel)
            }
        }
    }

    var errorInfoView: some View {
        VStack {
            Spacer()
            ErrorInfoView(viewModel: viewModel.errorInfoViewModel)
                .padding(EdgeInsets(top: 0,
                                    leading: errorHorizontalPadding,
                                    bottom: startCallButtonHeight + layoutSpacing,
                                    trailing: errorHorizontalPadding)
                )
        }
    }
}

struct SetupTitleView: View {
    let viewHeight: CGFloat = 44
    let verticalSpacing: CGFloat = 0
    var title: String = ""
    var backButtonViewModel: IconButtonViewModel

    var body: some View {
        VStack(spacing: verticalSpacing) {
            ZStack(alignment: .leading) {
                IconButton(viewModel: backButtonViewModel)
                    .flipsForRightToLeftLayoutDirection(true)
                HStack {
                    Spacer()
                    Text(title)
                        .font(Fonts.headline.font)
                        .foregroundColor(Color(StyleProvider.color.onBackground))
                    Spacer()
                }
            }.frame(height: viewHeight)
            Divider()
        }
    }
}
