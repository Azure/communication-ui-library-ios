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

            guard let drawerController = drawerController else {
                return
            }

            drawerController.contentController = hostingController
            parent.addChild(drawerController)
            parent.view.addSubview(drawerController.view)

            // Use Auto Layout to ensure the drawer presents from the bottom.
            drawerController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                drawerController.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
                drawerController.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
                drawerController.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
                hostingController.view.heightAnchor.constraint(equalToConstant: 300)
            ])

            drawerController.didMove(toParent: parent)
        }

        func dismissDrawer() {
            drawerController?.dismiss(animated: true) {
                self.isVisible.wrappedValue = false
                self.drawerController = nil
            }
        }
    }
}
