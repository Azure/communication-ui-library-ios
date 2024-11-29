//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
// MARK: - RoundedCorner Shape

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    // Allows the shape to animate smoothly
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
// swiftlint:disable type_body_length
internal struct ExpandableDrawer<Content: View>: View {
    // MARK: - Properties

    // Bindings
    @Binding var isPresented: Bool
    @Binding var isAutoCommitted: Bool

    // Drawer Configuration
    let hideDrawer: () -> Void
    let title: String?
    let endIcon: CompositeIcon?
    let endIconAction: (() -> Void)?
    let showTextBox: Bool
    let textBoxHint: String?
    let commitAction: ((_ message: String, _ isFinal: Bool?) -> Void)?

    // Content
    let content: Content

    // Internal States
    @State private var drawerState: DrawerState = .gone
    @State private var drawerHeightState: BottomDrawerHeightStatus = .collapsed
    @State private var dragOffset: CGFloat = 0
    @State private var drawerHeight: CGFloat = DrawerConstants.collapsedHeight
    @State private var text: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var isFullyExpanded = false
    @State private var isExpanded = false

    // MARK: - Initializer
    init(
        isPresented: Binding<Bool>,
        hideDrawer: @escaping () -> Void,
        title: String? = nil,
        endIcon: CompositeIcon? = nil,
        endIconAction: (() -> Void)? = nil,
        showTextBox: Bool = false,
        textBoxHint: String? = nil,
        isAutoCommitted: Binding<Bool> = .constant(false),
        commitAction: ((_ message: String, _ isFinal: Bool?) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self._isAutoCommitted = isAutoCommitted
        self.hideDrawer = hideDrawer
        self.title = title
        self.endIcon = endIcon
        self.endIconAction = endIconAction
        self.showTextBox = showTextBox
        self.textBoxHint = textBoxHint
        self.commitAction = commitAction
        self.content = content()
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            if drawerState != .gone {
                // Background Overlay
                overlayView

                // Drawer Content
                drawerView
                    .transition(.move(edge: .bottom))
                    .offset(y: drawerState == .hidden ? UIScreen.main.bounds.height : max(dragOffset, 0))
                    .animation(.easeInOut, value: drawerState == .visible)
                    .accessibilityAddTraits(.isModal)
            }
        }
        .onChange(of: isPresented) { newValue in
            newValue ? showDrawer() : hideDrawerAnimated()
        }
        .onChange(of: isAutoCommitted) { shouldClear in
            if shouldClear {
                clearText()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                    let newHeight = drawerHeight - value.translation.height
                    drawerHeight = min(max(newHeight,
                                           DrawerConstants.collapsedHeight),
                                       DrawerConstants.expandedHeight)
                }
                .onEnded { value in
                    withAnimation {
                        drawerHeightState = value.translation.height <
                            -DrawerConstants.dragThreshold ? .expanded : .collapsed
                        isExpanded = drawerHeight >
                        (DrawerConstants.collapsedHeight + DrawerConstants.expandedHeight) / 2
                        drawerHeight = isExpanded ?
                        DrawerConstants.expandedHeight : DrawerConstants.collapsedHeight
                        isFullyExpanded = drawerHeight == DrawerConstants.expandedHeight
                    }
                    dragOffset = 0
                }
        )
        .onAppear {
            if isPresented {
                showDrawer()
            }
            addKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }

    // MARK: - Drawer View
    private var drawerView: some View {
        VStack {
            Spacer()
            VStack {
                // Handle for Dragging
                handleView

                // Title and Icons
                titleView

                // Content
                content

                // Text Editor (if applicable)
                if isFullyExpanded && showTextBox {
                    textEditor
                        .frame(height: DrawerConstants.textBoxHeight)
                        .padding([.leading, .trailing], 10)
                }

                // Bottom Padding to Push Content Off-Screen
                Spacer().frame(height: DrawerConstants.textBoxPaddingBottom)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .background(Color(StyleProvider.color.drawerColor))
            .clipShape(RoundedCorner(radius: DrawerConstants.drawerCornerRadius, corners: [.topLeft, .topRight]))
            .shadow(radius: DrawerConstants.drawerShadowRadius)
            .padding(.bottom, keyboardHeight)
            .animation(.easeInOut, value: keyboardHeight)
            .frame(height: drawerHeight)
        }
        .onAppear {
            if showTextBox {
                DispatchQueue.main.async {
                    setDrawerHeight(to: .expanded)
                }
            } else {
                DispatchQueue.main.async {
                    setDrawerHeight(to: .collapsed)
                }
            }
        }
    }

    // MARK: - Handle View
    private var handleView: some View {
        RoundedRectangle(cornerRadius: DrawerConstants.drawerHandleCornerRadius)
            .fill(Color.gray.opacity(0.6))
            .frame(width: 36, height: 4)
            .padding(.top, 5)
    }

    // MARK: - Title View
    private var titleView: some View {
        VStack {
            HStack(spacing: 8) {
                Spacer()
                // End Icon (if any)
                if let icon = endIcon {
                    Icon(name: icon, size: DrawerListConstants.iconSize)
                        .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                        .onTapGesture {
                            endIconAction?()
                        }
                }

                Icon(name: isFullyExpanded ? CompositeIcon.minimize :
                        CompositeIcon.maximize, size: DrawerListConstants.iconSize)
                    .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                    .onTapGesture {
                        setDrawerHeight(to: isFullyExpanded ? .collapsed : .expanded)
                    }
            }
            .padding([.leading, .trailing], 10)
            .padding(.top, 15)
        }.overlay(
            Text(title ?? "")
                .font(.headline)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 15),
            alignment: .center
        )

    }

    // MARK: - Overlay View
    private var overlayView: some View {
        Color.black.opacity(isFullyExpanded ? DrawerConstants.overlayOpacity : 0)
            .ignoresSafeArea()
            .onTapGesture {
                if isFullyExpanded {
                    setDrawerHeight(to: .collapsed)
                }
            }
            .accessibilityHidden(true)
    }

    // MARK: - Text Editor
    private var textEditor: some View {
        CustomTextField(
            text: $text,
            placeholder: textBoxHint ?? "",
            onCommit: {
                commitAction?(text, true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    text = ""
                }
            },
            onChange: { newText in
                commitAction?(newText, false)
            }
        )
        .frame(height: DrawerConstants.textBoxHeight)
        .frame(maxWidth: .infinity)
        .onChange(of: isAutoCommitted) { shouldClear in
            if shouldClear {
                clearText()
            }
        }
    }

    // MARK: - Helper Functions

    /// Displays the drawer with animation.
    private func showDrawer() {
        drawerState = .hidden
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                drawerState = .visible
            }
        }
    }

    /// Hides the drawer with animation and sets state to gone after delay.
    private func hideDrawerAnimated() {
        withAnimation {
            drawerState = .hidden
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + DrawerConstants.delayUntilGone) {
            drawerState = .gone
        }
    }

    /// Toggles the drawer between visible and hidden states.
    private func toggleDrawer() {
        if drawerState == .visible {
            hideDrawerAnimated()
        } else {
            showDrawer()
        }
    }

    /// Sets the drawer height to collapsed or expanded.
    /// - Parameter heightState: The desired height state.
    private func setDrawerHeight(to heightState: BottomDrawerHeightStatus) {
        withAnimation {
            drawerHeightState = heightState
            switch heightState {
            case .collapsed:
                drawerHeight = DrawerConstants.collapsedHeight
                isFullyExpanded = false
            case .expanded:
                drawerHeight = DrawerConstants.expandedHeight
                isFullyExpanded = true
            }
        }
    }

    /// Clears the text in the text editor and resets auto-commit state.
    private func clearText() {
        DispatchQueue.main.async {
            text = ""
            isAutoCommitted = false
        }
    }

    // MARK: - Keyboard Observers

    /// Adds observers for keyboard show and hide notifications.
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
                if keyboardHeight > 0 {
                    keyboardHeight -= 120
                }
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }

    /// Removes keyboard observers.
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension ExpandableDrawer {
    /// Determines if the device is in landscape mode based on width and height.
    private func isLandscape(geometry: GeometryProxy) -> Bool {
        return geometry.size.width > geometry.size.height
    }
}
// swiftlint:enable type_body_length
