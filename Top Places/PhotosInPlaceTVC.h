//
//  PhotosInPlaceTVC.h
//  Top Places
//
//  Created by Juan Posadas on 11/5/13.
//  Copyright (c) 2013 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosInPlaceTVC : UITableViewController

@property (nonatomic) id flickrPlaceId;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSString *placeName;

@end
