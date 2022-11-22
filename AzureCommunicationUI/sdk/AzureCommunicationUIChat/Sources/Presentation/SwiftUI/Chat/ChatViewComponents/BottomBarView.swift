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
    @StateObject var viewModel: BottomBarViewModel

    @State var textEditorHeight: CGFloat = 20

    var body: some View {
        HStack(spacing: Constants.padding) {
            messageTextField
            sendButton
        }
        .padding([.leading, .trailing, .bottom], Constants.padding)
    }

    var messageTextField: some View {
        TextEditorView(text: $viewModel.message)
    }

    var sendButton: some View {
        IconButton(viewModel: viewModel.sendButtonViewModel)
            .flipsForRightToLeftLayoutDirection(true)
    }
}

// Workaround due to no support for multiline text in SwiftUI Textfield.
// Multiline support was added in iOS 16 but has a new issue of lack of
// support for padding
// This uses an invisible text view to measure the text size and then pass
// that to the texteditor to use for it's height
struct TextEditorView: View {
    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let shadow: CGFloat = 1
        static let minimumHeight: CGFloat = 40

        // Extra padding needed when more that one line displayed
        static let multilineHeightOffset: CGFloat = 20
    }

    @Binding var text: String
    @State var textEditorHeight: CGFloat = Constants.minimumHeight

    var body: some View {

        ZStack(alignment: .leading) {
            Text(text)
                .font(.system(.body))
                .foregroundColor(.clear)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })

            TextEditor(text: $text)
                .font(.system(.body))
                .frame(height: max(Constants.minimumHeight, textEditorHeight))
                .cornerRadius(Constants.cornerRadius)
                .shadow(radius: Constants.shadow)
        }.onPreferenceChange(ViewHeightKey.self) {
            textEditorHeight = $0 + (text.numberOfLines() > 1 ? Constants.multilineHeightOffset : 0)
        }

    }

}

extension String {
    func numberOfLines() -> Int {
        return self.numberOfOccurrencesOf(string: "\n") + 1
    }

    func numberOfOccurrencesOf(string: String) -> Int {
        return self.components(separatedBy: string).count - 1
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
