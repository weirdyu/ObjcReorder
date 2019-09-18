//
//  ReorderController.h
//  ObjcReorderDemo
//
//  Created by weirdyu on 2019/7/17.
//  Copyright © 2019 weirdyu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ReorderStateType) {
    ReorderStateTypeReady,
    ReorderStateTypeReordering
};

typedef NS_ENUM(NSInteger, ReorderSpacerCellStyle) {
    ReorderSpacerCellStyleAutomic,
    ReorderSpacerCellStyleHidden,
    ReorderSpacerCellStyleTransparent
};

@protocol TableViewReorderDelegate <NSObject>

@required
- (void)tableView:(UITableView *)tableView reorderRowAtSource:(NSIndexPath *)source toDestination:(NSIndexPath *)destination;

- (BOOL)tableView:(UITableView *)tableView canReorderRowAtSource:(NSIndexPath *)source;

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForReorderFromRowAtSource:(NSIndexPath *)source toProposedDestinationIndexPath:(NSIndexPath *)destination;

@optional
- (void)tableView:(UITableView *)tableView didBeginReorderingAtSource:(NSIndexPath *)source;

- (void)tableView:(UITableView *)tableView didFinishReorderingAtSource:(NSIndexPath *)source toFinalDestinationIndexPath:(NSIndexPath *)indexPath;

@end


@interface ReorderStateContext :NSObject

@property (nonatomic, strong)  NSIndexPath *sourceRow;
@property (nonatomic, strong)  NSIndexPath *destinationRow;
@property (nonatomic, assign)  CGFloat snapshotOffset;
@property (nonatomic, assign)  CGPoint touchPosition;

@end


@interface ReorderState : NSObject

@property (nonatomic, assign) ReorderStateType reorderStateType;
@property (nonatomic, strong) ReorderStateContext *context;
@property (nonatomic, strong) NSIndexPath *snapshotRow;

- (void)setupStateType:(ReorderStateType)type snapshotRow:(NSIndexPath *)row;
- (void)setupStateType:(ReorderStateType)type context:(ReorderStateContext *)context;

@end


////////////////////////////////////////////////////////////////
//MARK:-
//MARK:ReorderController
//MARK:-
////////////////////////////////////////////////////////////////


@interface ReorderController : NSObject

@property (nonatomic, weak) id <TableViewReorderDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) NSTimeInterval longPressDuration;
@property (nonatomic, assign) BOOL cancelsTouchesInView;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) CGFloat cellOpacity;
@property (nonatomic, assign) CGFloat cellScale;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGFloat shadowOpacity;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) ReorderSpacerCellStyle spacerCellStyle;
@property (nonatomic, assign) BOOL autoScrollEnabled;

@property (nonatomic, strong) UIView *snapshotView;

@property (nonatomic, strong) ReorderState *reorderState;

@property (nonatomic, strong) CADisplayLink *autoScrollDisplayLink;
@property (nonatomic, assign) CFTimeInterval lastAutoScrollTimeStamp;



- (instancetype)initWithTableView:(UITableView *)tableView;

- (UITableViewCell *)spacerCellForIndexPath:(NSIndexPath *)indexPath;

- (void)beginReorder:(CGPoint)touchPosition;
- (void)updateReorder:(CGPoint)touchPosition;
- (void)endReorder;

@end



@interface SnapDistance : NSObject

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) CGFloat distance;

@end


