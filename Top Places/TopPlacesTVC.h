//
//  TopPlacesTVC.h
//  Top Places
//
//  Created by Juan Posadas on 11/5/13.
//  Copyright (c) 2013 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopPlacesTVC : UITableViewController

@property (nonatomic, strong) NSMutableArray *places; // of Flickr places NSDictionary
@property (nonatomic, strong) NSMutableDictionary *countries; // of Flickr places NSDictionary

@end
