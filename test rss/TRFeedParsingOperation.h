//
//  TRFeedSerializer.h
//  test rss
//
//  Created by Mikhail Rakhmalevich on 12.06.14.
//  Copyright (c) 2014 Mikhail Rahmalevich. All rights reserved.
//

@interface TRFeedParsingOperation : NSOperation

- (instancetype)initWithData:(NSData *)data channel:(Channel *)channel;

@end
