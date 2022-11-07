//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import UIKit

struct CompositeButton: UIViewRepresentable {
    @Binding private var buttonLabel: String

    let buttonStyle: FluentUI.ButtonStyle
    let iconName: CompositeIcon?

    init(buttonLabel: Binding<String>, buttonStyle: FluentUI.ButtonStyle, iconName: CompositeIcon? = nil) {
        _buttonLabel = buttonLabel
        self.buttonStyle = buttonStyle
        self.iconName = iconName
    }

    func makeUIView(context: Context) -> FluentUI.Button {
        let button = Button(style: buttonStyle)
        button.setTitle(buttonLabel, for: .normal)

        if let iconName = iconName {
            let icon = StyleProvider.icon.getUIImage(for: iconName)
            button.image = icon
        }

        return button
    }

    func updateUIView(_ button: FluentUI.Button, context: Context) {
        button.setTitle(buttonLabel, for: .normal)
    }
}
