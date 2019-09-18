//
//  ReorderController+GestureRecognizer.m
//  ObjcReorderDemo
//
//  Created by weirdyu on 2019/7/17.
//  Copyright © 2019 weirdyu. All rights reserved.
//

#import "ReorderController+GestureRecognizer.h"

@interface ReorderController () <UIGestureRecognizerDelegate>

@end

@implementation ReorderController (GestureRecognizer)

- (void)handleReorderGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.tableView) return;
    CGPoint touchPosition = [gestureRecognizer locationInView:self.tableView.superview];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self beginReorder:touchPosition];
            [self impactFeedback];
            break;
        case UIGestureRecognizerStateChanged:
            [self updateReorder:touchPosition];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            [self endReorder];
            [self impactFeedback];
            break;
        default:
            break;
    }
}

- (void)impactFeedback
{
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
        [generator prepare];
        [generator impactOccurred];
    }
}

#pragma mark - Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.tableView) return NO;
    CGPoint gestureLocation = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:gestureLocation];
    if (!indexPath) return NO;
    return [self.delegate tableView:self.tableView canReorderRowAtSource:indexPath];
}

@end





