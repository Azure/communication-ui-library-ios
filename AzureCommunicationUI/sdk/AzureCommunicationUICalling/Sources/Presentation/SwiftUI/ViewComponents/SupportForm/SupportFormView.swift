//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct SupportFormView: View {
    @ObservedObject var viewModel: SupportFormViewModel
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
                .opacity(viewModel.blockSubmission ? 0.5 : 1.0)
                .font(Fonts.button2.font)
                .foregroundColor(Color(StyleProvider.color.onBackground))
            }.padding(.all, 16)
            ZStack(alignment: .topLeading) {
                if viewModel.messageText.isEmpty {
                    Text(viewModel.describeYourIssueHintText)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.leading, 8)
                        .accessibilityHidden(true)
                }
                TextEditor(text: $viewModel.messageText)
                    .frame(height: 150)
                    .opacity(viewModel.messageText.isEmpty ? 0.25 : 1)
                    .cornerRadius(16.0)
                    .border(Color(StyleProvider.color.onSurface).opacity(0.25))
                    .accessibilityHint(viewModel.describeYourIssueHintText)
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            HStack {
                Text(viewModel.logsAttachNotice)
                Link(viewModel.privacyPolicyText, destination: URL(string: StringConstants.privacyPolicyLink)!)
                .foregroundColor(Color(StyleProvider.color.primaryColor))
                Spacer()
#if DEBUG
                // Hidden button for injecting text
                Button(" ") {
                    viewModel.messageText = "Sample Message"
                }
                .accessibilityIdentifier(AccessibilityIdentifier.supportFormTextFieldAccessibilityId.rawValue)
#endif
            }
            .padding(.leading, 16)
            .padding(.bottom, 72)
        }
        .background(Color(StyleProvider.color.backgroundColor))
        .cornerRadius( 16.0)
        .shadow(radius: 4.0)
        .padding(.leading, 8)
        .padding(.trailing, 8)
        .transition(.slide)
    }
}

class SupportFormViewController: UIViewController {
    private var hostingController: UIHostingController<SupportFormView>?
    private var viewModel: SupportFormViewModel

    init(viewModel: SupportFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupHostingController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHostingController() {
        // Initialize your SwiftUI view with the ViewModel
        let supportFormView = SupportFormView(viewModel: viewModel)

        // Create a UIHostingController with your SwiftUI view
        let hostingController = UIHostingController(rootView: supportFormView)

        // Add as a child of the current UIViewController
        addChild(hostingController)
        view.addSubview(hostingController.view)

        // Setup constraints to match the parent view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Complete the addition of the child view controller
        hostingController.didMove(toParent: self)

        self.hostingController = hostingController
    }
}
