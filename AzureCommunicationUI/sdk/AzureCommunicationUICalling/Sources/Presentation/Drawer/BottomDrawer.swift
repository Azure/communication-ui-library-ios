//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

enum DrawerState {
    case gone
    case hidden
    case visible
}

struct BottomDrawer<Content: View>: View {
    @Binding var isPresented: Bool
    @State private var drawerState: DrawerState = .gone
    let content: Content

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        _isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        ZStack {
            if drawerState != .gone {
                // Background overlay to dim main content
                Color.black.opacity(drawerState == .visible ? 0.4 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .allowsHitTesting(drawerState == .visible)

                // Drawer content
                VStack {
                    Spacer()

                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.gray)
                            .frame(width: 36, height: 4)
                            .padding()
                            .gesture( DragGesture()
                                .onEnded { value in
                                    if value.translation.height > 50 {
                                        withAnimation {
                                            isPresented = false
                                        }
                                    }
                                })
                        content
                    }.frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: drawerState == .visible)
                .offset(y: drawerState == .hidden ? UIScreen.main.bounds.height : 0)
                .ignoresSafeArea()
            }
        }
        .onChange(of: isPresented) { newValue in
            if newValue {
                // Move from gone to visible through hidden
                if drawerState == .gone {
                    drawerState = .hidden
                    withAnimation {
                        drawerState = .visible
                    }
                }
            } else {
                // Transition back to gone from visible through hidden
                withAnimation {
                    drawerState = .hidden
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Delay to allow animation to complete
                    drawerState = .gone
                }
            }
        }
    }
}
