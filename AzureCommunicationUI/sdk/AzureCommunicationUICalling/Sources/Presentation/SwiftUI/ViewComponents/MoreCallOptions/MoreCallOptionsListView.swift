//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct MoreCallOptionsListView: View {
    @ObservedObject var viewModel: MoreCallOptionsListViewModel

    init(viewModel: MoreCallOptionsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: MoreCallOptionsListViewConstants.vStackSpacing) {
            Text("Leave call?")
                .font(.system(size: MoreCallOptionsListViewConstants.titleFontSize))
                .foregroundColor(.primary)
                .padding(.top, MoreCallOptionsListViewConstants.titlePaddingTop)

            ForEach(viewModel.items) { option in
                HStack {
                    Icon(name: option.icon, size: MoreCallOptionsListViewConstants.iconSize)
                        .foregroundColor(.primary)
                    Text(option.title)
                        .foregroundColor(.primary)
                        .padding(.leading, MoreCallOptionsListViewConstants.textPaddingLeading)
                        .font(.system(size: MoreCallOptionsListViewConstants.textFontSize))
                    Spacer()
                }
                .padding(.horizontal, MoreCallOptionsListViewConstants.optionPaddingHorizontal)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    option.action()
                }
            }
        }.padding(.bottom, MoreCallOptionsListViewConstants.bottomPadding)
    }
}

class MoreCallOptionsListViewConstants {
    static let vStackSpacing: CGFloat = 16
    static let titleFontSize: CGFloat = 20
    static let titlePaddingTop: CGFloat = 20
    static let iconSize: CGFloat = 24
    static let textPaddingLeading: CGFloat = 8
    static let textFontSize: CGFloat = 18
    static let optionPaddingVertical: CGFloat = 8
    static let optionPaddingHorizontal: CGFloat = 16
    static let bottomPadding: CGFloat = 24
}
