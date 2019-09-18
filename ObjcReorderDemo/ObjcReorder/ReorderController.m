//
//  ReorderController.m
//  ObjcReorderDemo
//
//  Created by weirdyu on 2019/7/17.
//  Copyright © 2019 weirdyu. All rights reserved.
//

#import "ReorderController.h"
#import "ReorderController+SnapShotView.h"
#import "ReorderController+DestinationRow.h"
#import "ReorderController+AutoScroll.h"
#import "ReorderController+GestureRecognizer.h"

@interface ReorderController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *reorderGestureRecognizer;

@end

@implementation ReorderController

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        [self setupConfig];
        [tableView addGestureRecognizer:self.reorderGestureRecognizer];
        self.tableView = tableView;
        
        ReorderState *reorderState = [ReorderState new];
        [reorderState setupStateType:ReorderStateTypeReady snapshotRow:nil];
        self.reorderState = reorderState;
    }
    return self;
}

- (void)setupConfig
{
    self.isEnabled = YES;
    self.longPressDuration = 0.3;
    self.cancelsTouchesInView = NO;
    self.animationDuration = 0.2;
    self.cellOpacity = 1;
    self.cellScale = 1;
    self.shadowColor = [UIColor blackColor];
    self.shadowOpacity = 0.3;
    self.shadowRadius = 10;
    self.shadowOffset = CGSizeMake(0, 3);
    self.spacerCellStyle = ReorderSpacerCellStyleAutomic;
    self.autoScrollEnabled = YES;
    
    ReorderState *reorderState = [ReorderState new];
    [reorderState setupStateType:ReorderStateTypeReady snapshotRow:nil];
    self.reorderState = reorderState;
}

- (void)setIsEnabled:(BOOL)isEnabled
{
    [self.reorderGestureRecognizer setEnabled:isEnabled];
}

- (void)setLongPressDuration:(NSTimeInterval)longPressDuration
{
    [self.reorderGestureRecognizer setMinimumPressDuration:longPressDuration];
}

- (void)setCancelsTouchesInView:(BOOL)cancelsTouchesInView
{
    [self.reorderGestureRecognizer setCancelsTouchesInView:cancelsTouchesInView];
}

- (UILongPressGestureRecognizer *)reorderGestureRecognizer
{
    if (!_reorderGestureRecognizer) {
        _reorderGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleReorderGesture:)];
        _reorderGestureRecognizer.delegate = self;
        _reorderGestureRecognizer.minimumPressDuration = self.longPressDuration;
    }
    return _reorderGestureRecognizer;
}

#pragma mark - Public Method

- (UITableViewCell *)spacerCellForIndexPath:(NSIndexPath *)indexPath
{
    if (self.reorderState.reorderStateType == ReorderStateTypeReordering && indexPath == self.reorderState.context.destinationRow) {
        return [self createSpacerCell];
    }else if (self.reorderState.reorderStateType == ReorderStateTypeReady && indexPath == self.reorderState.snapshotRow) {
        return [self createSpacerCell];
    }
    return nil;
}

#pragma mark - Reordering

- (void)beginReorder:(CGPoint)touchPosition
{
    if (self.reorderState.reorderStateType != ReorderStateTypeReady) return;
    
    UIView *superview = self.tableView.superview;
    CGPoint tableTouchPosition = [superview convertPoint:touchPosition toView:self.tableView];
    NSIndexPath *sourceRow = [self.tableView indexPathForRowAtPoint:tableTouchPosition];
    BOOL canReorder = [self.delegate tableView:self.tableView canReorderRowAtSource:sourceRow];
    if (!canReorder) return;

    [self createSnapshotViewForCell:sourceRow];
    [self animateSnapshotViewIn];
    [self activateAutoScrollDisplayLink];
    [self.tableView reloadData];

    CGFloat snapshotOffset = (self.snapshotView.center.y?:0) - touchPosition.y;
    ReorderStateContext *context = [ReorderStateContext new];
    context.sourceRow = sourceRow;
    context.destinationRow = sourceRow;
    context.snapshotOffset = snapshotOffset;
    context.touchPosition = touchPosition;
    [self.reorderState setupStateType:ReorderStateTypeReordering context:context];

    if ([self.delegate respondsToSelector:@selector(tableView:didBeginReorderingAtSource:)]) {    
        [self.delegate tableView:self.tableView didBeginReorderingAtSource:sourceRow];
    }
}

