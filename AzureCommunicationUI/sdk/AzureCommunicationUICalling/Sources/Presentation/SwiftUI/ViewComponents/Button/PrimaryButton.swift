//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct PrimaryButton: View {
    @ObservedObject var viewModel: PrimaryButtonViewModel

    var body: some View {
        let action = Action()
        // accessibilityElement(children: .combine) is required because
        // the CompositeButton is represented as a superview with subviews
        CompositeButton(buttonStyle: viewModel.buttonStyle,
                        buttonLabel: viewModel.buttonLabel,
                        iconName: viewModel.iconName,
                        paddings: viewModel.paddings,
                        themeOptions: viewModel.themeOptions) {
            $0.addTarget(action, action: #selector(Action.perform(sender:)), for: .touchUpInside)
            action.action = {
                viewModel.action()
            }
        }
           .disabled(viewModel.isDisabled)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(viewModel.accessibilityLabel ?? viewModel.buttonLabel))
            .accessibilityAddTraits(.isButton)
    }

    class Action: NSObject {
        var action: (() -> Void)?
        @objc func perform(sender: Any?) {
            action?()
        }
    }
}
