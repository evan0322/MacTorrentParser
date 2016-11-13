//
//  MTPParsingManager.h
//  MacTorrentParser
//
//  Created by WEI XIE on 2016-11-13.
//  Copyright © 2016 WEI XIE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTPParsingManager : NSObject

+ (id)sharedInstance;

- (BOOL) hanldeDropedFileWithPath:(NSString *)filePath;

//The dictionary contain the info metadata in the torrent file
@property (nonatomic,strong) NSDictionary* infoDictionary;

@property (nonatomic,strong) NSString* torrentName;

@property (nonatomic,strong) NSString* torrentClient;

@property (nonatomic,strong) NSString* torrentDate;

@property (nonatomic,strong) NSString* torrentTrackerURL;

@property (nonatomic,strong) NSArray<NSDictionary *>* torrentFiles;



@end
