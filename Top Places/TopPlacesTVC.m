//
//  TopPlacesTVC.m
//  Top Places
//
//  Created by Juan Posadas on 11/5/13.
//  Copyright (c) 2013 Stanford. All rights reserved.
//

#import "TopPlacesTVC.h"
#import "PhotosInPlaceTVC.h"
#import "FlickrFetcher.h"

@interface TopPlacesTVC ()

@property (nonatomic, strong) NSArray *sortedKeys;

@end

@implementation TopPlacesTVC

#pragma mark - Initialization

- (void)setSortedKeys:(NSArray *)sortedKeys
{
    _sortedKeys = sortedKeys;
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
    [self fetchPlaces];
}

- (void)fetchPlaces
{
    [self.refreshControl beginRefreshing]; // start the spinner
    NSURL *topPlacesURL = [FlickrFetcher URLforTopPlaces];
    
    // create a (non-main) queue to do fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    // put a block to do the fetch onto that queue
    
    dispatch_async(fetchQ, ^{
        
        
        NSData *jsonData = [NSData dataWithContentsOfURL:topPlacesURL];
        NSDictionary *results =  [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:0
                                                                   error:NULL];

        NSArray *places = [results valueForKeyPath:FLICKR_RESULTS_PLACES];
//        NSLog(@"PLACES: %@", results);
        
        NSMutableDictionary *countries = [[NSMutableDictionary alloc] init];
        NSArray *sortedKeys;
        
        for (NSDictionary *entry in places) {
            
            NSString *placeName = [entry valueForKey:FLICKR_PLACE_NAME];
            
            NSMutableArray *placeSplits = [[NSMutableArray alloc] initWithArray:[placeName componentsSeparatedByString:@","]];
            NSString *country = [placeSplits lastObject];
            [placeSplits removeLastObject];
            [placeSplits addObject:[entry valueForKey:FLICKR_PLACE_ID]];

            NSMutableArray *placesByCountry = [countries objectForKey:country];
            
            if (placesByCountry) {
                
                [placesByCountry addObject:placeSplits];
                [countries setObject:placesByCountry forKey:country];
            
            } else {
            
                NSMutableArray *firstArray = [[NSMutableArray alloc] init];
                [firstArray addObject:placeSplits];
                [countries setObject:firstArray forKey:country];
            
            }
            
        }
        
        sortedKeys = [[countries allKeys] sortedArrayUsingSelector:
                           @selector(localizedCaseInsensitiveCompare:)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing]; // stop the spinner
            self.countries = countries;
            self.sortedKeys = sortedKeys;
        });
    });

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.countries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSString *country = self.sortedKeys[section];
    NSArray *countryRows = [self.countries objectForKey:country];
    
    return [countryRows count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sortedKeys[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Place Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...

    NSArray *place = [self sortAndFindPlaceForIndex:indexPath];
    
    cell.textLabel.text = [place firstObject];
    cell.detailTextLabel.text = [place count] < 3 ? @"" : [place objectAtIndex:1];
    
    return cell;
}

- (NSArray *)sortAndFindPlaceForIndex:(NSIndexPath *)indexPath
{
    NSString *country = self.sortedKeys[indexPath.section];
    NSArray *placesInCountry = [self.countries objectForKey:country];
    
    NSArray *sortedPlacesInCountry = [placesInCountry sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *first = [(NSArray *)obj1 firstObject];
        NSString *second = [(NSArray *)obj2 firstObject];
        
        return [first compare:second];
    }];
    
    return sortedPlacesInCountry[indexPath.row];
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
            
            if ([segue.identifier isEqualToString:@"Display Photo List"]) {
                
                if ([segue.destinationViewController isKindOfClass:[PhotosInPlaceTVC class]]) {
                    
                    PhotosInPlaceTVC *piptvc = segue.destinationViewController;
                    piptvc.placeName = [(UITableViewCell *)sender textLabel].text;

                    NSArray *place = [self sortAndFindPlaceForIndex:indexPath];
                    piptvc.flickrPlaceId = [place lastObject];
                    
                }
                
            }
            
        }
    }
    
}



@end
