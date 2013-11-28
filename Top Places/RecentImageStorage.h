//
//  RecentImageStorage.h
//  Top Places
//
//  Created by Juan Posadas on 11/6/13.
//  Copyright (c) 2013 Stanford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentImageStorage : NSObject

+ (void) saveRecentImageData: (NSDictionary*) imageData;
+ (NSMutableArray*) getRecentImages;

@end
