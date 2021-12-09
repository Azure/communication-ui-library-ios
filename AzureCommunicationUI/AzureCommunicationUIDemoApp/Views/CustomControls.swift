//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct DemoButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .foregroundColor(isEnabled ? .white : .disabledWhite)
            .background(isEnabled ? Color.blue : Color.disabledBlue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension Color {
  static let disabledBlue = Color(red: 188 / 255.0, green: 224 / 255.0, blue: 253 / 255.0)
  static let disabledWhite = Color(white: 1, opacity: 179 / 255.0)
}
