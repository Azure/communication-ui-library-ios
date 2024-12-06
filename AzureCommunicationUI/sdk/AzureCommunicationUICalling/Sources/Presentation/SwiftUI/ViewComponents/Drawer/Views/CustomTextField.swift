//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import SwiftUI

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    var onCommit: (() -> Void)?
    var onChange: ((String) -> Void)?

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField

        init(_ parent: CustomTextField) {
            self.parent = parent
        }

        // Called when the text changes
        func textFieldDidChangeSelection(_ textField: UITextField) {
            guard let newText = textField.text else {
                return
            }
            parent.text = newText
            parent.onChange?(newText)
        }

        // Called when the return key is pressed
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onCommit?()
            // Do NOT resign first responder to keep the keyboard open
            DispatchQueue.main.async {
                textField.becomeFirstResponder()
            }
            return false // Returning false to prevent default behavior
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = StyleProvider.color.drawerColor
        textField.returnKeyType = .send
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
}
