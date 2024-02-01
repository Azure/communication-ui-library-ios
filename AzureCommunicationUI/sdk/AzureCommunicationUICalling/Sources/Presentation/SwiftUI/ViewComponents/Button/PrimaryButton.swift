//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct PrimaryButton: View {
    @ObservedObject var viewModel: PrimaryButtonViewModel

    var body: some View {
        // accessibilityElement(children: .combine) is required because
        // the CompositeButton is represented as a superview with subviews
        CompositeButton(buttonStyle: viewModel.buttonStyle,
                        buttonLabel: viewModel.buttonLabel,
                        iconName: viewModel.iconName,
                        paddings: viewModel.paddings)
            .onTapGesture(perform: viewModel.action)
            .disabled(viewModel.isDisabled)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(viewModel.accessibilityLabel ?? viewModel.buttonLabel))
            .accessibilityAddTraits(.isButton)
    }
}
