//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct BottomToastDiagnosticView: View {
    @ObservedObject var viewModel: BottomToastDiagnosticViewModel

    private let cornerRadius: CGFloat = 6

    var body: some View {
        HStack(alignment: .center) {
            if let icon = viewModel.icon {
                IconProvider().getImage(for: icon)
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color(StyleProvider.color.onSurface))
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
            }
            Text(viewModel.text)
                .font(Fonts.subhead.font)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(StyleProvider.color.onSurface))
                .accessibilitySortPriority(2)
        }
        .frame(height: 36)
        .background(Color(StyleProvider.color.backgroundColor))
        .cornerRadius(cornerRadius)
    }
}
