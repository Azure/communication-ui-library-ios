//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

internal enum DrawerState {
    case gone
    case hidden
    case visible
}

internal enum DrawerConstants {
    // How round is the drawer handle
    static let drawerHandleCornerRadius: CGFloat = 4

    // How round is the drawer itself
    static let drawerCornerRadius: CGFloat = 16

    // How much shadow is under the drawer
    static let drawerShadowRadius: CGFloat = 10

    // Color of the handle (Generic gray works in light/dark)
    static let handleColor: Color = .gray

    // Width of the handle
    static let handleWidth: CGFloat = 36

    // Height of the handle
    static let handleHeight: CGFloat = 4

    // Padding above the handle
    static let handlePaddingTop: CGFloat = 8

    // How much "fill" below the content to push it off the bottom os the screen
    static let bottomFillY: CGFloat = 48

    // Opacity of faded items (like background overlay)
    static let overlayOpacity: CGFloat = 0.4

    // How much drag you need on the drawer to dismiss in that way
    static let dragThreshold: CGFloat = 50

    // After hiding, the delay before making it "gone", accounts for animation
    static let delayUntilGone: CGFloat = 0.3
}

/// Bottom Drawer w/Swift UI Support
///
/// How it works:
/// When enabling/disabling, state goes Gone->Hidden->Visible, or Visible->HIdden->Gone
/// Gone is means the content is not included in the view
/// Hidden is the "off screen state" to allow for animation transitions
/// Visible is the "on screen state" when it's displayed
///
/// When tapping out, or dragging down on the handle, the hideDrawer functions is called
///
/// Examples Usage:
///     BottomDrawer(isPresented: viewModel.supportFormViewModel.isDisplayed,
///                  hideDrawer: viewModel.supportFormViewModel.hideForm) {
///         reportErrorView
///         .accessibilityElement(children: .contain)
///         .accessibilityAddTraits(.isModal)
///    }
internal struct BottomDrawer<Content: View>: View {
    @State private var drawerState: DrawerState = .gone
    let isPresented: Bool
    let hideDrawer: () -> Void
    let content: Content

    init(isPresented: Bool, hideDrawer: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.isPresented = isPresented
        self.content = content()
        self.hideDrawer = hideDrawer
    }

    var body: some View {
        ZStack {
            if drawerState != .gone {
                Color.black.opacity(drawerState == .visible ? DrawerConstants.overlayOpacity : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            hideDrawer()
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
                                    if value.translation.height > DrawerConstants.dragThreshold {
                                        withAnimation {
                                            hideDrawer()
                                        }
                                    }
                                })
                        content
                        Spacer().frame(height: DrawerConstants.bottomFillY)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(StyleProvider.color.surface))
                    .cornerRadius(DrawerConstants.drawerCornerRadius)
                    .shadow(radius: DrawerConstants.drawerShadowRadius)
                    .padding(.bottom, -DrawerConstants.bottomFillY)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + DrawerConstants.delayUntilGone) {
                    drawerState = .gone
                }
            }
        }
    }
}
