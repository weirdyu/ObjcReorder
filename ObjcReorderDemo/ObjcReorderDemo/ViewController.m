//
//  ViewController.m
//  ObjcReorderDemo
//
//  Created by weirdyu on 2019/9/18.
//  Copyright © 2019 weirdyu. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "ObjcReorder.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, TableViewReorderDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"ObjcReorderDemo";
    [self setupDataSource];
    [self setupSubviews];
}

- (void)setupDataSource
{
    NSArray *array = @[@"Item 1", @"Item 2", @"Item 3", @"Item 4", @"Item 5", @"Item 6", @"Item 7", @"Item 8"];
    _dataSource = [NSMutableArray arrayWithArray:array];
}

- (void)setupSubviews
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.reorder.delegate = self;
    tableView.tableFooterView = [UIView new];
    tableView.rowHeight = 60;
    tableView.allowsMultipleSelection = YES;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableviewCell"];
    [self.view addSubview:tableView];
    _tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

#pragma mark - UITableViewDataSource/UITableViewDelegate

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *spacerCell = [tableView.reorder spacerCellForIndexPath:indexPath];
    if (spacerCell) {
        return spacerCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableviewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TableViewReorderDelegate

- (void)tableView:(UITableView *)tableView reorderRowAtSource:(NSIndexPath *)source toDestination:(NSIndexPath *)destination
{
    NSString *item = _dataSource[source.row];
    [_dataSource removeObject:item];
    [_dataSource insertObject:item atIndex:destination.row];
}

- (BOOL)tableView:(UITableView *)tableView canReorderRowAtSource:(NSIndexPath *)source
{
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForReorderFromRowAtSource:(NSIndexPath *)source toProposedDestinationIndexPath:(NSIndexPath *)destination
{
    return destination;
}

@end
