//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

@available(iOS 15.0, *)
struct BottomBarView: View {
    private enum Constants {
        static let minimumHeight: CGFloat = 50
        static let focusDelay: CGFloat = 1.0
        static let padding: CGFloat = 12
    }

    @FocusState private var hasFocus: Bool

    @StateObject var viewModel: BottomBarViewModel

    var body: some View {
        HStack(spacing: Constants.padding) {
            legacyMessageTextField
            sendButton
        }
        .padding([.leading, .trailing], Constants.padding)
//        .onTapGesture {
//            hasFocus = false
//        }
    }

    // Wrap iOS 16 .vertical
    // Can't set minimumHeight
    var messageTextField: some View {
        Group {
            if #available(iOS 16.0, *) {
                TextField("Message...",
                          text: $viewModel.message,
                          axis: .vertical)
                .submitLabel(.return)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($hasFocus)
                .onChange(of: viewModel.message) { newValue in
                    guard !newValue.isEmpty else {
                        return
                    }
                    viewModel.sendTypingIndicator()
                }
            }
        }
    }

    var legacyMessageTextField: some View {
        LegacyTextFieldView(text: $viewModel.message)
            .frame(height: 40)
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 1))
            )
        // color: Light/Dividers/On primary
    }

    var sendButton: some View {
        IconButton(viewModel: viewModel.sendButtonViewModel)
            .flipsForRightToLeftLayoutDirection(true)
    }
}

struct LegacyTextFieldView: UIViewRepresentable {
    @Binding var text: String

    typealias UIViewType = UITextView

    func makeUIView(context: Context) -> UIViewType {
        let textView = UITextView()

//        textView.layer.cornerRadius = 5
//         textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
//         textView.layer.borderWidth = 0.5
//         textView.clipsToBounds = true

//        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
//        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true

        textView.font = UIFont.preferredFont(forTextStyle: .body)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
         uiView.text = text
//         uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>

        init(_ text: Binding<String>) {
            self.text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }
    }
}
