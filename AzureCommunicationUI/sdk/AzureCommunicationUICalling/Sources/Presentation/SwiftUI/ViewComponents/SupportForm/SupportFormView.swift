//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct SupportFormView: View {
    @ObservedObject var viewModel: SupportFormViewModel
    @ObservedObject var landscapeKeyboardWatcher: LandscapeAwareKeyboardWatcher
        = LandscapeAwareKeyboardWatcher.shared

    enum Constants {
        static let otherControlsHeightEstimate: CGFloat = 144
        static let smallPad: CGFloat = 8
        static let largePad: CGFloat = 16
        static let disabledOpacity: CGFloat = 0.4
        static let enabledOpacity: CGFloat = 1.0
    }

    let screenHeight: CGFloat = UIScreen.main.bounds.height

    init(viewModel: SupportFormViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            HStack {
                Button(viewModel.cancelButtonText) {
                    viewModel.hideForm()
                }
                .font(Fonts.button2.font)
                .foregroundColor(Color(StyleProvider.color.onBackground))
                Spacer()
                Text(viewModel.reportAProblemText)
                    .font(Fonts.subhead.font)
                Spacer()
                Button(viewModel.sendFeedbackText) {
                    viewModel.sendReport()
                }
                .accessibilityIdentifier(AccessibilityIdentifier.supportFormSubmitAccessibilityId.rawValue)
                .disabled(viewModel.blockSubmission)
                .opacity(viewModel.blockSubmission ? Constants.disabledOpacity : Constants.enabledOpacity)
                .font(Fonts.button2.font)
                .foregroundColor(Color(StyleProvider.color.onBackground))
            }
            ZStack(alignment: .topLeading) {
                if viewModel.messageText.isEmpty {
                    Text(viewModel.describeYourIssueHintText)
                        .foregroundColor(.gray)
                        .padding(.top, Constants.smallPad)
                        .padding(.leading, Constants.smallPad)
                        .accessibilityHidden(true)
                }
                TextEditor(text: $viewModel.messageText)
                    .frame(height: calculatedTextEditorHeight())
                    .opacity(viewModel.messageText.isEmpty ? Constants.disabledOpacity : Constants.enabledOpacity)
                    .border(Color(StyleProvider.color.onSurface).opacity(Constants.disabledOpacity))
                    .accessibilityHint(viewModel.describeYourIssueHintText)
            }
            HStack {
                Text(viewModel.logsAttachNotice)
                    .font(Fonts.caption1.font)
                Link(viewModel.privacyPolicyText, destination: URL(string: StringConstants.privacyPolicyLink)!)
                    .foregroundColor(Color(StyleProvider.color.primaryColor))
                    .font(Fonts.caption2.font)
                Spacer()
#if DEBUG
                // Hidden button for injecting text
                Button(" ") {
                    viewModel.messageText = "Sample Message"
                }
                .accessibilityIdentifier(AccessibilityIdentifier.supportFormTextFieldAccessibilityId.rawValue)
#endif
            }
        }
        .padding()
    }

    func calculatedTextEditorHeight() -> CGFloat {
        let sh = screenHeight
        let kh = landscapeKeyboardWatcher.activeHeight
        let och = Constants.otherControlsHeightEstimate
        let availableHeight = sh - kh - och
        return max(0, min(150, availableHeight))
    }
}
