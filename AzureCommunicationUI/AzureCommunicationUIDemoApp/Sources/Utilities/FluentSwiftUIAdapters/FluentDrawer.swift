//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import SwiftUI
import FluentUI
import UIKit

internal struct FluentDrawer<Content: View>: UIViewControllerRepresentable {
    @Binding var isVisible: Bool
    let content: Content
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isVisible {
            context.coordinator.presentDrawer(from: uiViewController, content: AnyView(content))
        } else {
            context.coordinator.dismissDrawer()
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(isVisible: $isVisible)
    }
    class Coordinator {
        var isVisible: Binding<Bool>
        var drawerController: DrawerController?
        let sourceView: UIView
        init(isVisible: Binding<Bool>) {
            self.isVisible = isVisible
            self.sourceView = UIView()
        }
        func presentDrawer(from parent: UIViewController, content: AnyView) {
            // Create a hosting controller for our SwiftUI content
            let hostingController = UIHostingController(rootView: content)
            // Create and configure the drawer controller
            drawerController = DrawerController(sourceView: sourceView,
                                                sourceRect: UIScreen.main.bounds,
                                                presentationDirection: .up)
            drawerController?.contentController = hostingController
            drawerController?.presentationStyle = .automatic
            drawerController?.resizingBehavior = .dismissOrExpand
            // Present the drawer
            parent.present(drawerController!, animated: true) {
                self.isVisible.wrappedValue = true
            }
        }
        func dismissDrawer() {
            drawerController?.dismiss(animated: true) {
                self.isVisible.wrappedValue = false
                self.drawerController = nil // Release the drawer controller
            }
        }
    }
}
