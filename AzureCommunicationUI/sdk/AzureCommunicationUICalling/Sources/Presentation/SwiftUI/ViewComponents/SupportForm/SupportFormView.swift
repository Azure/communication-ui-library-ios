//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct SupportFormView: View {
    @Binding var showingForm: Bool
    @ObservedObject var viewModel: SupportFormViewModel

    init(showingForm: Binding<Bool>, viewModel: SupportFormViewModel) {
        self._showingForm = showingForm
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("We'll automatically attach logs.")) {
                    TextEditor(text: $viewModel.messageText)
                        .frame(height: 150)
                        .foregroundColor(viewModel.messageText == "Please describe your issue..." ? .gray : .primary)
                        .onTapGesture {
                            if viewModel.messageText == "Please describe your issue..." {
                                viewModel.messageText = ""
                            }
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
                    viewModel.sendReport()
                    showingForm = false
                }
            )
        }
    }
}
