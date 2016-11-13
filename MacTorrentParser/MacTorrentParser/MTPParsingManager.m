//
//  MTPParsingManager.m
//  MacTorrentParser
//
//  Created by WEI XIE on 2016-11-13.
//  Copyright © 2016 WEI XIE. All rights reserved.
//

#import "MTPParsingManager.h"
#import "MTPConstants.h"
#import "MTPBDecodingManager.h"

@implementation MTPParsingManager {
    BOOL containSingleFile;
}



+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}


- (BOOL )hanldeDropedFileWithPath:(NSString *)filePath
{
    NSData *content = [NSData dataWithContentsOfFile:filePath];
    MTPBDecodingManager *decodingManager = [MTPBDecodingManager sharedInstance];
    NSDictionary *torrent = [decodingManager parseFileWithEncodedData:content];
    if (!torrent) {
        return NO;
    }
    
    
    NSMutableDictionary *info = torrent[@"info"];
    if(info[@"files"]) {
        containSingleFile = NO;
    } else {
        containSingleFile = YES;
    }
    self.torrentDate = [self extractCreateDateFromTorrentDict:torrent];
    self.torrentTrackerURL = [self extractTrackerURLFromTorrentDict:torrent];
    self.torrentName = [self extractNameFromTorrentDict:torrent];
    self.torrentClient = [self extractClientFromTorrentDict:torrent];
    //If the torrent only contains one file, we use that file infomation instead
    if (containSingleFile) {
        NSMutableDictionary *fileDict = [[NSMutableDictionary alloc] init];
        if (self.torrentName) {
            fileDict[@"path"] = self.torrentName;
        }
        
        if ([self extractFileHashFromTorrentDict:torrent]) {
            fileDict[@"filehash"] = [self extractFileHashFromTorrentDict:torrent];
        }
        
        if (info[@"length"]) {
            fileDict[@"length"] = info[@"length"];
        }
        
        self.torrentFiles = @[(NSDictionary *)fileDict];
    } else {
        self.torrentFiles = [self extractFileDetailsFromTorrentDict:torrent];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationParsingCompleted object:nil];
    return YES;
}

- (NSString *)extractCreateDateFromTorrentDict:(NSDictionary *)torrent
{
    int dateNum = [torrent[@"creation date"] intValue];
    NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:dateNum];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSLog(@"Create date is %@", [dateFormatter stringFromDate:date]);
    return [dateFormatter stringFromDate:date];
}

- (NSString *)extractTrackerURLFromTorrentDict:(NSDictionary *)torrent
{
    NSString *trackerURL = [[NSString alloc] initWithData:(NSData *)torrent[@"announce"] encoding:NSUTF8StringEncoding];
    NSLog(@"Tracker URL is %@", trackerURL);
    return trackerURL;
}

- (NSArray<NSDictionary *> *)extractFileDetailsFromTorrentDict:(NSDictionary *)torrent
{
    NSDictionary *info = torrent[@"info"];
    NSArray *files = info[@"files"];
    NSMutableArray *filesParsed = [[NSMutableArray alloc] init];
    for(NSDictionary *fileDict in files) {
        NSMutableDictionary *fileDictParsed = [fileDict mutableCopy];
        if (fileDictParsed[@"path"]) {
            NSArray *pathArray = fileDictParsed[@"path"];
            
            fileDictParsed[@"path"] = [[NSString alloc] initWithData:(NSData *)pathArray[0] encoding:NSUTF8StringEncoding];
        }
        
        if (fileDictParsed[@"filehash"]) {
            fileDictParsed[@"filehash"] = [[NSString alloc] initWithData:(NSData *)fileDictParsed[@"filehash"] encoding:NSUTF8StringEncoding];
        }
        [filesParsed addObject:(NSDictionary *)fileDictParsed];
    }
    return (NSArray *)filesParsed;
}

- (NSString *)extractClientFromTorrentDict:(NSDictionary *)torrent
{
    NSString *name = [[NSString alloc] initWithData:(NSData *)torrent[@"created by"] encoding:NSUTF8StringEncoding];
    NSLog(@"Client is %@", name);
    return name;
}

- (NSString *)extractNameFromTorrentDict:(NSDictionary *)torrent
{
    NSMutableDictionary *info = torrent[@"info"];
    NSString *name = [[NSString alloc] initWithData:(NSData *)info[@"name"] encoding:NSUTF8StringEncoding];
    NSLog(@"Name is %@", name);
    return name;
}

- (NSString *)extractFileHashFromTorrentDict:(NSDictionary *)torrent
{
    //We need to convert data into hex string
    NSMutableDictionary *info = torrent[@"info"];
    NSData *hashData = (NSData *)info[@"filehash"];
    NSUInteger capacity = hashData.length * 2;
    NSMutableString *sbuf = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *buf = hashData.bytes;
    NSInteger i;
    for (i=0; i<hashData.length; ++i) {
        [sbuf appendFormat:@"%02lX", (unsigned long)buf[i]];
    }
    return sbuf;
}

@end
