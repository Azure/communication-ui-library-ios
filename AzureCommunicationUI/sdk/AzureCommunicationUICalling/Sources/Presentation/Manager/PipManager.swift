//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import UIKit
import AVKit

protocol PipManagerProtocol {
    func stopPictureInPicture()
    func reset()
}

class PipManager: NSObject, PipManagerProtocol {
    private let store: Store<AppState, Action>
    private let logger: Logger

    private var onRequirePipContentView: () -> UIView?
    private var onRequirePipPlaceholderView: () -> UIView?
    private var onPipStarted: () -> Void
    private var onPipStoped: () -> Void
    private var onPipStartFailed: () -> Void

    /// Pip controller for System AVKit Pip Window
    private var avKitPipController: AVPictureInPictureController?
    /// Pip view controller embeds into System AVKit Pip Window
    private var pipVideoController: UIViewController?

    private var turnCameraOffWhilePipIsStarting: Bool = false

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState, Action>,
         logger: Logger,
         onRequirePipContentView: @escaping () -> UIView?,
         onRequirePipPlaceholderView: @escaping () -> UIView?,
         onPipStarted: @escaping () -> Void,
         onPipStoped: @escaping () -> Void,
         onPipStartFailed: @escaping () -> Void) {

        self.store = store
        self.logger = logger
        self.onRequirePipContentView = onRequirePipContentView
        self.onRequirePipPlaceholderView = onRequirePipPlaceholderView
        self.onPipStarted = onPipStarted
        self.onPipStoped = onPipStoped
        self.onPipStartFailed = onPipStartFailed
        super.init()

        commonInit()
    }

    private func startPictureInPicture() {
        logger.debug("testpip: startPictureInPicture")
        turnCameraOffWhilePipIsStarting = self.store.state.localUserState.cameraState.operation == .on
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.avKitPipController?.startPictureInPicture()
        }
    }

    func stopPictureInPicture() {
        avKitPipController?.stopPictureInPicture()
        store.dispatch(action: .visibilityAction(.showNormalEntered))
    }

    func reset() {
        pipVideoController = nil
        avKitPipController = nil
        updateStartPipAutomatically(navigationState: store.state.navigationState)
    }

    private func commonInit() {
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state: state)
            }.store(in: &cancellables)
    }

    private func receive(state: AppState) {
        updateStartPipAutomatically(navigationState: state.navigationState)

        if state.visibilityState.currentStatus == .pipModeRequested {
            guard #available(iOS 15.0, *), AVPictureInPictureController.isPictureInPictureSupported() else {
                onPipStartFailed()
                return
            }
            store.dispatch(action: .visibilityAction(.pipModeLaunching))
            startPictureInPicture()
        }
    }

    private func updateStartPipAutomatically(navigationState: NavigationState) {
        guard #available(iOS 15.0, *), AVPictureInPictureController.isPictureInPictureSupported() else {
            return
        }

        if navigationState.status == .inCall {
            if self.pipVideoController != nil {
                return
            }
            guard let pipPlaceholderView = onRequirePipPlaceholderView() else {
                return
            }

            pipPlaceholderView.isHidden = false

            let pipVideoCallViewController = CallPipVideoViewController(pipPlaceholderView: pipPlaceholderView)
            pipVideoCallViewController.onRequirePipContentView = onRequirePipContentView

            let contentSource = AVPictureInPictureController.ContentSource(
                activeVideoCallSourceView: pipPlaceholderView, contentViewController: pipVideoCallViewController)

            let avKitPipController = AVPictureInPictureController(contentSource: contentSource)

            avKitPipController.canStartPictureInPictureAutomaticallyFromInline = true
            avKitPipController.delegate = self

            self.pipVideoController = pipVideoCallViewController
            self.avKitPipController = avKitPipController
        } else {
            pipVideoController = nil
            avKitPipController = nil
        }
    }

}

extension PipManager: AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerDidStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController) {
            logger.debug("testpip: pip Did Stop")
            self.onPipStoped()
            store.dispatch(action: .visibilityAction(.showNormalEntered))
    }

    public func pictureInPictureControllerWillStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController) {
            logger.debug("testpip: pip Will Start")
            if turnCameraOffWhilePipIsStarting {
                self.store.dispatch(action: .localUserAction(.cameraOffTriggered))
            }
    }

    public func pictureInPictureControllerDidStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController) {
            logger.debug("testpip: pip Did Start")
            self.onPipStarted()
            self.store.dispatch(action: .visibilityAction(.pipModeEntered))

            if turnCameraOffWhilePipIsStarting {
                turnCameraOffWhilePipIsStarting = false
                self.store.dispatch(action: .localUserAction(.cameraOnTriggered))
            }
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                           restoreUserInterfaceForPictureInPictureStopWithCompletionHandler
                                           completionHandler: @escaping (Bool) -> Void) {

        logger.debug("testpip: pip restoreUserInterfac")
//        guard let onAVKitPipTapped = onAVKitPipTapped else {
            completionHandler(true)
//            return
//        }
//        onAVKitPipTapped(completionHandler)
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                           failedToStartPictureInPictureWithError error: Error) {
        logger.error("pictureInPictureController " + error.localizedDescription)
    }
}
