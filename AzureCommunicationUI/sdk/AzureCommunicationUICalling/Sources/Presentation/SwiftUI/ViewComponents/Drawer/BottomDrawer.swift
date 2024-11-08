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

internal enum DrawerHeightState {
    case collapsed
    case expanded
}

internal enum DrawerConstants {
    // How round is the drawer handle
    static let drawerHandleCornerRadius: CGFloat = 4

    // How round is the drawer itself
    static let drawerCornerRadius: CGFloat = 16

    // How much shadow is under the drawer
    static let drawerShadowRadius: CGFloat = 10

    // How much "fill" below the content to push it off the bottom os the screen
    static let bottomFillY: CGFloat = 48

    // Opacity of faded items (like background overlay)
    static let overlayOpacity: CGFloat = 0.4

    // How much drag you need on the drawer to dismiss in that way
    static let dragThreshold: CGFloat = 100

    // After hiding, the delay before making it "gone", accounts for animation
    static let delayUntilGone: CGFloat = 0.3
    static let collapsedHeight: CGFloat = 200
    static let expandedHeight: CGFloat = UIScreen.main.bounds.height * 0.8
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
///
///  Typically used (if presenting a list) with DrawerListView
///
internal struct BottomDrawer<Content: View>: View {
    @State private var drawerState: DrawerState = .gone
    @State private var drawerHeightState: DrawerHeightState = .collapsed
    @State private var dragOffset: CGFloat = 0
    @State private var scrollViewContentSize: CGFloat = 0
    @State private var drawerHeight: CGFloat = DrawerConstants.collapsedHeight
    @State private var isExpanded = false

    let isPresented: Bool
    let hideDrawer: () -> Void
    let content: Content
    let isExpandable: Bool
    var drawerWorkItem: DispatchWorkItem?

    init(isPresented: Bool,
         hideDrawer: @escaping () -> Void,
         @ViewBuilder content: () -> Content,
         isExpandable: Bool = false) {
        self.isPresented = isPresented
        self.content = content()
        self.hideDrawer = hideDrawer
        self.isExpandable = isExpandable
    }
    var body: some View {
        ZStack(alignment: .bottom) {
            if drawerState != .gone {
                overlayView
                drawerView
                    .transition(.move(edge: .bottom))
                    .offset(y: drawerState == .hidden ? UIScreen.main.bounds.height : max(dragOffset, 0))
                    .animation(.easeInOut, value: drawerState == .visible)
                    .accessibilityAddTraits(.isModal)
                    .onAppear {
                        UIAccessibility.post(notification: .screenChanged, argument: nil)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.height
                                if isExpandable {
                                    let newHeight = drawerHeight - value.translation.height
                                    drawerHeight = min(max(newHeight,
                                                           DrawerConstants.collapsedHeight),
                                                       DrawerConstants.expandedHeight)
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > DrawerConstants.dragThreshold {
                                    withAnimation {
                                        hideDrawer()
                                    }
                                } else if isExpandable {
                                    withAnimation {
                                        drawerHeightState = value.translation.height <
                                            -DrawerConstants.dragThreshold ? .expanded : .collapsed
                                        let threshold = UIScreen.main.bounds.height * 0.5
                                        isExpanded = drawerHeight >
                                        (DrawerConstants.collapsedHeight + DrawerConstants.expandedHeight) / 2
                                        drawerHeight = isExpanded ?
                                        DrawerConstants.expandedHeight : DrawerConstants.collapsedHeight
                                    }
                                }
                                dragOffset = 0
                            }
                    )
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

    private var overlayView: some View {
        Color.black.opacity(drawerState == .visible ? DrawerConstants.overlayOpacity : 0)
            .ignoresSafeArea()
            .onTapGesture {
                hideDrawer()
            }
            .accessibilityHidden(true)
    }

    private var drawerView: some View {
        VStack {
            Spacer()
            VStack {
                Color.clear.frame(maxWidth: .infinity, maxHeight: 1)
                    .accessibilityHidden(drawerState != .visible)
                    .accessibilityLabel(Text("Close Drawer"))
                    .accessibilityAction {
                        hideDrawer()
                    }
                    .accessibility(hidden: drawerState != .visible)
                    .allowsHitTesting(drawerState == .visible)

                content
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color(StyleProvider.color.surface))
            .cornerRadius(DrawerConstants.drawerCornerRadius)
            .shadow(radius: DrawerConstants.drawerShadowRadius)
            .padding(.bottom, -DrawerConstants.bottomFillY)
            .modifier(ConditionalFrameModifier(isExpanded: $isExpanded,
                                               drawerHeight: $drawerHeight, isExpandable: isExpandable))
        }
    }
}

struct ConditionalFrameModifier: ViewModifier {
    @Binding var isExpanded: Bool
    @Binding var drawerHeight: CGFloat
    let isExpandable: Bool

    func body(content: Content) -> some View {
        Group {
            if isExpandable {
                content.frame(height: drawerHeight)
            } else {
                content
            }
        }
    }
}
