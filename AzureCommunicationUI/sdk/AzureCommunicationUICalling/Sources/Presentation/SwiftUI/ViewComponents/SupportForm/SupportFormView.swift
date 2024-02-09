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
                                Text("We'll automatically attach logs.")
                                Spacer()
                            Link("Privacy Policy", destination: URL(string: "https://www.microsoft.com")!)
                        
                                .foregroundColor(.blue)
                            }) {
                    ZStack(alignment: .topLeading) {
                        if viewModel.messageText.isEmpty {
                            Text("Please describe your issue...")
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
                        Text("Attach screenshot")
                    }
                }
            }
            .navigationBarTitle("Report a Problem", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingForm = false
                },
                trailing: Button("Send") {
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
