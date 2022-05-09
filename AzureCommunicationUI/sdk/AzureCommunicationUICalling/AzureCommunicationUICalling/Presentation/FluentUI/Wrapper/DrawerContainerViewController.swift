//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI

class DrawerContainerViewController<T>: UIViewController, DrawerControllerDelegate {
    weak var delegate: DrawerControllerDelegate?
    lazy var drawerTableView: UITableView? = nil
    let backgroundColor: UIColor = UIDevice.current.userInterfaceIdiom == .pad
        ? StyleProvider.color.popoverColor
        : StyleProvider.color.drawerColor
    var items: [T] = []
    let headerName: String?
    private let sourceView: UIView
    private let showHeader: Bool
    private var halfScreenHeight: CGFloat {
        UIScreen.main.bounds.height / 2
    }
    private weak var controller: DrawerController?

    init(items: [T], sourceView: UIView, headerName: String? = nil, showHeader: Bool = false) {
        self.items = items
        self.sourceView = sourceView
        self.showHeader = showHeader
        self.headerName = headerName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        showDrawerView()
        self.resizeDrawer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || isMovingFromParent {
            sourceView.superview?.isUserInteractionEnabled = true
            sourceView.removeFromSuperview()
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIDevice.current.setValue(UIDevice.current.orientation.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        resizeDrawer()
    }

    func dismissDrawer(animated: Bool = false) {
        self.controller?.dismiss(animated: animated)
    }

    func updateDrawerList(items: [T]) {
        self.items = items
        resizeDrawer()
    }

    private func showDrawerView() {
        DispatchQueue.main.async {
            guard let topViewController = UIWindow.keyWindow?.topViewController,
                  let topView = topViewController.view else {
                return
            }

            if !topView.subviews.contains(self.sourceView) {
                self.sourceView.isHidden = true
                topView.isUserInteractionEnabled = false
                topView.addSubview(self.sourceView)
            }

            if let drawerController = self.getDrawerController(from: self.sourceView) {
                topViewController.present(drawerController, animated: true, completion: nil)
            }
        }
    }

    private func getDrawerController(from sourceView: UIView) -> DrawerController? {
        let controller = DrawerController(
            sourceView: sourceView,
            sourceRect: sourceView.bounds,
            presentationDirection: .up)
        controller.delegate = self.delegate
        controller.contentView = drawerTableView
        controller.resizingBehavior = showHeader ? .none : .dismiss
        controller.backgroundColor = backgroundColor

        self.controller = controller
        resizeDrawer()
        return controller
    }

    private func resizeDrawer() {
        let isiPhoneLayout = UIDevice.current.userInterfaceIdiom == .phone
        let cellHeight = 44
        let ipadCellHeight = 48.5
        let drawerResizeBarHeight: CGFloat = 25
        // Workaround to adjust cell divider height for drawer resize
        let dividerOffsetHeight = CGFloat(self.items.count * 3)

        var isScrollEnabled = !isiPhoneLayout
        var drawerHeight = CGFloat(self.items.count * cellHeight)

//        if isiPhoneLayout {
//            drawerHeight += dividerOffsetHeight + drawerResizeBarHeight
//        } else {
//            drawerHeight = CGFloat(self.items.count) * ipadCellHeight + (showHeader ? drawerResizeBarHeight : 0)
//        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.drawerTableView?.reloadData()

            if drawerHeight > self.halfScreenHeight {
                drawerHeight = self.halfScreenHeight
                isScrollEnabled = true
            }

            self.drawerTableView?.isScrollEnabled = isScrollEnabled
            self.controller?.preferredContentSize = CGSize(width: 400,
                                                           height: drawerHeight + (self.showHeader ? 36 : 0))
        }
    }

    private func getCellHeight(tableView: UITableView) -> CGFloat? {
        var cellHeight: CGFloat?
        for (index, cell) in self.drawerTableView!.visibleCells.enumerated() {
            print("\(index): \(cell.bounds.height)")
            cellHeight = cell.bounds.height
        }
        return cellHeight
    }
}
