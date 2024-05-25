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

enum DrawerConstants {
    static let drawerCornerRadius: CGFloat = 4
    static let handleColor: Color = .gray
    static let handleWidth: CGFloat = 36
    static let handleHeight: CGFloat = 4
    static let handlePaddingTop: CGFloat = 8
    static let bottomFillY: CGFloat = 48
    static let overlayOpacity: CGFloat = 0.4
}

struct BottomDrawer<Content: View>: View {
    @ObservedObject var keyboardWatcher = LandscapeAwareKeyboardWatcher.shared
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
                Color.black.opacity(drawerState == .visible ? DrawerConstants.overlayOpacity : 0)
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
                        RoundedRectangle(cornerRadius: DrawerConstants.drawerCornerRadius)
                            .fill(DrawerConstants.handleColor)
                            .frame(width: DrawerConstants.handleWidth, height: DrawerConstants.handleHeight)
                            .padding(.top, DrawerConstants.handlePaddingTop)
                            .gesture(DragGesture()
                                .onEnded { value in
                                    if value.translation.height > 50 {
                                        withAnimation {
                                            isPresented = false
                                        }
                                    }
                                })
                        content
                        Spacer().frame(height: DrawerConstants.bottomFillY)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(StyleProvider.color.surface))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding(.bottom, keyboardWatcher.activeHeight - DrawerConstants.bottomFillY)
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: drawerState == .visible)
                .offset(y: drawerState == .hidden ? UIScreen.main.bounds.height : 0)
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
