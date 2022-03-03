//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct PrimaryButton: View {
    @ObservedObject var viewModel: PrimaryButtonViewModel

    private let height: CGFloat = 52

    var body: some View {
        CompositeButton(buttonStyle: viewModel.buttonStyle,
                        buttonLabel: viewModel.buttonLabel,
                        iconName: viewModel.iconName)
            .onTapGesture(perform: viewModel.action)
            .frame(height: height)
            .disabled(viewModel.isDisabled)
            .accessibility(label: Text(viewModel.accessibilityLabel ?? ""))
    }
}
