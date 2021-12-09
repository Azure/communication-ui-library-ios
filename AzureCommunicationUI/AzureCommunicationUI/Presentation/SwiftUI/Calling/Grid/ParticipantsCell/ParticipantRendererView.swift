//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine

struct ParticipantRendererView: View {
    let rendererView: UIView
    @Binding var isSpeaking: Bool
    @Binding var displayName: String?
    let borderColor = Color(Style.color.primaryColor)

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                VideoRendererView(rendererView: rendererView)
                Text(displayName ?? "")
                    .font(Fonts.subhead.font)
                    .foregroundColor(Color(Style.color.onBackground))
            }
        }.overlay(
            isSpeaking ? RoundedRectangle(cornerRadius: 4).strokeBorder(borderColor, lineWidth: 4) : nil
        )
    }

}
