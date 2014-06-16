//
//  FetchedResultsDataSource.h
//  MyZone
//
//  Created by Matthew Hillman on 4/2/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

typedef void (^ConfigureCellBlock)(id cell, id item);

@interface FetchedResultsDataSource : NSObject <UITableViewDataSource>
@property (assign, nonatomic) BOOL showSectionIndex;

@property (weak, nonatomic) UITableViewController *delegate;
- (void)configureForFetchRequest:(NSFetchRequest *)fetchRequest
                       inContext:(NSManagedObjectContext *)context
          withSectionNameKeyPath:(NSString *)sectionNameKeyPath
                  cellIdentifier:(NSString *)cellIdentifier
              configureCellBlock:(ConfigureCellBlock)configureCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
