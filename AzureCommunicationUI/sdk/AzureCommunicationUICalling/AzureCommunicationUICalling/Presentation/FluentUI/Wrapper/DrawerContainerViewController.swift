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
        var isScrollEnabled = !isiPhoneLayout

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            guard self.drawerTableView != nil else {
                return
            }

            self.drawerTableView!.reloadData()

            var drawerHeight = self.getDrawerHeight(
                tableView: self.drawerTableView!,
                numberOfItems: self.items.count,
                showHeader: self.showHeader,
                isiPhoneLayout: isiPhoneLayout)

            if drawerHeight > self.halfScreenHeight {
                drawerHeight = self.halfScreenHeight
                isScrollEnabled = true
            }

            self.drawerTableView!.isScrollEnabled = isScrollEnabled
            self.controller?.preferredContentSize = CGSize(width: 400,
                                                           height: drawerHeight)
        }
    }

    private func getDrawerHeight(tableView: UITableView,
                                 numberOfItems: Int,
                                 showHeader: Bool,
                                 isiPhoneLayout: Bool) -> CGFloat {
        let headerHeight = self.getHeaderHeight(tableView: tableView, isiPhoneLayout: isiPhoneLayout)
        let resizeBarHeight: CGFloat = isiPhoneLayout ? 20 : 0
        let dividerOffsetHeight = CGFloat(numberOfItems * 3)

        var drawerHeight: CGFloat = getTotalCellsHeight(tableView: tableView, numberOfItems: numberOfItems)
        drawerHeight += showHeader ? headerHeight : resizeBarHeight
        drawerHeight += dividerOffsetHeight

        return drawerHeight
    }

    private func getHeaderHeight(tableView: UITableView,
                                 isiPhoneLayout: Bool) -> CGFloat {
        return isiPhoneLayout ? tableView.sectionHeaderHeight + 20 : tableView.sectionHeaderHeight + 35
    }

    private func getTotalCellsHeight(tableView: UITableView,
                                     numberOfItems: Int) -> CGFloat {
        // If we can't get all table cell heights,
        // fall back to assumption all cells are the same height.
        guard tableView.visibleCells.count == numberOfItems else {
            let defaultCellHeight: CGFloat = 44
            var firstCellHeight: CGFloat = defaultCellHeight
            for cell in tableView.visibleCells {
                firstCellHeight = cell.bounds.height
                break
            }
            return firstCellHeight * CGFloat(numberOfItems)
        }

        var totalCellsHeight: CGFloat = 0
        for cell in tableView.visibleCells {
            totalCellsHeight += cell.bounds.height
        }
        return totalCellsHeight
    }
}
