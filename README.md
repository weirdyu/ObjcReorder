# ObjcReorder
ObjcReorder is a UITableView extension that lets you add long-press drag-and-drop reordering to any table view. It's robust, lightweight, and fully customizable.

Written in Objective-C, translated from [swift version](https://github.com/adamshin/SwiftReorder).

## Preview

![img](https://github.com/weirdyu/ObjcReorder/blob/master/demo.gif)

## Features

- Smooth animations
- Automatic edge scrolling
- Works with multiple table sections
- Customizable shadow, scaling, and transparency effects

## Usage

### Setup

- Add the following line to your table view setup.

```
- (void)setupSubviews
{
    //...
    tableView.reorder.delegate = self;
}
```

- Add this code to the beginning of your `- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath`.

```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *spacerCell = [tableView.reorder spacerCellForIndexPath:indexPath];
    if (spacerCell) {
        return spacerCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableviewCell" forIndexPath:indexPath];
    return cell;
}
```

- Implement the `- (void)tableView:(UITableView *)tableView reorderRowAtSource:(NSIndexPath *)source toDestination:(NSIndexPath *)destination` delegate method, and others as necessary.

```
- (void)tableView:(UITableView *)tableView reorderRowAtSource:(NSIndexPath *)source toDestination:(NSIndexPath *)destination
{
    // Update data model
}
```

This method is analogous to the `UITableViewDataSource` method `tableView(_:moveRowAt:to:)`. However, it may be called multiple times in the course of one drag-and-drop action.

### Customization

SwiftReorder exposes several properties for adjusting the style of the reordering effect. For example, you can add a scaling effect to the selected cell:

```
tableView.reorder.cellScale = 1.05
```

Or adjust the shadow:

```
tableView.reorder.shadowOpacity = 0.5
tableView.reorder.shadowRadius = 20
```
