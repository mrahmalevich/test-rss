//
//  Channel.h
//  test rss
//
//  Created by Mikhail Rakhmalevich on 12.06.14.
//  Copyright (c) 2014 Mikhail Rahmalevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Channel : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSSet *items;
@end

@interface Channel (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
