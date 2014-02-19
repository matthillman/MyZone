//
//  ArrayDataSource.m
//  Ratio
//
//  Created by Matthew Hillman on 11/12/13.
//  Copyright (c) 2013 Matthew Hillman. All rights reserved.
//

#import "ArrayDataSource.h"

@interface ArrayDataSource ()

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) ConfigureCellBlock configureCellBlock;

@end


@implementation ArrayDataSource

- (id)initWithItems:(NSArray *)items
     cellIdentifier:(NSString *)cellIdentifier
 configureCellBlock:(ConfigureCellBlock)configureCellBlock
{
    self = [super init];
    if (self) {
        self.items = items;
        self.cellIdentifier = cellIdentifier;
        self.configureCellBlock = [configureCellBlock copy];
    }
    return self;
}

- (void)configureForItems:(NSArray *)items cellIdentifier:(NSString *)cellIdentifier configureCellBlock:(ConfigureCellBlock)configureCellBlock
{
    self.items = items;
    self.cellIdentifier = cellIdentifier;
    self.configureCellBlock = configureCellBlock;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.items[(NSUInteger) indexPath.row];
}

- (NSArray *)items
{
    if (!_items) return @[];
    
    return _items;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell, item);
    return cell;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell, item);
    return cell;
}

@end
