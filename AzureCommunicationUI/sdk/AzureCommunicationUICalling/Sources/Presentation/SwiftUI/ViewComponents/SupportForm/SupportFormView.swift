//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

struct SupportFormView: View {
    @Binding var showingForm: Bool
    @ObservedObject var viewModel: SupportFormViewModel

    init(isPresented: Binding<Bool>, viewModel: SupportFormViewModel) {
        self._showingForm = isPresented
        self.viewModel = viewModel
    }
    var body: some View {
        VStack {
            HStack {
                Button(viewModel.cancelButtonText) {
                    showingForm = false
                }
                .font(Fonts.button2.font)
                .foregroundColor(Color(StyleProvider.color.onBackground))
                Spacer()
                Text(viewModel.reportAProblemText)
                    .font(Fonts.subhead.font)
                Spacer()
                Button(viewModel.sendFeedbackText) {
                    showingForm = false
                    viewModel.prepareToSend()
                }
                .font(Fonts.button2.font)
                .foregroundColor(Color(StyleProvider.color.onBackground))
            }.padding(16.0)
            ZStack(alignment: .topLeading) {
                if viewModel.messageText.isEmpty {
                    Text(viewModel.describeYourIssueHintText)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                TextEditor(text: $viewModel.messageText)
                    .frame(height: 150)
                    .opacity(viewModel.messageText.isEmpty ? 0.25 : 1)
            }
            .padding()
            .cornerRadius(16.0)
            .border(Color(StyleProvider.color.onSurface).opacity(0.25))
            HStack {
                Text(viewModel.logsAttachNotice)
                Link(viewModel.privacyPolicyText, destination: URL(string: StringConstants.privacyPolicyLink)!)
                    .foregroundColor(.blue)
                Spacer()
            }
            Toggle(isOn: $viewModel.includeScreenshot) {
                Text(viewModel.attachScreenshot)
            }
        }
        .background(Color(StyleProvider.color.backgroundColor))
        .cornerRadius(16.0)
        .shadow(radius: 4.0)
        .padding()
        .onDisappear {
            if viewModel.submitOnDismiss {
                DispatchQueue.main.async {
                    viewModel.sendReport()
                }
            }
        }
    }
}
