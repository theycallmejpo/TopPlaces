//
//  RecentImageStorage.m
//  Top Places
//
//  Created by Juan Posadas on 11/6/13.
//  Copyright (c) 2013 Stanford. All rights reserved.
//

#import "RecentImageStorage.h"

@implementation RecentImageStorage

#define RECENT_IMAGES_KEY @"recentImages"
#define MAX_RECENT_IMAGES 20

+ (void)saveRecentImageData:(NSDictionary *)imageData
{
    NSMutableArray *recent = [RecentImageStorage getRecentImages];
    
    if ([recent containsObject:imageData]) {
        [recent removeObject:imageData];
    }
    
    [recent insertObject:imageData atIndex:0];
    
    if ([recent count] > MAX_RECENT_IMAGES) {
        recent = [[recent subarrayWithRange:NSMakeRange(0, MAX_RECENT_IMAGES)] mutableCopy];
    }
    
    
    [RecentImageStorage saveRecent:recent];
}

+ (NSMutableArray *)getRecentImages
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recent = [defaults mutableArrayValueForKey:RECENT_IMAGES_KEY];
    if (!recent) recent = [[NSMutableArray alloc] init];
    return recent;
}


+ (void) saveRecent: (NSMutableArray*) recent {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:recent forKey:RECENT_IMAGES_KEY];
    [defaults synchronize];
}

@end
