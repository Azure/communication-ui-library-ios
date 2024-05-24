//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

enum DrawerState {
    case gone
    case hidden
    case visible
}

struct BottomDrawer<Content: View>: View {
    @ObservedObject var keyboardWatcher = LandscapeAwareKeyboardWatcher.shared
    @Binding var isPresented: Bool
    @State private var drawerState: DrawerState = .gone
    let content: Content
    let bottomOffset = 48.0

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        _isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        ZStack {
            if drawerState != .gone {
                Color.black.opacity(drawerState == .visible ? 0.4 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .allowsHitTesting(drawerState == .visible)

                VStack {
                    Spacer()

                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.gray)
                            .frame(width: 36, height: 4)
                            .padding()
                            .gesture(DragGesture()
                                .onEnded { value in
                                    if value.translation.height > 50 {
                                        withAnimation {
                                            isPresented = false
                                        }
                                    }
                                })
                        content

                        Spacer().frame(height: bottomOffset)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(StyleProvider.color.surface))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding(.bottom, keyboardWatcher.keyboardHeight - bottomOffset)
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: drawerState == .visible)
                .offset(y: drawerState == .hidden ? UIScreen.main.bounds.height : 0)
                .ignoresSafeArea()
            }
        }
        .onChange(of: isPresented) { newValue in
            if newValue {
                drawerState = .hidden
                withAnimation {
                    drawerState = .visible
                }
            } else {
                withAnimation {
                    drawerState = .hidden
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    drawerState = .gone
                }
            }
        }
    }
}
