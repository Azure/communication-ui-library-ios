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

internal enum BottomDrawerHeightStatus {
    case collapsed
    case expanded
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
}
// swiftlint:disable type_body_length
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
    @State private var drawerHeightState: BottomDrawerHeightStatus = .collapsed
    @State private var dragOffset: CGFloat = 0
    @State private var scrollViewContentSize: CGFloat = 0
    @State private var drawerHeight: CGFloat = DrawerConstants.collapsedHeight
    @State private var isExpanded = false
    @State private var isFullyExpanded = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var textEditorYPosition: CGFloat = 0
    @State private var text: String = ""
    let isPresented: Bool
    let hideDrawer: () -> Void
    let content: Content
    let isExpandable: Bool
    let showTextBox: Bool
    var drawerWorkItem: DispatchWorkItem?
    let title: String?
    let endIcon: CompositeIcon?
    let endIconAction: (() -> Void)?
    let textBoxHint: String?
    let startIcon: CompositeIcon?
    let startIconAction: (() -> Void)?
    let commitAction: ((_ message: String) -> Void)?

    init(isPresented: Bool,
         hideDrawer: @escaping () -> Void,
         title: String? = nil,
         startIcon: CompositeIcon? = nil,
         startIconAction: (() -> Void)? = nil,
         endIcon: CompositeIcon? = nil,
         endIconAction: (() -> Void)? = nil,
         showTextBox: Bool = false,
         textBoxHint: String? = nil,
         isExpandable: Bool = false,
         commitAction: ((_ message: String) -> Void)? = nil,
         @ViewBuilder content: () -> Content) {
        self.isPresented = isPresented
        self.content = content()
        self.hideDrawer = hideDrawer
        self.isExpandable = isExpandable
        self.showTextBox = showTextBox
        self.title = title
        self.endIcon = endIcon
        self.endIconAction = endIconAction
        self.textBoxHint = textBoxHint
        self.startIcon = startIcon
        self.startIconAction = startIconAction
        self.commitAction = commitAction
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
                        addKeyboardObservers()
                    }
                    .onDisappear {
                        removeKeyboardObservers()
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
                                if value.translation.height > DrawerConstants.dragThreshold && !isExpandable {
                                    withAnimation {
                                        hideDrawer()
                                    }
                                } else if isExpandable {
                                    withAnimation {
                                        drawerHeightState = value.translation.height <
                                            -DrawerConstants.dragThreshold ? .expanded : .collapsed
                                        isExpanded = drawerHeight >
                                        (DrawerConstants.collapsedHeight + DrawerConstants.expandedHeight) / 2
                                        drawerHeight = isExpanded ?
                                        DrawerConstants.expandedHeight : DrawerConstants.collapsedHeight
                                        isFullyExpanded = drawerHeight == DrawerConstants.expandedHeight
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
                if isFullyExpanded, showTextBox {
                    ZStack(alignment: .leading) {
                        textEditor
                        placeHolder
                    }.frame(height: DrawerConstants.textBoxHeight)
                        .padding([.leading, .trailing], 10)
                        .accessibilityHidden(true)
                }
                Spacer().frame(height: DrawerConstants.bottomFillY)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .background(Color(StyleProvider.color.drawerColor))
            .cornerRadius(DrawerConstants.drawerCornerRadius)
            .shadow(radius: DrawerConstants.drawerShadowRadius)
            .padding(.bottom, keyboardHeight - DrawerConstants.bottomFillY)
            .animation(.easeInOut, value: keyboardHeight + DrawerConstants.bottomFillY)
            .modifier(ConditionalFrameModifier(
                drawerHeight: $drawerHeight, isExpandable: isExpandable))
        }.onAppear {
            if showTextBox {
                DispatchQueue.main.async {
                    setDrawerHeight(to: .expanded)
                }
            }
        }
    }

    private var titleView: some View {
        VStack {
            // Handle at the top center
            if isExpandable {
                RoundedRectangle(cornerRadius: DrawerConstants.drawerHandleCornerRadius)
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 36, height: 4)
                    .padding(.top, 5)
            }

            HStack(spacing: 8) {
                if let icon = startIcon {
                    Icon(name: icon, size: DrawerListConstants.iconSize)
                        .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                        .accessibilityHidden(true)
                        .padding(.leading, 15)
                        .padding(.top, 15)
                        .onTapGesture {
                            startIconAction?()
                        }
                }
                Spacer()
                if let icon = endIcon {
                    Icon(name: icon, size: DrawerListConstants.iconSize)
                        .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                        .accessibilityHidden(true)
                        .onTapGesture {
                            endIconAction?()
                        }
                }
                if isExpandable && !isFullyExpanded {
                    Icon(name: CompositeIcon.maximize, size: DrawerListConstants.iconSize)
                        .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                        .accessibilityHidden(true)
                        .onTapGesture {
                            setDrawerHeight(to: .expanded)
                        }
                }

                if isExpandable && isFullyExpanded {
                    Icon(name: CompositeIcon.minimize, size: DrawerListConstants.iconSize)
                        .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                        .accessibilityHidden(true)
                        .onTapGesture {
                            setDrawerHeight(to: .collapsed)
                        }
                }
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
        Color.black.opacity(isExpandable ? 0.01 :
                                (drawerState == .visible ? DrawerConstants.overlayOpacity : 0))
            .ignoresSafeArea()
            .onTapGesture {
                if isFullyExpanded {
                    setDrawerHeight(to: .collapsed)
                } else {
                    hideDrawer()
                }
            }
            .accessibilityHidden(true)
    }

    private var textEditor: some View {
        VStack {
            CustomTextEditor(text: $text, onCommit: {
                let committedText = text
                commitAction?(committedText)
                DispatchQueue.main.async {
                    text = ""
                }
            }, onChange: { newText in
                commitAction?(newText)
            })
            .frame(height: DrawerConstants.textBoxHeight)
            .background(Color.white)
            .cornerRadius(DrawerConstants.drawerHandleCornerRadius)
            .overlay(RoundedRectangle(cornerRadius: DrawerConstants.drawerHandleCornerRadius)
                .stroke(Color(Colors.dividerOnPrimary)))
        }
    }

    private var placeHolder: some View {
        Group {
            if text.isEmpty, let hint = textBoxHint {
                Text(hint)
                    .foregroundColor(Color(Colors.textDisabled))
                    .padding(DrawerConstants.placeHolderPadding)
                    .allowsHitTesting(false)
            }
        }
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
                if keyboardHeight > 0 {
                    keyboardHeight -= 100
                }
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }

    func setDrawerHeight(to heightState: BottomDrawerHeightStatus) {
        guard isExpandable else {
            return
        }

        withAnimation {
            drawerHeightState = heightState
            switch heightState {
            case .collapsed:
                drawerHeight = DrawerConstants.collapsedHeight
                isExpanded = false
                isFullyExpanded = false
            case .expanded:
                drawerHeight = DrawerConstants.expandedHeight
                isExpanded = true
                isFullyExpanded = true
            }
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
}

struct ConditionalFrameModifier: ViewModifier {
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
// swiftlint:enable type_body_length
