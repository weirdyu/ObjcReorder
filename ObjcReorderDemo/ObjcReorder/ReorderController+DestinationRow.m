//
//  ReorderController+DestinationRow.m
//  ObjcReorderDemo
//
//  Created by weirdyu on 2019/7/17.
//  Copyright © 2019 weirdyu. All rights reserved.
//

#import "ReorderController+DestinationRow.h"
#import "ReorderController+GestureRecognizer.h"

@implementation ReorderController (DestinationRow)

- (void)updateDestinationRow
{
    if (self.reorderState.reorderStateType != ReorderStateTypeReordering) return;
    
    NSIndexPath *proposedNewDestinationRow = [self proposedNewDestinationRow];
    NSIndexPath *newDestinationRow = [self.delegate tableView:self.tableView targetIndexPathForReorderFromRowAtSource:self.reorderState.context.destinationRow toProposedDestinationIndexPath:proposedNewDestinationRow];
    if (newDestinationRow == self.reorderState.context.destinationRow) return;
    
    NSIndexPath *oldDestinationRow = self.reorderState.context.destinationRow;
    self.reorderState.context.destinationRow = newDestinationRow;
    
    [self.delegate tableView:self.tableView reorderRowAtSource:oldDestinationRow toDestination:self.reorderState.context.destinationRow];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[oldDestinationRow] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:@[self.reorderState.context.destinationRow] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    if (oldDestinationRow != self.reorderState.context.destinationRow) {
        [self impactFeedback];
    }
}

- (NSIndexPath *)proposedNewDestinationRow
{
    if (self.reorderState.reorderStateType != ReorderStateTypeReordering) return nil;
    UIView *superview = self.tableView.superview;
    UIView *tableview = self.tableView;
    
    CGRect snapshotFrameInSuperview = [self rectWithCenter:self.snapshotView.center size:self.snapshotView.bounds.size];
    CGRect snapshotFrame = [superview convertRect:snapshotFrameInSuperview toView:tableview];
    
    NSMutableArray *visibleCells = [NSMutableArray array];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        // Workaround for an iOS 11 bug.
        // When adding a row using UITableView.insertRows(...), if the new
        // row's frame will be partially or fully outside the table view's
        // bounds, and the new row is not the first row in the table view,
        // it's inserted without animation.
        BOOL cellOverlapsTopBounds = CGRectGetMinY(cell.frame) < CGRectGetMinY(self.tableView.bounds) + 5;
        BOOL cellIsFirstCell = [[self.tableView indexPathForCell:cell] isEqual:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (!cellOverlapsTopBounds || cellIsFirstCell) {
            [visibleCells addObject:cell];
        }
    }

    NSMutableArray *rowSnapDistances = [NSMutableArray array];
    for (UITableViewCell *cell in visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell] ? : [NSIndexPath indexPathForRow:0 inSection:0];
        SnapDistance *rowSnapDistance = [SnapDistance new];
        if ([self.reorderState.context.destinationRow compare:indexPath] == NSOrderedAscending) {
            rowSnapDistance.indexPath = indexPath;
            rowSnapDistance.distance = abs(CGRectGetMaxY(snapshotFrame)-CGRectGetMaxY(cell.frame));
        }else {
            rowSnapDistance.indexPath = indexPath;
            rowSnapDistance.distance = abs(CGRectGetMinY(snapshotFrame)-CGRectGetMinY(cell.frame));
        }
        [rowSnapDistances addObject:rowSnapDistance];
    }

    NSMutableArray *sectionSnapDistances = [NSMutableArray array];
    for (int section = 0; section < self.tableView.numberOfSections; section++) {
        NSInteger rowInSection = [self.tableView numberOfRowsInSection:section];
        SnapDistance *sectionSnapDistance = [SnapDistance new];
        if (section > self.reorderState.context.destinationRow.section) {
            CGRect rect;
            if (rowInSection == 0) {
                rect = [self rectForEmptySection:section];
            }else {
                rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            }
            sectionSnapDistance.indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
            sectionSnapDistance.distance = abs(CGRectGetMaxY(snapshotFrame) - CGRectGetMinY(rect));
            [sectionSnapDistances addObject:sectionSnapDistance];
        }else if (section < self.reorderState.context.destinationRow.section) {
            CGRect rect;
            if (rowInSection == 0) {
                rect = [self rectForEmptySection:section];
            }else {
                rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:rowInSection-1 inSection:section]];
            }
            sectionSnapDistance.indexPath = [NSIndexPath indexPathForRow:rowInSection inSection:section];
            sectionSnapDistance.distance = abs(CGRectGetMinY(snapshotFrame) - CGRectGetMaxY(rect));
            [sectionSnapDistances addObject:sectionSnapDistance];
        }
    }
    
    NSMutableArray *snapDistances = [NSMutableArray array];
    [snapDistances addObjectsFromArray:rowSnapDistances];
    [snapDistances addObjectsFromArray:sectionSnapDistances];
    SnapDistance *minDistance = snapDistances.firstObject;
    for (SnapDistance *snapDistance in snapDistances) {
        if (snapDistance.distance < minDistance.distance) {
            minDistance = snapDistance;
        }
    }
    return minDistance.indexPath;
}

- (CGRect)rectForEmptySection:(NSInteger)section
{
    if (!self.tableView) return CGRectZero;
    
    CGRect sectionRect = [self.tableView rectForHeaderInSection:section];
    return UIEdgeInsetsInsetRect(sectionRect, UIEdgeInsetsMake(sectionRect.size.height, 0, 0, 0));
}

#pragma mark - Private Method

- (CGRect)rectWithCenter:(CGPoint)center size:(CGSize)size
{
    CGRect rect = CGRectMake(center.x - (size.width / 2), center.y - (size.height / 2), size.width, size.height);
    return rect;
}

@end
