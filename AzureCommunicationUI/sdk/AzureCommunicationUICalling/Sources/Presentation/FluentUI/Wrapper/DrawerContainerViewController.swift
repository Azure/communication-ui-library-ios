//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class DrawerContainerViewController<T: Equatable>: UIViewController,
                                                    DrawerControllerDelegate,
                                                    DrawerViewControllerProtocol {
    weak var delegate: DrawerControllerDelegate?
    lazy var drawerTableView: UITableView? = nil
    let backgroundColor: UIColor = UIDevice.current.userInterfaceIdiom == .pad
        ? StyleProvider.color.popoverColor
        : StyleProvider.color.drawerColor
    var items: [T] = []
    let headerName: String?
    private let sourceView: UIView
    private let showHeader: Bool
    private let isRightToLeft: Bool
    private weak var controller: DrawerController?

    // MARK: Constants
    private enum Constants {
        static var drawerWidth: CGFloat { return 400.0 }
        static var resizeBarHeight: CGFloat {
            UIDevice.current.userInterfaceIdiom == .phone ? 20 : 0
        }
        static var halfScreenHeight: CGFloat {
            UIScreen.main.bounds.height / 2
        }
        static var drawerHeaderMargin: CGFloat {
            UIDevice.current.userInterfaceIdiom == .phone ? 20 : 35
        }
    }
    init(sourceView: UIView,
         headerName: String? = nil,
         isRightToLeft: Bool = false
    ) {
        self.sourceView = sourceView
        self.showHeader = headerName != nil && headerName?.isEmpty == false
        self.headerName = headerName
        self.isRightToLeft = isRightToLeft
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
        resetOrientation()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        resizeDrawer()
    }

    func dismissDrawer(animated: Bool = false) {
        self.controller?.dismiss(animated: animated)
    }

    func updateDrawerList(items updatedItems: [T]) {
        // if contents are identical, do nothing
        guard self.items != updatedItems else {
            return
        }
        // should update layout if items count increases/decreases
        let shouldUpdateLayout = self.items.count != updatedItems.count
        self.items = updatedItems
        resizeDrawer(withLayoutUpdate: shouldUpdateLayout)
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
        controller.overrideUserInterfaceStyle = StyleProvider.color.colorSchemeOverride
        resizeDrawer()
        self.controller?.contentView?.semanticContentAttribute = self.isRightToLeft ?
                                                            .forceRightToLeft : .forceLeftToRight
        return controller
    }

    private func resizeDrawer(withLayoutUpdate shouldUpdateLayout: Bool = true) {
        let isiPhoneLayout = UIDevice.current.userInterfaceIdiom == .phone
        var isScrollEnabled = !isiPhoneLayout

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let drawerTableView = self.drawerTableView else {
                return
            }
            drawerTableView.reloadData()

            guard shouldUpdateLayout else {
                return
            }

            if drawerTableView.frame == CGRect.zero {
                self.setInitialTableViewFrame(isiPhoneLayout)
            }

            var drawerHeight = self.getDrawerHeight(
                tableView: drawerTableView,
                numberOfItems: self.items.count,
                showHeader: self.showHeader,
                isiPhoneLayout: isiPhoneLayout)

            if drawerHeight > Constants.halfScreenHeight {
                drawerHeight = Constants.halfScreenHeight
                isScrollEnabled = true
            }
            drawerTableView.isScrollEnabled = isScrollEnabled
            self.controller?.preferredContentSize = CGSize(width: Constants.drawerWidth,
                                                           height: drawerHeight)
        }
    }

    private func getDrawerHeight(tableView: UITableView,
                                 numberOfItems: Int,
                                 showHeader: Bool,
                                 isiPhoneLayout: Bool) -> CGFloat {
        let headerHeight = self.getHeaderHeight(tableView: tableView, isiPhoneLayout: isiPhoneLayout)
        let dividerOffsetHeight = CGFloat(numberOfItems * 3)

        var drawerHeight: CGFloat = getTotalCellsHeight(tableView: tableView, numberOfItems: numberOfItems)
        drawerHeight += showHeader ? headerHeight : Constants.resizeBarHeight
        drawerHeight += dividerOffsetHeight

        return drawerHeight
    }

    private func getHeaderHeight(tableView: UITableView,
                                 isiPhoneLayout: Bool) -> CGFloat {
        return tableView.sectionHeaderHeight + Constants.drawerHeaderMargin
    }

    private func getTotalCellsHeight(tableView: UITableView,
                                     numberOfItems: Int) -> CGFloat {
        return (0..<tableView.numberOfSections).flatMap { section in
            return (0..<tableView.numberOfRows(inSection: section)).map { row in
                return IndexPath(row: row, section: section)
            }
        }.map { index in return tableView.rectForRow(at: index).height }.reduce(0, +)
    }

    private func setInitialTableViewFrame(_ isiPhoneLayout: Bool) {
        guard let tableView = self.drawerTableView else {
            return
        }
        let initialWidth = isiPhoneLayout ? UIScreen.main.bounds.width : Constants.drawerWidth
        tableView.frame = CGRect(x: 0, y: Constants.resizeBarHeight, width: initialWidth, height: 0)
        tableView.setNeedsDisplay()
    }
}
