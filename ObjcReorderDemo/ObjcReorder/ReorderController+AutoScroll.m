//
//  ReorderController+AutoScroll.m
//  ObjcReorderDemo
//
//  Created by weirdyu on 2019/7/17.
//  Copyright © 2019 weirdyu. All rights reserved.
//

#import "ReorderController+AutoScroll.h"
#import "ReorderController+SnapShotView.h"
#import "ReorderController+DestinationRow.h"

static CGFloat const autoScrollThreshold = 30;
static CGFloat const autoScrollMinVelocity = 60;
static CGFloat const autoScrollMaxVelocity = 280;

@implementation ReorderController (AutoScroll)

- (CGFloat)autoScrollVelocity
{
    if (!self.tableView || !self.snapshotView) {
        return 0;
    }
    if (!self.autoScrollEnabled) return 0;
    
    CGRect safeAreaFrame;
    if (@available(iOS 11, *)) {
        safeAreaFrame = UIEdgeInsetsInsetRect(self.tableView.frame, self.tableView.adjustedContentInset);
    } else {
        safeAreaFrame = UIEdgeInsetsInsetRect(self.tableView.frame, self.tableView.scrollIndicatorInsets);
    }
    
    CGFloat distanceToTop = MAX(CGRectGetMinY(self.snapshotView.frame) - CGRectGetMinY(safeAreaFrame), 0);
    CGFloat distanceToBottom = MAX(CGRectGetMaxY(safeAreaFrame) - CGRectGetMaxY(self.snapshotView.frame), 0);
    if (distanceToTop < autoScrollThreshold) {
        return [self mapValue:distanceToTop inRangeWithMin:autoScrollThreshold max:0 toRangeWithMin:-autoScrollMinVelocity max:-autoScrollMaxVelocity];
    }
    if (distanceToBottom < autoScrollThreshold) {
       return [self mapValue:distanceToBottom inRangeWithMin:autoScrollThreshold max:0 toRangeWithMin:autoScrollMinVelocity max:autoScrollMaxVelocity];
    }
    return 0;
}


- (void)activateAutoScrollDisplayLink
{
    self.autoScrollDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLinkUpdate:)];
    [self.autoScrollDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.lastAutoScrollTimeStamp = 0;
}

- (void)clearAutoScrollDisplayLink
{
    [self.autoScrollDisplayLink invalidate];
    self.autoScrollDisplayLink = nil;
    self.lastAutoScrollTimeStamp = 0;
}

- (void)handleDisplayLinkUpdate:(CADisplayLink *)displayLink
{
    if (!self.tableView) return;
    
    if (self.lastAutoScrollTimeStamp) {
        CGFloat scrollVelocity = [self autoScrollVelocity];
        if (scrollVelocity != 0) {
            CGFloat elapsedTime = displayLink.timestamp - self.lastAutoScrollTimeStamp;
            CGFloat scrollDelta = elapsedTime * scrollVelocity;
            
            CGPoint contentOffset = self.tableView.contentOffset;
            self.tableView.contentOffset = CGPointMake(contentOffset.x, contentOffset.y + scrollDelta);
            
            UIEdgeInsets contentInset;
            if (@available(iOS 11, *)) {
                contentInset = self.tableView.adjustedContentInset;
            } else {
                contentInset = self.tableView.contentInset;
            }
            
            CGFloat minContentOffset = -contentInset.top;
            CGFloat maxContentOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height + contentInset.bottom;
            
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, MIN(self.tableView.contentOffset.y, maxContentOffset));
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, MAX(self.tableView.contentOffset.y, minContentOffset));
            
            [self updateSnapshotViewPosition];
            [self updateDestinationRow];
        }
    }
    self.lastAutoScrollTimeStamp = displayLink.timestamp;
}

#pragma mark - Private Method

- (CGFloat)mapValue:(CGFloat)value inRangeWithMin:(CGFloat)minA max:(CGFloat)maxA toRangeWithMin:(CGFloat)minB max:(CGFloat)maxB
{
    return (value - minA) * (maxB - minB) / (maxA - minA) + minB;
}

@end
