//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct LeaveCallConfirmationView: View {
    @ObservedObject var viewModel: LeaveCallConfirmationViewModel

    init(viewModel: LeaveCallConfirmationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: LeaveCallConfirmationViewConstants.vStackSpacing) {
            Text("Leave call?")
                .font(.system(size: LeaveCallConfirmationViewConstants.titleFontSize, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, LeaveCallConfirmationViewConstants.titlePaddingTop)

            ForEach(viewModel.options) { option in
                HStack {
                    Icon(name: option.icon, size: LeaveCallConfirmationViewConstants.iconSize)
                        .foregroundColor(.primary)
                    Text(option.title)
                        .foregroundColor(.primary)
                        .padding(.leading, LeaveCallConfirmationViewConstants.textPaddingLeading)
                        .font(.system(size: LeaveCallConfirmationViewConstants.textFontSize))
                    Spacer()
                }
                .padding(.vertical, LeaveCallConfirmationViewConstants.optionPaddingVertical)
                .padding(.horizontal, LeaveCallConfirmationViewConstants.optionPaddingHorizontal)
                .frame(maxWidth: .infinity)
                .background(option.title == "End Call" ? Color.red : Color.clear)
                .cornerRadius(LeaveCallConfirmationViewConstants.optionCornerRadius)
                .onTapGesture {
                    option.action()
                }
            }
        }
    }
}

class LeaveCallConfirmationViewConstants {
    static let vStackSpacing: CGFloat = 20
    static let titleFontSize: CGFloat = 20
    static let titlePaddingTop: CGFloat = 20
    static let iconSize: CGFloat = 24
    static let textPaddingLeading: CGFloat = 8
    static let textFontSize: CGFloat = 18
    static let optionPaddingVertical: CGFloat = 12
    static let optionPaddingHorizontal: CGFloat = 16
    static let optionCornerRadius: CGFloat = 10
}
