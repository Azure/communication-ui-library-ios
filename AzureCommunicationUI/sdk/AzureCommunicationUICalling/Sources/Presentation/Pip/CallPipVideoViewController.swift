//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVKit

@available(iOS 15.0, *)
final class CallPipVideoViewController: AVPictureInPictureVideoCallViewController {
    var onRequirePipContentView: (() -> UIView?)?
    var onRequireContentFailed: (() -> Void)?

//    private let pipPlaceholderView: UIView

    /// Indicate if the pip container is ready for adding content.
    private var isPipPlaceholderReady: Bool = false

    public init(pipPlaceholderView: UIView) {
//        self.pipPlaceholderView = pipPlaceholderView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        view.addSubview(pipPlaceholderView)
//        pipPlaceholderView.isHidden = false
        isPipPlaceholderReady = true
        addPipContent()
    }

    private func addPipContent() {
        guard let pipContentView = onRequirePipContentView?() else {
            return
        }

        pipContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pipContentView)

        pipContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pipContentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pipContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pipContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pipContentView.isHidden = false
    }
}
