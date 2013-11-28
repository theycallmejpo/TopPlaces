//
//  RecentImagesTVC.m
//  Top Places
//
//  Created by Juan Posadas on 11/6/13.
//  Copyright (c) 2013 Stanford. All rights reserved.
//

#import "RecentImagesTVC.h"
#import "RecentImageStorage.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface RecentImagesTVC ()

@property (nonatomic, strong) NSArray *recentImages;

@end

@implementation RecentImagesTVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.recentImages = [RecentImageStorage getRecentImages];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.recentImages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary *photo = self.recentImages[indexPath.row];
    NSString *title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    NSString *description = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    if ([title isEqualToString:@""]) {
        if ([description isEqualToString:@""]) {
            title = @"Unknown";
        } else {
            title = description;
        }
    }
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = description;
    
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            
            if ([segue.identifier isEqualToString:@"Display Photo"]) {
                
                if([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    
                    ImageViewController *ivc = segue.destinationViewController;
                    ivc.imageURL = [FlickrFetcher URLforPhoto:self.recentImages[indexPath.row] format:FlickrPhotoFormatLarge];
                    
                    ivc.title = [(UITableViewCell *)sender textLabel].text;
                    
                    [RecentImageStorage saveRecentImageData:self.recentImages[indexPath.row]];
                    
                }
                
            }
            
        }
    }
    
}



@end
