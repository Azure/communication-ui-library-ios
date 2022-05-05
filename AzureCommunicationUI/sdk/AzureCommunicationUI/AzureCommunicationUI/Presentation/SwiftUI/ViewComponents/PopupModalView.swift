//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import SwiftUI

struct PopupModalView<T: View>: ViewModifier {
    let popup: T
    let isPresented: Bool
    let alignment: Alignment

    init(isPresented: Bool, alignment: Alignment = .center, @ViewBuilder content: () -> T) {
        self.isPresented = isPresented
        self.alignment = alignment
        popup = content()
    }

    func body(content: Content) -> some View {
        content
            .overlay(popupContent())
    }

    @ViewBuilder private func popupContent() -> some View {
        GeometryReader { geometry in
            if isPresented {
                popup
                    .frame(width: geometry.size.width,
                           height: geometry.size.height,
                           alignment: alignment)
            }
        }
    }
}
