//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine

struct LobbyOverlayView: View {
    let title: String = "Waiting for host"
    let subtitle: String = "Someone in the meeting will let you in soon"

    private let layoutSpacing: CGFloat = 24
    private let iconImageSize: CGFloat = 24

    var body: some View {
        Color(StyleProvider.color.overlay)
            .overlay(
                VStack(spacing: layoutSpacing) {
                    Icon(name: .clock, size: iconImageSize)
                    Text(title)
                        .font(Fonts.headline.font)
                    Text(subtitle)
                        .font(Fonts.subhead.font)
                })
    }
}
