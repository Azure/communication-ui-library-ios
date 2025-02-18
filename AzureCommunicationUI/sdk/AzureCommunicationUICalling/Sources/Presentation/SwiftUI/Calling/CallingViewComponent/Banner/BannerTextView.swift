//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct BannerTextView: View {
    @ObservedObject var viewModel: BannerTextViewModel

    var body: some View {
        Group {
            Text(viewModel.title).bold()
            + Text(" ")
            + Text(viewModel.body)
            + Text(" ")
            + Text(viewModel.linkDisplay).underline()
        }
        .font(.system(size: adjustedFontSize(), weight: .regular)) // Apply computed font size
        .lineLimit(nil)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(viewModel.accessibilityLabel))
        .accessibilityAddTraits(.isLink)
        .onTapGesture {
            if let url = URL(string: viewModel.link) {
                UIApplication.shared.open(url)
            }
        }
    }

    /// Adjusts the font size based on Dynamic Type but keeps it within limits.
    private func adjustedFontSize() -> CGFloat {
        let baseSize: CGFloat = 14  // Default footnote size
        let maxSize: CGFloat = 26   // Maximum size allowed
        let minSize: CGFloat = 12   // Minimum size allowed

        let scaledSize = UIFontMetrics.default.scaledValue(for: baseSize)
        return min(max(scaledSize, minSize), maxSize) // Clamp within bounds
    }
}
