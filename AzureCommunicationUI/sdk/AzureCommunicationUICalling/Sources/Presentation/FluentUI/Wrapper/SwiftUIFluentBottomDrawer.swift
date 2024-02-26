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
            // Ensure the UIHostingController is used for SwiftUI content.
            let hostingController = UIHostingController(rootView: content)
            if self.drawerController == nil {
                // Adjust sourceRect to ensure the drawer appears at the bottom
                let sourceRect = CGRect(x: 0, y: parent.view.bounds.height - 1,
                                        width: parent.view.bounds.width, height: 1)
                self.drawerController = DrawerController(sourceView: parent.view,
                                                         sourceRect: sourceRect,
                                                         presentationDirection: .up,
                                                         preferredMaximumHeight: 300)
            }
            guard let drawerController = drawerController else {
                return
            }

            drawerController.contentController = hostingController

            /*
             - (void) displayContentController: (UIViewController*) content {
             [self addChildViewController:content];
             content.view.frame = [self frameForContentController];
             [self.view addSubview:self.currentClientView];
             [content didMoveToParentViewController:self];
             }

             1. Call the addChildViewController: method of your container view controller.

             This method tells UIKit that your container view controller is now managing the view of 
             the child view controller.
             */
            parent.addChild(drawerController)
            /*
             2. Add the child’s root view to your container’s view hierarchy.

             Always remember to set the size and position of the child’s frame as part of this process.
             */
            parent.view.addSubview(drawerController.view)
            //drawerController.view.frame = parent.view.frame

            /*
             3. Add any constraints for managing the size and position of the child’s root view.
             */
            drawerController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                drawerController.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
                drawerController.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
                drawerController.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
                // This constraint helps in managing the height of the drawer
                drawerController.view.topAnchor.constraint(greaterThanOrEqualTo: parent.view.topAnchor)
            ])

            /*
             4. Call the didMoveToParentViewController: method of the child view controller.

             */

            drawerController.didMove(toParent: parent)
        }

        func dismissDrawer() {
            drawerController?.dismiss(animated: true)
        }
    }
}
