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
                Section(footer: Text("We'll automatically attach logs.")) {
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
                    // We are going to wait ~ 16ms, 1 frame @ 60fps, before dispatching this
                    // The reason being that the screenshot shouldn't show the form
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1 / 60) {
                        viewModel.sendReport()
                    }
                }
            )
        }
    }
}
