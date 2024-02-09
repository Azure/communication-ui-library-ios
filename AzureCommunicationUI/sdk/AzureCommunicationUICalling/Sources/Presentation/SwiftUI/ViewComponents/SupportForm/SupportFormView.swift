//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct SupportFormView: View {
    @Binding var showingForm: Bool
    @ObservedObject var viewModel: SupportFormViewModel

    init(isPresented: Binding<Bool>, viewModel: SupportFormViewModel) {
        self._showingForm = isPresented
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            Form {
                Section(footer:
                            HStack {
                    Text(viewModel.logsAttachNotice)
                                Spacer()
                    Link(viewModel.privacyPolicyText, destination: URL(string: StringConstants.privacyPolicyLink)!)
                                .foregroundColor(.blue)
                            }) {
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
                }
                Section {
                    Toggle(isOn: $viewModel.includeScreenshot) {
                        Text(viewModel.attachScreenshot)
                    }
                }
            }
            .navigationBarTitle(viewModel.reportIssueTitle, displayMode: .inline)
            .navigationBarItems(
                leading: Button(viewModel.cancelButtonText) {
                    showingForm = false
                },
                trailing: Button(viewModel.sendFeedbackText) {
                    showingForm = false
                    viewModel.prepareToSend()
                }
            )
        }.onDisappear {
            if viewModel.submitOnDismiss {
                DispatchQueue.main.async {
                    viewModel.sendReport()
                }
            }
        }
    }
}
