//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class RightToLeftTransition: NSObject, UIViewControllerAnimatedTransitioning {

    private let duration: TimeInterval = 0.25

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        let toFinalFrame = transitionContext.finalFrame(for: toView)

        let toViewOff = toFinalFrame.offsetBy(dx: toFinalFrame.width, dy: 0)
        toView.view.frame = toViewOff

        transitionContext.containerView.insertSubview(toView.view, aboveSubview: fromView.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                toView.view.frame = toFinalFrame
            }, completion: {_ in
                transitionContext.completeTransition(true)
            })
    }
}
