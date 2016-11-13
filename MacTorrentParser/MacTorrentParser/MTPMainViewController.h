//
//  MainViewController.h
//  MacTorrentParser
//
//  Created by WEI XIE on 2016-11-12.
//  Copyright © 2016 WEI XIE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MTPMainViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSTextField *dateTextField;
@property (weak) IBOutlet NSTextField *clientTextField;
@property (weak) IBOutlet NSTextField *trackerTextField;
@property (weak) IBOutlet NSScrollView *fileDetailView;
@property (weak) IBOutlet NSTableView *filesTableView;

@end

