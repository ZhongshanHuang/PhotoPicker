//
//  PhotoBrowserTransitionAnimator.swift
//  HZSCustomTransition
//
//  Created by HzS on 16/4/6.
//  Copyright © 2016年 HzS. All rights reserved.
//

import UIKit

// MARK: - present专场动画协议
protocol PhotoBrowserPresentDelegate: class {
    
    // 对应的imageview
    func imageViewForPresent(indexPath: IndexPath) -> UIImageView
    
    // 起始位置
    func photoBrowserPresentFromRect(indexPath: IndexPath) -> CGRect
    
    // 目标位置
    func photoBrowserPresentToRect(indexPath: IndexPath) -> CGRect
}

// MARK: - dismiss专场动画协议
protocol PhotoBrowserDismissDelegate: class {
    
    // 对应的imageview
    func imageViewFromDismiss() -> UIImageView
    
    // imageView的indexPath
    func indexPathForDismiss() -> IndexPath
    
    // 起始位置
    func photoBrowserDismissFromRect() -> CGRect
}

class PhotoBrowserTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum TransitionType {
        case present
        case dismiss
    }
    
    private(set) var type: TransitionType = .present
    
    weak var presentDelegate: PhotoBrowserPresentDelegate?
    weak var dismissDelegate: PhotoBrowserDismissDelegate?
    var indexPath: IndexPath?
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView  = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view,
              let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else {
            return
        }
        let containerView = transitionContext.containerView
        
        
        if type == .present {
            containerView.addSubview(toView)
            guard let presentDelegate = presentDelegate else {
                fatalError("presentDelegate not nil")
            }
            
            if let indexPath = indexPath {
                toView.isHidden = true
                
                let back = UIView(frame: containerView.bounds)
                back.backgroundColor = .black
                back.alpha = 0.1
                containerView.addSubview(back)
                
                let imageView = presentDelegate.imageViewForPresent(indexPath: indexPath)
                imageView.frame = presentDelegate.photoBrowserPresentFromRect(indexPath: indexPath)
                containerView.addSubview(imageView)
                
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                    imageView.frame = presentDelegate.photoBrowserPresentToRect(indexPath: indexPath)
                    back.alpha = 1.0
                }, completion: { (finish) in
                    toView.isHidden = false
                    imageView.removeFromSuperview()
                    back.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            } else {
                let transition = containerView.bounds.width
                toView.transform = CGAffineTransform.identity.translatedBy(x: transition, y: 0)
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                    toView.transform = .identity
                    fromView.transform = CGAffineTransform.identity.translatedBy(x: -transition, y: 0)
                }, completion: { (finish) in
                    fromView.transform = .identity
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            }
            
        } else if type == .dismiss {
            fromView.isHidden = true
            guard let dismissDelegate = dismissDelegate else {
                fatalError("dismissDelegate not nil")
            }
            
            let back = UIView(frame: containerView.bounds)
            back.backgroundColor = .black
            back.alpha = fromView.backgroundColor?.cgColor.alpha ?? 1.0
            containerView.addSubview(back)
            
            let imageView = dismissDelegate.imageViewFromDismiss()
            imageView.frame = dismissDelegate.photoBrowserDismissFromRect()
            containerView.addSubview(imageView)
            
            let indexPath = dismissDelegate.indexPathForDismiss()
            var dismissToFrame = presentDelegate!.photoBrowserPresentFromRect(indexPath: indexPath)
            if dismissToFrame.origin.x.isNaN { // 消失在中间
                let dismissX = (containerView.bounds.width - dismissToFrame.width) / 2
                let dismissY = (containerView.bounds.height - dismissToFrame.height) / 2
                dismissToFrame = CGRect(origin: CGPoint(x: dismissX, y: dismissY), size: dismissToFrame.size)
            }
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                back.alpha = 0.1
                imageView.frame = dismissToFrame
            }, completion: { (finish) in
                imageView.removeFromSuperview()
                back.removeFromSuperview()
                if !transitionContext.transitionWasCancelled {
                    fromView.removeFromSuperview()
                    self.indexPath = nil
                } else {
                    fromView.isHidden = false
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

extension PhotoBrowserTransitionAnimator: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        type = .present
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        type = .dismiss
        return self
    }

}
