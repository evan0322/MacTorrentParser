//
//  MainView.m
//  MacTorrentParser
//
//  Created by WEI XIE on 2016-11-12.
//  Copyright © 2016 WEI XIE. All rights reserved.
//

#import "MTPMainView.h"
#import "MTPParsingManager.h"


@implementation MTPMainView


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
    [self registerForDraggedTypes:@[(NSString*)kUTTypeItem]];
    
    
}


-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    
    return NSDragOperationEvery;
}

-(NSDragOperation) draggingUpdated:(id<NSDraggingInfo>)sender
{
    
    return NSDragOperationEvery;
}


- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender{
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSURLPboardType]) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        NSLog(@"Reading file from path: %@", fileURL.path);
        MTPParsingManager *manager = [MTPParsingManager sharedInstance];
        if(![manager hanldeDropedFileWithPath:fileURL.path]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Invalid Format"];
            [alert setInformativeText:@"Invlid torrent file provided."];
            [alert addButtonWithTitle:@"Ok"];
            [alert runModal];
        };
    }
    return YES;
}

@end
