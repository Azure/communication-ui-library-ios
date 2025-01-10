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
    static let placeHolderPadding: CGFloat = 8

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
    static let expandedHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    static let textBoxHeight: CGFloat = 40
    static let textBoxPaddingBottom: CGFloat = 10
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
    @State private var dragOffset: CGFloat = 0
    @State private var scrollViewContentSize: CGFloat = 0
    @State private var drawerHeight: CGFloat = DrawerConstants.collapsedHeight
    let isPresented: Bool
    let hideDrawer: () -> Void
    let content: Content
    var drawerWorkItem: DispatchWorkItem?
    let startIcon: CompositeIcon?
    let startIconAction: (() -> Void)?
    let title: String?

    init(isPresented: Bool,
         hideDrawer: @escaping () -> Void,
         title: String? = nil,
         startIcon: CompositeIcon? = nil,
         startIconAction: (() -> Void)? = nil,
         @ViewBuilder content: () -> Content) {
        self.isPresented = isPresented
        self.content = content()
        self.hideDrawer = hideDrawer
        self.startIcon = startIcon
        self.startIconAction = startIconAction
        self.title = title
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
            }
        }
        .onChange(of: isPresented) { newValue in
            if newValue {
                showDrawer()
            } else {
                hideDrawerAnimated()
            }
        }
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
                if title != nil {
                    titleView
                }
                content
                Spacer().frame(height: DrawerConstants.bottomFillY)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .background(Color(StyleProvider.color.drawerColor))
            .cornerRadius(DrawerConstants.drawerCornerRadius)
            .shadow(radius: DrawerConstants.drawerShadowRadius)
            .padding(.bottom, -DrawerConstants.bottomFillY)
        }
    }

    private var titleView: some View {
        VStack {
            HStack(spacing: 8) {
                if let icon = startIcon {
                    Icon(name: icon, size: DrawerListConstants.iconSize)
                        .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                        .padding(.leading, 15)
                        .padding(.top, 15)
                        .onTapGesture {
                            startIconAction?()
                        }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 10)
            .padding(.top, 5)
        }
        .overlay(
            Text(title ?? "")
                .font(.headline)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 20),
            alignment: .center
        )
    }

    private var overlayView: some View {
        // Determine the appropriate opacity based on the drawer's state
        let overlayOpacity = (drawerState == .visible) ? DrawerConstants.overlayOpacity : 0

        return Color.black.opacity(overlayOpacity)
            .ignoresSafeArea()
            .onTapGesture {
                hideDrawer()
            }
            .accessibilityHidden(true)
    }

    // MARK: - Helper Functions
    private func showDrawer() {
        drawerState = .hidden
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                drawerState = .visible
            }
        }
    }

    private func hideDrawerAnimated() {
        withAnimation {
            drawerState = .hidden
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + DrawerConstants.delayUntilGone) {
            drawerState = .gone
        }
    }
}
