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
    let themeOptions: ThemeOptions
    var update: (FluentUI.Button, Context) -> Void
    init(buttonStyle: FluentUI.ButtonStyle,
         buttonLabel: String,
         iconName: CompositeIcon? = nil,
         paddings: Paddings? = nil,
         themeOptions: ThemeOptions,
         update: @escaping (FluentUI.Button) -> Void) {
        self.buttonStyle = buttonStyle
        self.buttonLabel = buttonLabel
        self.iconName = iconName
        self.paddings = paddings
        /* <CUSTOM_COLOR_FEATURE> */
        self.themeOptions = themeOptions
        /* </CUSTOM_COLOR_FEATURE> */
        self.update = { view, _ in update(view) }
    }

     func makeUIView(context: Context) -> FluentUI.Button {
         return createButton(style: buttonStyle,
                             label: buttonLabel,
                             paddings: paddings,
                             themeOptions: themeOptions,
                             iconName: iconName)
     }
    func createButton(
            style: FluentUI.ButtonStyle,
            label: String,
            paddings: Paddings?,
            themeOptions: ThemeOptions,
            iconName: CompositeIcon? = nil
        ) -> FluentUI.Button {
        let button = Button(style: buttonStyle)
        button.setTitle(buttonLabel, for: .normal)
         /* <CUSTOM_COLOR_FEATURE> */
                let dynamicColor = (buttonStyle == .borderless ||
                                   buttonStyle == .primaryOutline)
                                   ? themeOptions.primaryColor.dynamicColor
                                   : themeOptions.foregroundOnPrimaryColor.dynamicColor
                let overrideTokens: [ButtonTokenSet.Tokens: ControlTokenValue] = [
                    .foregroundColor: ControlTokenValue.dynamicColor({
                        dynamicColor!
                    }),
                    .foregroundPressedColor: ControlTokenValue.dynamicColor({
                        dynamicColor!
                    })]
                button.tokenSet.replaceAllOverrides(with: overrideTokens)
         /* </CUSTOM_COLOR_FEATURE> */
                 if let paddings = paddings {
                    button.edgeInsets = getEdgeInserts(paddings)
                }
        if let iconName = iconName {
            /* <CUSTOM_COLOR_FEATURE> */
            let icon = StyleProvider.icon.getUIImage(for: iconName)?.withRenderingMode(.alwaysTemplate)
            button.setImage(icon, for: .normal)
            button.tintColor = themeOptions.foregroundOnPrimaryColor
            /* </CUSTOM_COLOR_FEATURE> */
        }

        return button

    }

    func updateUIView(_ button: FluentUI.Button, context: Context) {
        update(button, context)
    }

     func getEdgeInserts(_ paddings: Paddings) -> NSDirectionalEdgeInsets {
        return NSDirectionalEdgeInsets(top: paddings.vertical,
                                       leading: paddings.horizontal,
                                       bottom: paddings.vertical,
                                       trailing: paddings.horizontal)
    }
}
