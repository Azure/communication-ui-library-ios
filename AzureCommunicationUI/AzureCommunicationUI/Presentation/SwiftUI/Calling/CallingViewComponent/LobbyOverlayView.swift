//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine

struct LobbyOverlayView: View {
    let viewModel: LobbyOverlayViewModel

    private let layoutSpacing: CGFloat = 24
    private let iconImageSize: CGFloat = 24
    private let horizontalPaddingSize: CGFloat = 16

    var body: some View {
        Color(StyleProvider.color.overlay)
            .overlay(
                VStack(spacing: layoutSpacing) {
                    Icon(name: .clock, size: iconImageSize)
                    Text(viewModel.title)
                        .font(Fonts.headline.font)
                    Text(viewModel.subtitle)
                        .font(Fonts.subhead.font)
                        .multilineTextAlignment(.center)
                }.padding(.horizontal, horizontalPaddingSize)
            )
    }
}
