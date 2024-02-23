//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import SwiftUI
import FluentUI
import UIKit

internal struct SwiftUIFluentBottomDrawer<Content: View>: UIViewControllerRepresentable {
    @Binding var isVisible: Bool
    let content: () -> Content

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isVisible {
            context.coordinator.presentDrawer(from: uiViewController, content: content())
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

        init(isVisible: Binding<Bool>) {
            self.isVisible = isVisible
        }

        func presentDrawer(from parent: UIViewController, content: Content) {
            let hostingController = UIHostingController(rootView: content)
            drawerController = DrawerController(sourceView: parent.view,
                                                sourceRect: parent.view.bounds,
                                                presentationDirection: .up)
            drawerController?.contentController = hostingController
            parent.addChild(drawerController!)
            parent.view.addSubview(drawerController!.view)
            drawerController!.view.frame = parent.view.bounds
            drawerController?.didMove(toParent: parent)
            // want to have views frame always equal to the parent frame
        }

        func dismissDrawer() {
            drawerController?.dismiss(animated: true) {
                self.isVisible.wrappedValue = false
                self.drawerController = nil
            }
        }
    }
}
