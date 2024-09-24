//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import UIKit

struct CompositeButton: UIViewRepresentable {

    struct Paddings {
        let horizontal: CGFloat
        let vertical: CGFloat
    }

    let buttonStyle: FluentUI.ButtonStyle
    let buttonLabel: String
    let iconName: CompositeIcon?
    let paddings: Paddings?

    var update: (FluentUI.Button, Context) -> Void

    init(buttonStyle: FluentUI.ButtonStyle,
         buttonLabel: String,
         iconName: CompositeIcon? = nil,
         paddings: Paddings? = nil,
         updater update: @escaping (FluentUI.Button) -> Void) {
        self.buttonStyle = buttonStyle
        self.buttonLabel = buttonLabel
        self.iconName = iconName
        self.paddings = paddings
        self.update = { view, _ in update(view) }
    }

    func makeUIView(context: Context) -> FluentUI.Button {
        let button = Button(style: buttonStyle)
        button.setTitle(buttonLabel, for: .normal)

        if let paddings = paddings {
            button.edgeInsets = getEdgeInserts(paddings)
        }

        if let iconName = iconName {
            let icon = StyleProvider.icon.getUIImage(for: iconName)
            button.image = icon
        }

        return button
    }

    func updateUIView(_ button: FluentUI.Button, context: Context) {
        update(button, context)
    }

    private func getEdgeInserts(_ paddings: Paddings) -> NSDirectionalEdgeInsets {
        return NSDirectionalEdgeInsets(top: paddings.vertical,
                                       leading: paddings.horizontal,
                                       bottom: paddings.vertical,
                                       trailing: paddings.horizontal)
    }
}
