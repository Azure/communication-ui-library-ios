//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ControlBarView: View {
    @ObservedObject var viewModel: ControlBarViewModel

    let audioDeviceButtonSourceView = UIView()

    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

    var body: some View {
        Group {
            if screenSizeClass != .iphoneLandscapeScreenSize {
                HStack {
                    Spacer()
                    videoButton
                    micButton
                    audioDeviceButton
                    hangUpButton
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()
                    hangUpButton
                    audioDeviceButton
                    micButton
                    videoButton
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(StyleProvider.color.backgroundColor))
        .modifier(PopupModalView(isPresented: viewModel.isAudioDeviceSelectionDisplayed) {
            audioDeviceSelectionListView
        })
    }

    var videoButton: some View {
        IconButton(viewModel: viewModel.cameraButtonViewModel)
    }

    var micButton: some View {
        IconButton(viewModel: viewModel.micButtonViewModel)
            .disabled(viewModel.isMicDisabled())
    }

    var audioDeviceButton: some View {
        IconButton(viewModel: viewModel.audioDeviceButtonViewModel)
            .background(SourceViewSpace(sourceView: audioDeviceButtonSourceView))
    }

    var hangUpButton: some View {
        IconButton(viewModel: viewModel.hangUpButtonViewModel)
    }

    var audioDeviceSelectionListView: some View {
        CompositePopupMenu(isPresented: $viewModel.isAudioDeviceSelectionDisplayed,
                           viewModel: viewModel.audioDeviceListViewModel,
                           sourceView: audioDeviceButtonSourceView)
            .modifier(LockPhoneOrientation())
    }
}
