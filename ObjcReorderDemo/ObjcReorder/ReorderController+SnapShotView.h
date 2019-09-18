//
//  ReorderController+SnapShotView.h
//  ObjcReorderDemo
//
//  Created by weirdyu on 2019/7/17.
//  Copyright © 2019 weirdyu. All rights reserved.
//

#import "ReorderController.h"

@interface ReorderController (SnapShotView)

- (void)createSnapshotViewForCell:(NSIndexPath *)indexPath;
- (void)removeSnapshotView;
- (void)updateSnapshotViewPosition;
- (void)animateSnapshotViewIn;
- (void)animateSnapshotViewOut;

@end
