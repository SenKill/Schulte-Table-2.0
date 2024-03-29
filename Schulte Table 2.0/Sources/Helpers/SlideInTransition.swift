//
//  SlideInTransition.swift
//  Schulte Table 2.0
//
//  Created by SenKill on 8/6/21.
//  Copyright © 2021 SenKill. All rights reserved.
//

import UIKit

final class SlideInTransition: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: - Public vars
    var isPresenting = false
    let dimmingView = UIView()
    
    // MARK: - Private vars
    private weak var targetViewController: UIViewController?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        
        let containerView = transitionContext.containerView
        let finalWidth = toViewController.view.bounds.width * 0.65
        let finalHeigth = toViewController.view.bounds.height
        
        if isPresenting {
            dimmingView.backgroundColor = .black
            dimmingView.alpha = 0.0
            containerView.addSubview(dimmingView)
            dimmingView.frame = containerView.bounds
            // Add menu view controller to container
            containerView.addSubview(toViewController.view)
            
            // Init frame off the screen
            toViewController.view.frame = CGRect(x: -finalWidth, y: 0, width: finalWidth, height: finalHeigth)
        }
        
        // Animate on screen
        let transform = {
            self.dimmingView.alpha = 0.3
            toViewController.view.transform = CGAffineTransform(translationX: finalWidth, y: 0)
        }
        
        //Animate back off screen
        let identity = {
            self.dimmingView.alpha = 0.0
            fromViewController.view.transform = .identity
        }
        
        // Animation of the transition
        let duration = transitionDuration(using: transitionContext)
        let isCancelled = transitionContext.transitionWasCancelled
        UIView.animate(withDuration: duration, animations: {
            self.isPresenting ? transform() : identity()
        }) { (_) in
            transitionContext.completeTransition(!isCancelled)
        }
        targetViewController = toViewController
        configureSwipeGesRec(for: containerView)
    }
    
}

// MARK: - Internal
private extension SlideInTransition {
    func configureSwipeGesRec(for view: UIView) {
        let swipeGesRec = UISwipeGestureRecognizer(target: self, action: #selector(testGesRec))
        swipeGesRec.direction = .left
        view.addGestureRecognizer(swipeGesRec)
    }
    
    @objc func testGesRec(_ sender: UISwipeGestureRecognizer) {
        guard sender.direction == .left else { return }
        targetViewController?.dismiss(animated: true)
    }
}
