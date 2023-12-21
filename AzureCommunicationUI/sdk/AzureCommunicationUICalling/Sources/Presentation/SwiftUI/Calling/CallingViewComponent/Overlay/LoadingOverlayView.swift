//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine

struct LoadingOverlayView: View {
    private let iconImageSize: CGFloat = 24
    private let verticalIconPaddingSize: CGFloat = 14
    private let verticalButtonPaddingSize: CGFloat = 32
    private let horizontalPaddingSize: CGFloat = 16

    @ObservedObject var viewModel: LoadingOverlayViewModel

    var body: some View {
        Color(StyleProvider.color.surface)
            .overlay(
                ZStack(alignment: .bottom) {
                    VStack(spacing: 10) {
                        Spacer()
                        Group {
                            ActivityIndicator(size: .medium)
                                .isAnimating(true)
                                .color(Colors.Palette.communicationBlue.color)
                            Text(viewModel.title)
                                .font(Fonts.title2.font)
                        }
                        .padding(.horizontal, horizontalPaddingSize)
                        .accessibilityElement(children: .combine)
                        .accessibility(addTraits: .isHeader)
                        if let actionButtonViewModel = viewModel.actionButtonViewModel {
                                PrimaryButton(viewModel: actionButtonViewModel)
                                    .fixedSize()
                                    .padding(.top, verticalButtonPaddingSize)
                        }
                        Spacer()
                    }
                }
            )
            .onAppear {
                viewModel.handleOffline()
                viewModel.handleMicAvailabilityCheck()
            }
    }
}
