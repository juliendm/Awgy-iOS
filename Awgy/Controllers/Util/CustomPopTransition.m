#import "CustomPopTransition.h"
//#import "DetailsViewController.h"
//#import "GroupSelfieViewController.h"

@implementation CustomPopTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toViewController.view];
    [containerView bringSubviewToFront:fromViewController.view];
    
    // Setup the initial view states
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        fromViewController.view.frame = CGRectMake(toViewController.view.frame.size.width, fromViewController.view.frame.origin.y, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        // Declare that we've finished
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
    
}

@end