- (void)updateReorder:(CGPoint)touchPosition
{
    if (self.reorderState.reorderStateType != ReorderStateTypeReordering) return;
    self.reorderState.context.touchPosition = touchPosition;
    
    [self updateSnapshotViewPosition];
    [self updateDestinationRow];
}

- (void)endReorder
{
    if (self.reorderState.reorderStateType != ReorderStateTypeReordering) return;
    [self.reorderState setupStateType:ReorderStateTypeReady snapshotRow:self.reorderState.context.destinationRow];
    
    CGRect cellRectInTableView = [self.tableView rectForRowAtIndexPath:self.reorderState.snapshotRow];
    CGRect cellRect = [self.tableView convertRect:cellRectInTableView toView:self.tableView.superview];
    CGPoint cellRectCenter = CGPointMake(CGRectGetMidX(cellRect), CGRectGetMidY(cellRect));
    // If no values change inside a UIView animation block, the completion handler is called immediately.
    // This is a workaround for that case.
    if (CGPointEqualToPoint(self.snapshotView.center, cellRectCenter)) {
        self.snapshotView.center = CGPointMake(self.snapshotView.center.x, self.snapshotView.center.y+0.1);
    }
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.snapshotView.center = CGPointMake(CGRectGetMidX(cellRect), CGRectGetMidY(cellRect));
    } completion:^(BOOL finished) {
        if (self.reorderState.reorderStateType == ReorderStateTypeReady) {
            NSIndexPath *row = self.reorderState.snapshotRow;
            [self.reorderState setupStateType:ReorderStateTypeReady snapshotRow:nil];
            [UIView performWithoutAnimation:^{
                [self.tableView reloadRowsAtIndexPaths:@[row] withRowAnimation:UITableViewRowAnimationNone];
            }];
            [self removeSnapshotView];
        }
    }];
    
    [self animateSnapshotViewOut];
    [self clearAutoScrollDisplayLink];
    
    if ([self.delegate respondsToSelector:@selector(tableView:didFinishReorderingAtSource:toFinalDestinationIndexPath:)]) {    
        [self.delegate tableView:self.tableView didFinishReorderingAtSource:self.reorderState.context.sourceRow toFinalDestinationIndexPath:self.reorderState.context.destinationRow];
    }
}

#pragma mark - Private Method

- (UITableViewCell *)createSpacerCell
{
    if (!self.snapshotView) return nil;
    UITableViewCell *cell = [UITableViewCell new];
    CGFloat height = self.snapshotView.bounds.size.height;

    [NSLayoutConstraint constraintWithItem:cell attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:height].active = YES;
    
    BOOL hideCell;
    switch (_spacerCellStyle) {
        case ReorderSpacerCellStyleAutomic:
            hideCell = self.tableView.style == UITableViewStyleGrouped;
            break;
        case ReorderSpacerCellStyleHidden:
            hideCell = YES;
            break;
        case ReorderSpacerCellStyleTransparent:
            hideCell = NO;
            break;
        default:
            break;
    }

    if (hideCell) {
        [cell setHidden:YES];
    }else {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

@end





////////////////////////////////////////////////////////////////
//MARK:-
//MARK:ReorderStateContext
//MARK:-
////////////////////////////////////////////////////////////////


@implementation ReorderStateContext


@end


@implementation ReorderState

- (void)setupStateType:(ReorderStateType)type snapshotRow:(NSIndexPath *)row
{
    self.reorderStateType = type;
    self.context = nil;
    self.snapshotRow = row;
}

- (void)setupStateType:(ReorderStateType)type context:(ReorderStateContext *)context
{
    self.reorderStateType = type;
    self.context = context;
    self.snapshotRow = nil;
}

@end


@implementation SnapDistance


@end
