//
//  ReorderController+SnapShotView.m
//  ObjcReorderDemo
//
//  Created by weirdyu on 2019/7/17.
//  Copyright © 2019 weirdyu. All rights reserved.
//

#import "ReorderController+SnapShotView.h"

@implementation ReorderController (SnapShotView)

- (void)createSnapshotViewForCell:(NSIndexPath *)indexPath
{
    if (!self.tableView) return;
    [self removeSnapshotView];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell) return;
    CGRect cellFrame = [self.tableView convertRect:cell.frame toView:self.tableView.superview];
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIView *view = [[UIImageView alloc] initWithImage:cellImage];
    view.frame = cellFrame;
    view.layer.masksToBounds = false;
    view.layer.opacity = self.cellOpacity;
    view.layer.transform = CATransform3DMakeScale(self.cellScale, self.cellScale, 1);
    view.layer.shadowColor = self.shadowColor.CGColor;
    view.layer.shadowOpacity = self.shadowOpacity;
    view.layer.shadowRadius = self.shadowRadius;
    view.layer.shadowOffset = self.shadowOffset;
    [self.tableView.superview addSubview:view];
    self.snapshotView = view;
}

- (void)removeSnapshotView
{
    [self.snapshotView removeFromSuperview];
    self.snapshotView = nil;
}

- (void)updateSnapshotViewPosition
{
    if (self.reorderState.reorderStateType == ReorderStateTypeReordering && self.tableView) {
        CGFloat newCenterY = self.reorderState.context.touchPosition.y + self.reorderState.context.snapshotOffset;
        CGRect safeAreaFrame;
         if (@available(iOS 11, *)) {
             safeAreaFrame = UIEdgeInsetsInsetRect(self.tableView.frame, self.tableView.safeAreaInsets);
        } else {
            safeAreaFrame = UIEdgeInsetsInsetRect(self.tableView.frame, self.tableView.scrollIndicatorInsets);
        }
        newCenterY = MIN(newCenterY, CGRectGetMaxY(safeAreaFrame));
        newCenterY = MAX(newCenterY, CGRectGetMinY(safeAreaFrame));
        self.snapshotView.center = CGPointMake(self.snapshotView.center.x, newCenterY);
    }
}

- (void)animateSnapshotViewIn
{
    if (!self.snapshotView) return;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation new];
    opacityAnimation.keyPath = @"opacity";
    opacityAnimation.fromValue = @(1);
    opacityAnimation.toValue = @(self.cellOpacity);
    opacityAnimation.duration = self.animationDuration;
    
    CABasicAnimation *shadowAnimation = [CABasicAnimation new];
    shadowAnimation.keyPath = @"shadowOpacity";
    shadowAnimation.fromValue = @(0);
    shadowAnimation.toValue = @(self.shadowOpacity);
    shadowAnimation.duration = self.animationDuration;
    
    CABasicAnimation *transformAnimation = [CABasicAnimation new];
    transformAnimation.keyPath = @"transform.scale";
    transformAnimation.fromValue = @(1);
    transformAnimation.toValue = @(self.cellScale);
    transformAnimation.duration = self.animationDuration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.snapshotView.layer addAnimation:opacityAnimation forKey:nil];
    [self.snapshotView.layer addAnimation:shadowAnimation forKey:nil];
    [self.snapshotView.layer addAnimation:transformAnimation forKey:nil];
}

- (void)animateSnapshotViewOut
{
    if (!self.snapshotView) return;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation new];
    opacityAnimation.keyPath = @"opacity";
    opacityAnimation.fromValue = @(self.cellOpacity);
    opacityAnimation.toValue = @(1);
    opacityAnimation.duration = self.animationDuration;
    
    CABasicAnimation *shadowAnimation = [CABasicAnimation new];
    shadowAnimation.keyPath = @"shadowOpacity";
    shadowAnimation.fromValue = @(self.shadowOpacity);
    shadowAnimation.toValue = @(0);
    shadowAnimation.duration = self.animationDuration;
    
    CABasicAnimation *transformAnimation = [CABasicAnimation new];
    transformAnimation.keyPath = @"transform.scale";
    transformAnimation.fromValue = @(self.cellScale);
    transformAnimation.toValue = @(1);
    transformAnimation.duration = self.animationDuration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.snapshotView.layer addAnimation:opacityAnimation forKey:nil];
    [self.snapshotView.layer addAnimation:shadowAnimation forKey:nil];
    [self.snapshotView.layer addAnimation:transformAnimation forKey:nil];
    
    self.snapshotView.layer.opacity = 1;
    self.snapshotView.layer.shadowOpacity = 0;
    self.snapshotView.layer.transform = CATransform3DIdentity;
}

@end
