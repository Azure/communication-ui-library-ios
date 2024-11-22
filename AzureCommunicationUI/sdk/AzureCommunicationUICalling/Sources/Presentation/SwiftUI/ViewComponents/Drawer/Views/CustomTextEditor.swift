//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import SwiftUI

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    var onCommit: (() -> Void)?
    var onChange: ((String) -> Void)?
    @State private var hasGainedFocus = false // Tracks if focus has been gained

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.onChange?(textView.text)
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.hasGainedFocus = true // Mark as focused
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                parent.onCommit?()
                return false
            }
            return true
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isScrollEnabled = false
        textView.returnKeyType = .send
        textView.backgroundColor = StyleProvider.color.drawerColor
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        // Manage first responder behavior
        if hasGainedFocus && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !hasGainedFocus && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }
}
