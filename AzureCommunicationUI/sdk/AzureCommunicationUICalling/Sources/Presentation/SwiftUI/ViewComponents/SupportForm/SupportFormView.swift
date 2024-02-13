//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

struct SupportFormView: View {
    @ObservedObject var viewModel: SupportFormViewModel
    init(viewModel: SupportFormViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        VStack {
            HStack {
                Button(viewModel.cancelButtonText) {
                    viewModel.hideForm()
                }
                .font(Fonts.button2.font)
                .foregroundColor(Color(StyleProvider.color.onBackground))
                Spacer()
                Text(viewModel.reportAProblemText)
                    .font(Fonts.subhead.font)
                Spacer()
                Button(viewModel.sendFeedbackText) {
                    viewModel.sendReport()
                }
                .disabled(viewModel.blockSubmission)
                .font(Fonts.button2.font)
                .foregroundColor(Color(StyleProvider.color.onBackground))
            }.padding(.all, 16)
            ZStack(alignment: .topLeading) {
                if viewModel.messageText.isEmpty {
                    Text(viewModel.describeYourIssueHintText)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                        .padding(.leading, 4)
                }
                TextEditor(text: $viewModel.messageText)
                    .frame(height: 150)
                    .opacity(viewModel.messageText.isEmpty ? 0.25 : 1)
                    .cornerRadius(16.0)
                    .border(Color(StyleProvider.color.onSurface).opacity(0.25))
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            HStack {
                Text(viewModel.logsAttachNotice)
                Link(viewModel.privacyPolicyText, destination: URL(string: StringConstants.privacyPolicyLink)!)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.bottom, 64)
        }
        .background(Color(StyleProvider.color.backgroundColor))
        .cornerRadius( 16.0)
        .shadow(radius: 4.0)
        .padding(.leading, 8)
        .padding(.trailing, 8)
    }
}
