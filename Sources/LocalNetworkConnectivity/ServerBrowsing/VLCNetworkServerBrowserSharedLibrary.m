/*****************************************************************************
 * VLCNetworkServerBrowserVLCMedia.m
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2015 VideoLAN. All rights reserved.
 * $Id$
 *
 * Authors: Tobias Conradi <videolan # tobias-conradi.de>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import "VLCNetworkServerBrowserSharedLibrary.h"
#import "VLCSharedLibraryParser.h"

@interface VLCNetworkServerBrowserSharedLibrary () <VLCSharedLibraryParserDelegate>
@property (nonatomic, readonly) NSString *addressOrName;
@property (nonatomic, readonly) NSUInteger port;
@property (nonatomic, readonly) VLCSharedLibraryParser *httpParser;

@end

@implementation VLCNetworkServerBrowserSharedLibrary
@synthesize title = _title, delegate = _delegate, items = _items;

- (instancetype)initWithName:(NSString *)name host:(NSString *)addressOrName portNumber:(NSUInteger)portNumber
{
    self = [super init];
    if (self) {
        _title = name;
        _addressOrName = addressOrName;
        _port = portNumber;
        _items = [NSArray array];
        _httpParser = [[VLCSharedLibraryParser alloc] init];
        _httpParser.delegate = self;
    }
    return self;
}

- (void)update {
    [self.httpParser fetchDataFromServer:self.addressOrName port:self.port];
}

#pragma mark - Specifics


- (void)sharedLibraryDataProcessings:(NSArray *)result
{
    _title = [result.firstObject objectForKey:@"libTitle"];

    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dict in result) {
        [items addObject:[[VLCNetworkServerBrowserItemSharedLibrary alloc] initWithDictionary:dict]];
    }
    _items = [items copy];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.delegate networkServerBrowserDidUpdate:self];

    }];
}

@end


@implementation VLCNetworkServerBrowserItemSharedLibrary
@synthesize name = _name, URL = _URL, fileSizeBytes = _fileSizeBytes, container = _container;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _name = dictionary[@"title"];
        NSString *thumbURLString = dictionary[@"thumb"];
        _subtitleURL = thumbURLString ? [NSURL URLWithString:thumbURLString] : nil;
        _fileSizeBytes = dictionary[@"size"];
        _duration = dictionary[@"duration"];
        NSString *subtitleURLString = dictionary[@"pathSubtitle"];
        if ([subtitleURLString isEqualToString:@"(null)"]) subtitleURLString = nil;
        subtitleURLString = [subtitleURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _subtitleURL = subtitleURLString ? [NSURL URLWithString:subtitleURLString] : nil;
        _URL = [NSURL URLWithString:dictionary[@"pathfile"]];
        _container = NO;
    }
    return self;
}

- (id<VLCNetworkServerBrowser>)containerBrowser {
    return nil;
}

@end