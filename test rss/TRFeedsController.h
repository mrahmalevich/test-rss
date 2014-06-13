//
//  TRLoader.h
//  test rss
//
//  Created by Mikhail Rakhmalevich on 12.06.14.
//  Copyright (c) 2014 Mikhail Rahmalevich. All rights reserved.
//

@class TRFeedsController;
@protocol TRFeedControllerDelegate <NSObject>

- (void)feedsControllerWillStardLoading:(TRFeedsController *)controller;
- (void)feedsControllerDidEndLoading:(TRFeedsController *)controller withError:(NSError *)error;

@end

@interface TRFeedsController : NSObject

- (instancetype)initWithDelegate:(id<TRFeedControllerDelegate>)delegate;
- (void)refreshFeeds;
- (BOOL)addFeedWithPath:(NSString *)path;

@end
