//
//  MainView.m
//  MacTorrentParser
//
//  Created by WEI XIE on 2016-11-12.
//  Copyright © 2016 WEI XIE. All rights reserved.
//

#import "MainView.h"

@implementation MainView 

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
    // Drawing code here.
    
    [self registerForDraggedTypes:@[(NSString*)kUTTypeItem]];
    NSLog(@"initWithFrame");

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
        NSLog(@"Path: %@", [self convertPath:fileURL]); 
    }
    return YES;
}

- (NSString *)convertPath:(NSURL *)url {
    return url.path;
}

@end
