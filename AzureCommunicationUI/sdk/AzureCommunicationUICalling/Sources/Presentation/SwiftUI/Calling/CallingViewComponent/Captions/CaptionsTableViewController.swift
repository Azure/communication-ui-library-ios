//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

class CaptionsTableViewController: UITableViewController {
    override func viewDidLoad() {
        tableView.separatorStyle = .none
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        (tableView.dataSource as? CaptionsViewManager)?.startCaptionSimulationTimer(tableView: tableView)
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        (tableView.dataSource as? CaptionsViewManager)?.stopCaptionSimulationTimer()
        super.viewDidDisappear(animated)
    }
}
