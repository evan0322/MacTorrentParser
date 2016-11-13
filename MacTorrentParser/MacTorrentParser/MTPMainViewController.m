//
//  MainViewController.m
//  MacTorrentParser
//
//  Created by WEI XIE on 2016-11-12.
//  Copyright © 2016 WEI XIE. All rights reserved.
//

#import "MTPMainViewController.h"
#import "MTPConstants.h"
#import "MTPParsingManager.h"


@interface MTPMainViewController()

@property (strong, nonatomic) MTPParsingManager* parsingManager;

@end

@implementation MTPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [NSColor blueColor].CGColor;
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parsingCompleted)
                                                 name:kNotificationParsingCompleted
                                               object:nil];
    self.parsingManager = [MTPParsingManager sharedInstance];
    [self.filesTableView setDelegate:self];
    [self.filesTableView setDataSource:self];
    self.nameTextField.editable = NO;
    self.clientTextField.editable = NO;
    self.trackerTextField.editable = NO;
    self.dateTextField.editable = NO;
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)parsingCompleted
{
    self.nameTextField.stringValue = self.parsingManager.torrentName;
    self.clientTextField.stringValue = self.parsingManager.torrentClient;
    self.trackerTextField.stringValue = self.parsingManager.torrentTrackerURL;
    self.dateTextField.stringValue = self.parsingManager.torrentDate;
    [self.filesTableView reloadData];
}


#pragma mark -
#pragma mark TableView delegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"MyView" owner:self];
    if (self.parsingManager.torrentFiles) {
        NSUInteger index = [[tableView tableColumns] indexOfObject:tableColumn];
        if (index == 0 ) {
            //Name column
            NSDictionary *file = self.parsingManager.torrentFiles[row];
            cell.textField.stringValue = file[@"path"]?file[@"path"]:@"";
        } else if (index == 1 ) {
            //Length column
            NSDictionary *file = self.parsingManager.torrentFiles[row];
            cell.textField.stringValue = file[@"length"]?file[@"length"]:@"";
        } else if (index == 2 ) {
            //hash column
            NSDictionary *file = self.parsingManager.torrentFiles[row];
            cell.textField.stringValue = file[@"filehash"]?file[@"filehash"]:@"";
        }
    }
    return cell;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    return [self.parsingManager.torrentFiles count];
}



@end
