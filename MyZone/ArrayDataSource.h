//
//  ArrayDataSource.h
//  Ratio
//
//  Created by Matthew Hillman on 11/12/13.
//  Copyright (c) 2013 Matthew Hillman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ConfigureCellBlock)(id cell, id item);

@interface ArrayDataSource : NSObject <UITableViewDataSource, UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *items;

- (id)initWithItems:(NSArray *)items
     cellIdentifier:(NSString *)cellIdentifier
 configureCellBlock:(ConfigureCellBlock)configureCellBlock;

- (void)configureForItems:(NSArray *)items cellIdentifier:(NSString *)cellIdentifier configureCellBlock:(ConfigureCellBlock)configureCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
