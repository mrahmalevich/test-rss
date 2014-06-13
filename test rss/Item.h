//
//  Item.h
//  test rss
//
//  Created by Mikhail Rakhmalevich on 13.06.14.
//  Copyright (c) 2014 Mikhail Rahmalevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) Channel *channel;

@end
