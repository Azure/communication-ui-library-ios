//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI

class PopupMenuViewController: DrawerContainerViewController<PopupMenuViewModel> {
    private weak var controller: PopupMenuController?
    override var drawerController: DrawerController? {
        return controller
    }

    let backgroundColor: UIColor = UIDevice.current.userInterfaceIdiom == .pad
        ? StyleProvider.color.popoverColor
        : StyleProvider.color.drawerColor

    override func updateDrawerList(items: [PopupMenuViewModel]) {
        super.updateDrawerList(items: items)

        if let selectedItemIndex = items.firstIndex(where: { $0.isSelected }) {
            let selectedItemIndexPath = IndexPath(item: selectedItemIndex, section: 0)
            controller?.selectedItemIndexPath = selectedItemIndexPath
            controller?.viewWillAppear(true)
        }
    }

    override func getDrawerController(from sourceView: UIView) -> DrawerController {
        let controller = PopupMenuController(sourceView: sourceView,
                                             sourceRect: sourceView.bounds,
                                             presentationDirection: .up)
        controller.backgroundColor = backgroundColor
        controller.delegate = self.delegate
        let popupMenuItems = self.items.map({ item -> PopupMenuItem in
            let popupMenuItem = PopupMenuItem(image: StyleProvider.icon.getUIImage(for: item.icon),
                                              title: item.title,
                                              isSelected: item.isSelected,
                                              onSelected: item.onSelected)
            popupMenuItem.imageColor = StyleProvider.color.onBackground
            popupMenuItem.titleColor = StyleProvider.color.onBackground
            popupMenuItem.imageSelectedColor = StyleProvider.color.onBackground
            popupMenuItem.titleSelectedColor = StyleProvider.color.onBackground
            popupMenuItem.accessoryCheckmarkColor = StyleProvider.color.onBackground

            return popupMenuItem
        })
        controller.addItems(popupMenuItems)

        self.controller = controller
        return controller
    }
}
