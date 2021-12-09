//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct BigPaddedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration
            .label
            .foregroundColor(configuration.isPressed ? .gray : .black)
            .padding(EdgeInsets(top: 75, leading: 25, bottom: 75, trailing: 25))
            .background(Color(red: 1, green: 1, blue: 1, opacity: 0.01))
            .background(Rectangle().stroke(Color.gray))
    }
}
