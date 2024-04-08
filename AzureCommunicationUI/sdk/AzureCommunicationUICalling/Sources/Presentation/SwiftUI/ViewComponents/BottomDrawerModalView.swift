//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct BottomDrawerModalView<T: View>: ViewModifier {
    let modalContent: T
    @Binding var isPresented: Bool
    var isDialogPresented: Bool = false

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> T) {
        self._isPresented = isPresented
        self.modalContent = content()
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    Color.black.opacity(isPresented ? 0.25 : 0)
                        .edgesIgnoringSafeArea(.all)
                        .animation(.easeIn(duration: 0.25), value: isPresented)
                        .onTapGesture {
                            isPresented = false
                        }

                    bottomDrawerContent()
                }
            )
    }

    @ViewBuilder private func bottomDrawerContent() -> some View {
        GeometryReader { geometry in
            modalContent
                .frame(width: geometry.size.width)
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                .edgesIgnoringSafeArea(.all)
                .transition(.move(edge: .bottom))
                .animation(.easeIn(duration: 1.25), value: true)
        }
    }
}

// Define a simple view that will act as the modal content
struct SampleModalContentView: View {
    var body: some View {
        VStack {
            Text("Modal Content")
                .font(.title)
                .foregroundColor(.white)
            Text("Tap outside to dismiss")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(Color.blue)
    }
}

// Preview Provider
struct BottomDrawerModalView_Previews: PreviewProvider {
    static var previews: some View {
        // This is your view that the modal will be presented over
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all)
            Text("Tap here to show modal")
                .foregroundColor(.white)
        }
        // Apply your view modifier here
        .modifier(BottomDrawerModalView(isPresented: .constant(true)) {
            SampleModalContentView()
        })
    }
}
