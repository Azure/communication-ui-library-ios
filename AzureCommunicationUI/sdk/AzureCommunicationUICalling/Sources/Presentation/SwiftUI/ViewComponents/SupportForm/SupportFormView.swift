//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct SupportFormView: View {
    @Binding var showingForm: Bool
    @State private var messageText: String = "Please describe your issue..."
    @State private var includeScreenshot: Bool = true
    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("We'll automatically attach logs.")) {
                    TextEditor(text: $messageText)
                        .frame(height: 150)
                        .foregroundColor(messageText == "Please describe your issue..." ? .gray : .primary)
                        .onTapGesture {
                            if messageText == "Please describe your issue..." {
                                messageText = ""
                            }
                        }
                }
                Section {
                    Toggle(isOn: $includeScreenshot) {
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
                    // Handle send action
                    showingForm = false
                }
            )
        }
    }
}
