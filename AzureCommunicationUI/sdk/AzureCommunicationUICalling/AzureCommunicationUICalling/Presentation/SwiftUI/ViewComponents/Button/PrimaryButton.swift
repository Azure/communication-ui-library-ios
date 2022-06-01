//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct PrimaryButton: View {
    @ObservedObject var viewModel: PrimaryButtonViewModel

    private let height: CGFloat = 52

    var body: some View {
        // accessibilityElement(children: .combine) is required because
        // the CompositeButton is represented as a superview with subviews
        CompositeButton(buttonStyle: viewModel.buttonStyle,
                        buttonLabel: viewModel.buttonLabel,
                        iconName: viewModel.iconName)
            .onTapGesture(perform: viewModel.action)
            .frame(height: height)
            .disabled(viewModel.isDisabled)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(viewModel.accessibilityLabel ?? viewModel.buttonLabel))
            .accessibilityAddTraits(.isButton)
    }
}
