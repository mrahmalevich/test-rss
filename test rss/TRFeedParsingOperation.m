//
//  TRFeedSerializer.m
//  test rss
//
//  Created by Mikhail Rakhmalevich on 12.06.14.
//  Copyright (c) 2014 Mikhail Rahmalevich. All rights reserved.
//

#import "TRFeedParsingOperation.h"

@interface TRFeedParsingOperation () <NSXMLParserDelegate>

+ (NSDateFormatter *)sharedDateFormatter;

@property (nonatomic, strong) Channel *channel;
@property (nonatomic, copy) NSData *feedData;

@property (nonatomic, strong) NSManagedObjectContext *localContext;
@property (nonatomic, strong) Channel *localChannel;
@property (nonatomic, strong) Item *currentItem;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL accumulatingParsedCharacterData;
@property (nonatomic, strong) NSMutableString *currentParsedCharacterData;

@end

@implementation TRFeedParsingOperation

#pragma mark - Initialization
static NSDateFormatter *_sharedDateFormatter = nil;
+ (NSDateFormatter *)sharedDateFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDateFormatter = [NSDateFormatter new];
        _sharedDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        _sharedDateFormatter.locale =[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        _sharedDateFormatter.dateFormat = @"EEEE', 'dd' 'MM' 'yyyy' 'HH':'mm':'ss' 'Z";
    });
    return _sharedDateFormatter;
}

- (instancetype)initWithData:(NSData *)data channel:(Channel *)channel
{
    if (self = [super init]) {
        self.channel = channel;
        self.feedData = data;
        self.items = [NSMutableArray new];
        self.currentParsedCharacterData = [NSMutableString new];
    }
    return self;
}

#pragma mark - Lifecycle
- (void)main
{
    self.localContext = [NSManagedObjectContext MR_context];
    
    // преемещаем канал в локальный контекст
    self.localChannel = [Channel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"SELF = %@", _channel] inContext:_localContext];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_feedData];
    [parser setDelegate:self];
    [parser parse];
    
    [self processParsingResult];
}

- (void)processParsingResult
{
    for (Item *item in _items) {
        Item *storedItem = [Item MR_findFirstByAttribute:@"link" withValue:item.link];
        if (storedItem) {
            NSDictionary *valuesDict = [item dictionaryWithValuesForKeys:[[item.entity attributesByName] allKeys]];
            [storedItem setValuesForKeysWithDictionary:valuesDict];
            [_localContext deleteObject:item];
        } else {
            item.channel = _localChannel;
        }
    }
    
    [_localContext MR_saveToPersistentStoreAndWait];
}

#pragma mark - NSXMLParser delegate

static NSString * const kChannelElementName     = @"channel";
static NSString * const kItemElementName        = @"item";
static NSString * const kTitleElementName       = @"title";
static NSString * const kSubtitleElementName    = @"description";
static NSString * const kLinkElementName        = @"link";
static NSString * const kPubDateElementName     = @"pubDate";

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:kItemElementName]) {
        self.currentItem = [Item MR_createInContext:_localContext];
    } else if ([elementName isEqualToString:kTitleElementName] ||
               [elementName isEqualToString:kSubtitleElementName] ||
               [elementName isEqualToString:kLinkElementName] ||
               [elementName isEqualToString:kPubDateElementName])
    {
        self.accumulatingParsedCharacterData = YES;
        [_currentParsedCharacterData setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *elementValue = [NSString stringWithString:_currentParsedCharacterData];
    if ([elementName isEqualToString:kItemElementName]) {
        if (_currentItem) {
            [_items addObject:_currentItem];
            self.currentItem = nil;
        }
    } else if ([elementName isEqualToString:kTitleElementName]) {
        if (_currentItem) {
            _currentItem.title = elementValue;
        } else {
            _localChannel.title = elementValue;
        }
    } else if ([elementName isEqualToString:kSubtitleElementName]) {
        if (_currentItem) {
            _currentItem.subtitle = elementValue;
        } else {
            _localChannel.subtitle = elementValue;
        }
    } else if ([elementName isEqualToString:kLinkElementName]) {
        if (_currentItem) {
            _currentItem.link = elementValue;
        }
    } else if ([elementName isEqualToString:kPubDateElementName]) {
        if (_currentItem) {
            _currentItem.pubDate = [[self.class sharedDateFormatter] dateFromString:elementValue];
        }
    }
    self.accumulatingParsedCharacterData = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (_accumulatingParsedCharacterData) {
        [_currentParsedCharacterData appendString:string];
    }
}

@end
