//
//  TRLoader.m
//  test rss
//
//  Created by Mikhail Rakhmalevich on 12.06.14.
//  Copyright (c) 2014 Mikhail Rahmalevich. All rights reserved.
//

#import "AFNetworking.h"

#import "TRFeedsController.h"
#import "TRFeedParsingOperation.h"

@interface TRFeedsController ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, weak) id<TRFeedControllerDelegate> delegate;

@end


@implementation TRFeedsController

#pragma mark - Initialization
- (instancetype)initWithDelegate:(id<TRFeedControllerDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        self.queue = [NSOperationQueue new];
        [self.queue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
        
        [self addDefaultChannels];
    }
    return self;
}

- (void)dealloc {
    [self.queue cancelAllOperations];
}

#pragma mark - Public
- (void)refreshFeeds
{
    [self.queue cancelAllOperations];
    
    [self.delegate feedsControllerWillStardLoading:self];

    NSArray *channels = [Channel MR_findAll];
    for (Channel *channel in channels) {
        [self.queue addOperation:[self requestForChannel:channel]];
    }
}

- (BOOL)addFeedWithPath:(NSString *)path
{
    BOOL result = NO;
    if ([NSURL URLWithString:path]) {
        Channel *storedChannel = [Channel MR_findFirstByAttribute:@"link" withValue:path];
        if (!storedChannel) {
            storedChannel = [Channel MR_createEntity];
            storedChannel.link = path;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            if (self.queue.operationCount == 0) {
                [self.delegate feedsControllerWillStardLoading:self];
            }
            [self.queue addOperation:[self requestForChannel:storedChannel]];
        }
        result = YES;
    }
    return result;
}

#pragma mark - Private
- (void)addDefaultChannels
{
    NSArray *defaultChannels = @[@"http://feeds.feedburner.com/RayWenderlich",
                                 @"http://feeds.feedburner.com/vmwstudios",
                                 @"http://feeds.feedburner.com/macindie"];
    for (NSString *path in defaultChannels) {
        Channel *channel = [Channel MR_findFirstByAttribute:@"link" withValue:path];
        if (!channel) {
            channel = [Channel MR_createEntity];
            channel.link = path;
        }
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (NSOperation *)requestForChannel:(Channel *)channel
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:channel.link]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *responseObject){
        TRFeedParsingOperation *parsingOperation = [[TRFeedParsingOperation alloc] initWithData:responseObject channel:channel];
        [self.queue addOperation:parsingOperation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){}];
    return operation;
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:self.queue]) {
        if (self.queue.operationCount == 0) {
            [self.delegate feedsControllerDidEndLoading:self withError:nil];
        }
    }
}

@end
