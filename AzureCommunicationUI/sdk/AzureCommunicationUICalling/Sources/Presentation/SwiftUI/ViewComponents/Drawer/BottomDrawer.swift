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
    static let dragThreshold: CGFloat = 200

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
    @State private var drawerHeight: CGFloat = DrawerConstants.collapsedHeight
    let isPresented: Bool
    let hideDrawer: () -> Void
    let content: Content
    let startIcon: CompositeIcon?
    let startIconAction: (() -> Void)?
    let startIconAccessibilityLabel: String?
    let dismissAccessibilityLabel: String?
    let title: String?

    var dragThreshold: CGFloat = DrawerConstants.dragThreshold

    init(isPresented: Bool,
         hideDrawer: @escaping () -> Void,
         title: String? = nil,
         startIcon: CompositeIcon? = nil,
         startIconAction: (() -> Void)? = nil,
         startIconAccessibilityLabel: String? = nil,
         dismissAccessibilityLabel: String? = nil,
         dragThreshold: CGFloat = DrawerConstants.dragThreshold,
         @ViewBuilder content: () -> Content) {
        self.isPresented = isPresented
        self.content = content()
        self.hideDrawer = hideDrawer
        self.startIcon = startIcon
        self.startIconAction = startIconAction
        self.title = title
        self.dragThreshold = dragThreshold
        self.startIconAccessibilityLabel = startIconAccessibilityLabel
        self.dismissAccessibilityLabel = dismissAccessibilityLabel
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if drawerState != .gone {
                Group {
                    overlayView
                    drawerView
                }
                .accessibilityElement(children: .contain)
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
                handleView
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
        .transition(.move(edge: .bottom))
        .offset(y: drawerState == .hidden ? UIScreen.main.bounds.height : max(dragOffset, 0))
        .animation(.easeInOut, value: drawerState == .visible)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newHeight = drawerHeight - value.translation.height
                    drawerHeight = min(max(newHeight, DrawerConstants.collapsedHeight),
                                       DrawerConstants.expandedHeight)
                }
                .onEnded { value in
                    withAnimation {
                        if value.translation.height > dragThreshold {
                            collapseDrawer()
                        } else if value.translation.height < -dragThreshold {
                            expandDrawer()
                        } else {
                            resetDrawer()
                        }
                    }
                    dragOffset = 0
                }
        )
    }

    private var handleView: some View {
        RoundedRectangle(cornerRadius: DrawerConstants.drawerHandleCornerRadius)
            .fill(Color.gray.opacity(0.6))
            .frame(width: 36, height: 4)
            .padding(.top, 5)
    }

    private var titleView: some View {
        VStack {
            HStack(spacing: 8) {
                if let icon = startIcon {
                    Icon(name: icon, size: DrawerListConstants.iconSize)
                        .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                        .padding(.leading, 15)
                        .padding(.top, 15)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityRemoveTraits(.isImage)
                        .accessibilityLabel(startIconAccessibilityLabel ?? "back")
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
        let overlayOpacity = (drawerState == .visible) ? DrawerConstants.overlayOpacity : 0

        return Color.black.opacity(overlayOpacity)
            .ignoresSafeArea()
            .onTapGesture {
                hideDrawer()
            }
            .accessibilityLabel(dismissAccessibilityLabel ?? "Dismiss drawer")
            .accessibilityAddTraits(.isButton)
    }

    // MARK: - Helper Functions
    private func showDrawer() {
        drawerState = .hidden
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                drawerState = .visible
                drawerHeight = DrawerConstants.collapsedHeight
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

    private func collapseDrawer() {
        drawerState = .hidden
        hideDrawer()
        drawerHeight = DrawerConstants.collapsedHeight
    }

    private func expandDrawer() {
        drawerState = .visible
        drawerHeight = DrawerConstants.expandedHeight
    }

    private func resetDrawer() {
        if drawerHeight > (DrawerConstants.collapsedHeight + DrawerConstants.expandedHeight) / 2 {
            expandDrawer()
        } else {
            collapseDrawer()
        }
    }
}

struct ButtonActions {
    let showSharingViewAction: (() -> Void)?
    let showSupportFormAction: (() -> Void)?
    let showCaptionsViewAction: (() -> Void)?
    let showSpokenLanguage: (() -> Void)?
    let showCaptionsLanguage: (() -> Void)?
    let showRttView: (() -> Void)?

    init(
        showSharingViewAction: (() -> Void)? = { },
        showSupportFormAction: (() -> Void)? = { },
        showCaptionsViewAction: (() -> Void)? = { },
        showSpokenLanguage: (() -> Void)? = { },
        showCaptionsLanguage: (() -> Void)? = { },
        showRttView: (() -> Void)? = { }
    ) {
        self.showSharingViewAction = showSharingViewAction
        self.showSupportFormAction = showSupportFormAction
        self.showCaptionsViewAction = showCaptionsViewAction
        self.showSpokenLanguage = showSpokenLanguage
        self.showCaptionsLanguage = showCaptionsLanguage
        self.showRttView = showRttView
    }
}
