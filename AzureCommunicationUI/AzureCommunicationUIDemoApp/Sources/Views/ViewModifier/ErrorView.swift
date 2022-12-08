//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ErrorView: ViewModifier {
    @Binding var isPresented: Bool

    var errorMessage: String
    var onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content.alert(isPresented: $isPresented) {
                Alert(title: Text("Error"),
                      message: Text(errorMessage),
                      dismissButton: .default(Text("Dismiss"), action: onDismiss))
        }
    }
}
