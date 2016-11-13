//
//  MTPBDecodingManager.h
//  MacTorrentParser
//
//  Created by WEI XIE on 2016-11-11.
//  Copyright © 2016 WEI XIE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTPBDecodingManager : NSObject

typedef struct {
    size_t		length;
    size_t		offset;
    const char	*bytes;
} BEncodedData;

+ (id)sharedInstance;

- (id)parseFileWithEncodedData:(NSData *)fileData;


@end
