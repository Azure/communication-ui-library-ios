//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
internal struct CaptionsAndRttLandscapeView<Content: View>: View {
    // MARK: - Properties

    // Bindings
    @Binding var isAutoCommitted: Bool

    // Drawer Configuration
    let title: String?
    let endIcon: CompositeIcon?
    let endIconAction: (() -> Void)?
    let showTextBox: Bool
    let textBoxHint: String?
    let commitAction: ((_ message: String, _ isFinal: Bool?) -> Void)?

    // Content
    let content: Content

    // Internal States
    @State private var text: String = ""
    @State private var keyboardHeight: CGFloat = 0

    // MARK: - Initializer
    init(
        title: String? = nil,
        endIcon: CompositeIcon? = nil,
        endIconAction: (() -> Void)? = nil,
        showTextBox: Bool = false,
        textBoxHint: String? = nil,
        isAutoCommitted: Binding<Bool> = .constant(false),
        commitAction: ((_ message: String, _ isFinal: Bool?) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isAutoCommitted = isAutoCommitted
        self.title = title
        self.endIcon = endIcon
        self.endIconAction = endIconAction
        self.showTextBox = showTextBox
        self.textBoxHint = textBoxHint
        self.commitAction = commitAction
        self.content = content()
    }

    // MARK: - Body
    var body: some View {
        drawerView.onChange(of: isAutoCommitted) { shouldClear in
            if shouldClear {
                clearText()
            }
        }
    }

    // MARK: - Drawer View
    private var drawerView: some View {
        VStack {
            Spacer()
            VStack {
                // Title and Icons
                titleView

                // Content
                content

                // Text Editor (if applicable)
                if showTextBox {
                    textEditor
                        .frame(height: DrawerConstants.textBoxHeight)
                        .padding([.leading, .trailing], 10)
                }

                // Bottom Padding to Push Content Off-Screen
                Spacer().frame(height: DrawerConstants.textBoxPaddingBottom)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .background(Color(StyleProvider.color.drawerColor))
            .clipShape(RoundedCorner(radius: 3, corners: [.topLeft, .bottomLeft]))
            .padding(.leading, 2)
            .shadow(radius: 3)
            .hideKeyboardOnTap() // Dismiss keyboard when tapping outside
        }
    }

    // MARK: - Title View
    private var titleView: some View {
        VStack {
            HStack(spacing: 8) {
                Spacer()
                // End Icon (if any)
                if let icon = endIcon {
                    Icon(name: icon, size: DrawerListConstants.iconSize)
                        .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                        .onTapGesture {
                            endIconAction?()
                        }
                }
            }
            .padding([.leading, .trailing], 10)
            .padding(.top, 15)
        }.overlay(
            Text(title ?? "")
                .font(.headline)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 15),
            alignment: .center
        )
    }

    // MARK: - Text Editor
    private var textEditor: some View {
        CustomTextField(
            text: $text,
            placeholder: textBoxHint ?? "",
            onCommit: {
                commitAction?(text, true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    text = ""
                }
            },
            onChange: { newText in
                commitAction?(newText, false)
            }
        )
        .frame(height: DrawerConstants.textBoxHeight)
        .frame(maxWidth: .infinity)
        .onChange(of: isAutoCommitted) { shouldClear in
            if shouldClear {
                clearText()
            }
        }
    }

    // MARK: - Helper Functions
    /// Clears the text in the text editor and resets auto-commit state.
    private func clearText() {
        DispatchQueue.main.async {
            text = ""
            isAutoCommitted = false
        }
    }
}
