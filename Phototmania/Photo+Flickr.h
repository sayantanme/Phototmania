//
//  Photo+Flickr.h
//  Phototmania
//
//  Created by Sayantan Chakraborty on 15/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+(Photo *) photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

+(void)loadPhotosFromFlickrArray:(NSArray *)photos
        intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
