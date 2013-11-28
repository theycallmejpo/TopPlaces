//
//  PhotosInPlaceTVC.m
//  Top Places
//
//  Created by Juan Posadas on 11/5/13.
//  Copyright (c) 2013 Stanford. All rights reserved.
//

#import "PhotosInPlaceTVC.h"
#import "ImageViewController.h"
#import "RecentImageStorage.h"
#import "FlickrFetcher.h"

@interface PhotosInPlaceTVC ()

@end

@implementation PhotosInPlaceTVC

#define MAX_FLICKR_PHOTOS 50
#define NO_TITLE_DESCRIPTION_STRING @"Unknown"

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchPhotos];
}

- (void)fetchPhotos
{
    
    [self.refreshControl beginRefreshing];
    NSURL *photosInPlaceURL = [FlickrFetcher URLforPhotosInPlace:self.flickrPlaceId maxResults:MAX_FLICKR_PHOTOS];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr photo fetcher", NULL);
    
    dispatch_async(fetchQ, ^{
    
        NSData *jsonData = [NSData dataWithContentsOfURL:photosInPlaceURL];
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:0
                                                                  error:NULL];

        NSArray *photos = [results valueForKeyPath:FLICKR_RESULTS_PHOTOS];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.refreshControl endRefreshing];
            self.photos = photos;
        
        });
    
    });
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.placeName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary *photo = self.photos[indexPath.row];
    NSString *photoTitle = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    NSString *photoDescription = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    if ([photoTitle isEqualToString:@""]) {
        
        if ([photoDescription isEqualToString:@""]) {
            photoTitle = @"Unknown";
        } else {
            photoTitle = photoDescription;
            photoDescription = @"";
        }
            
    }
    
    cell.textLabel.text = photoTitle;
    cell.detailTextLabel.text = photoDescription;
    
    return cell;
}

#pragma mark - UITableViewDelegate

// when a row is selected and we are in a UISplitViewController,
//   this updates the Detail ImageViewController (instead of segueing to it)
// knows how to find an ImageViewController inside a UINavigationController in the Detail too
// otherwise, this does nothing (because detail will be nil and not "isKindOfClass:" anything)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    id detail = self.splitViewController.viewControllers[1];
    
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    
    if ([detail isKindOfClass:[ImageViewController class]]) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *title = [cell textLabel].text;
        [self prepareImageViewController:detail toDisplayPhoto:self.photos[indexPath.row] andTitle:title];
    }
}



#pragma mark - Navigation
- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo andTitle:(NSString *)title
{
//    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
//    ivc.title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    

    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    ivc.title = title;
    [RecentImageStorage saveRecentImageData:photo];
    
}


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
                    
//                    ImageViewController *ivc = segue.destinationViewController;
//                    ivc.imageURL = [FlickrFetcher URLforPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
//                    
                    NSString *title = [(UITableViewCell *)sender textLabel].text;
//                    
//                    [RecentImageStorage saveRecentImageData:self.photos[indexPath.row]];
                    
                    [self prepareImageViewController:segue.destinationViewController
                                      toDisplayPhoto:self.photos[indexPath.row]
                                            andTitle:title];
                    
                }
                
            }
            
        }
    }
    
}



@end









