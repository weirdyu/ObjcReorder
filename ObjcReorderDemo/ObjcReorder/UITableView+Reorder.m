//
//  UITableView+Reorder.m
//  ObjcReorderDemo
//
//  Created by weirdyu on 2019/7/17.
//  Copyright © 2019 weirdyu. All rights reserved.
//

#import "UITableView+Reorder.h"
#import <objc/runtime.h>

static const NSString * ReorderControllerKey = @"ReorderControllerKey";

@implementation UITableView (Reorder)
@dynamic reorder;

- (ReorderController *)reorder
{
    //  iOS 11 bugfix
    if (@available(iOS 11, *)) self.estimatedRowHeight = 0;

    ReorderController *controller = objc_getAssociatedObject(self, &ReorderControllerKey);
    if (controller == nil) {
        controller = [[ReorderController alloc] initWithTableView:self];
        objc_setAssociatedObject(self, &ReorderControllerKey, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return controller;
}

#pragma mark - Delegate


@end
