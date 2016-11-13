//
//  MTPBDecodingManager.m
//  MacTorrentParser
//
//  Created by WEI XIE on 2016-11-11.
//  Copyright © 2016 WEI XIE. All rights reserved.
//

#import "MTPBDecodingManager.h"

@implementation MTPBDecodingManager

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)parseFileWithEncodedData:(NSData *)fileData
{
    BEncodedData data;
    data.bytes = [fileData bytes];
    data.length = [fileData length];
    data.offset = 0;
    
    return data.bytes ? [self objectFromData:&data] : nil;
}

- (id)objectFromData:(BEncodedData *)data
{
    if (data->offset >= data->length) return nil;
    
    switch (data->bytes[data->offset]) {
        case 'l':
            //Data Object
            return [self arrayFromEncodedData:data];
            break;
        case 'd':
            //Dictionary
            return [self dictionaryFromEncodedData:data];
            break;
        case 'i':
            //Int
            return [self numberFromEncodedData:data];
            break;
        default:
            if (data->bytes[data->offset] >= '0' && data->bytes[data->offset] <= '9')
                return [self dataFromEncodedData:data];
    }
    
    data->offset++;
    return [self objectFromData:data];
}

- (NSArray *)arrayFromEncodedData:(BEncodedData *)data
{
    NSMutableArray *array = [NSMutableArray array];
    
    if (data->bytes[data->offset] != 'l') return nil;
    
    data->offset++; /* Move off the l so we point to the first encoded item. */
    if (data->offset >= data->length) return nil;
    
    while (data->offset < data->length && data->bytes[data->offset] != 'e')
        [array addObject:[self objectFromData:data]];
    
    if (data->bytes[data->offset] != 'e') return nil;
    
    data->offset++;
    
    return array;
}

- (NSDictionary *)dictionaryFromEncodedData:(BEncodedData *)data
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSString *key = nil;
    id value = nil;
    
    if (data->bytes[data->offset] != 'd') return nil;
    
    data->offset++; /* Move off the d so we point to the string key. */
    if (data->offset >= data->length) return nil;
    
    while (data->offset < data->length && data->bytes[data->offset] != 'e') {
        if (data->bytes[data->offset] >= '0' && data->bytes[data->offset] <= '9') {
            key = [self stringFromEncodedData:data];
            value = [self objectFromData:data];
            if (key != nil && value != nil)
                [dictionary setValue:value forKey:key];
        } else {
            return nil;
        }
    }
    
    if (data->bytes[data->offset] != 'e') return nil;
    
    data->offset++;
    
    return dictionary;
}

- (NSNumber *)numberFromEncodedData:(BEncodedData *)data
{
    long long int number = 0;
    
    if (data->bytes[data->offset] != 'i') return nil;
    
    data->offset++; /* We start on the i so we need to move by one. */
    if (data->offset >= data->length) return nil;
    
    BOOL firstChar = YES, firstDigit = YES, negate = NO;
    while (data->offset < data->length && data->bytes[data->offset] != 'e') {
        unsigned char curChar = data->bytes[data->offset++];
        if (curChar > '9' || curChar < '0') {
            if (!firstChar) return nil;
            if      (curChar == '-') negate = YES;
            else if (curChar != '+') return nil;
        } else {
            if (curChar == '0' && firstDigit && data->bytes[data->offset] != 'e')
                return nil;
            
            number *= 10;
            number += curChar - '0';
            firstDigit = NO;
        }
        firstChar = NO;
    }
    
    data->offset++;
    
    return [NSNumber numberWithLongLong:negate? -number: number];
}

- (NSData *)dataFromEncodedData:(BEncodedData *)data
{
    NSMutableData *decodedData = [NSMutableData data];
    size_t dataLength = 0;
    
    if (data->offset >= data->length) return nil;
    
    if (data->bytes[data->offset] < '0' || data->bytes[data->offset] > '9')
        return nil;
    
    while (data->offset < data->length && data->bytes[data->offset] != ':') {
        unsigned char curChar = data->bytes[data->offset++];
        if (curChar > '9' || curChar < '0') return nil;
        dataLength *= 10;
        dataLength += curChar - '0';
    }
    
    if (data->bytes[data->offset] != ':')
        return nil;
    
    data->offset++;
    if (data->offset+dataLength > data->length) return nil;
    
    [decodedData appendBytes:data->bytes+data->offset length:dataLength];
    
    data->offset += dataLength;
    return decodedData;
}

- (NSString *)stringFromEncodedData:(BEncodedData *)data
{
    
    NSData *decodedData = [self dataFromEncodedData:data];
    if (decodedData == nil) return nil;
    
    return [[NSString alloc] initWithBytes:[decodedData bytes] length:[decodedData length] encoding:NSUTF8StringEncoding];
}

@end
