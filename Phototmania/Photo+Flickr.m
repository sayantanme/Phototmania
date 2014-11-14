//
//  Photo+Flickr.m
//  Phototmania
//
//  Created by Sayantan Chakraborty on 15/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import "Photo+Flickr.h"
#import "Flickr Fetcher/FlickrFetcher.h"
#import "Photographer+Create.h"

@implementation Photo (Flickr)

+(Photo *) photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    NSString *unique = [photoDictionary valueForKeyPath:FLICKR_PHOTO_ID];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!matches || error ||((matches.count)>1)) {
        //handle error
    }else if ([matches count]){
        photo = [matches firstObject];
    }else{
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        photo.unique = unique;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge]absoluteString];
        photo.latitude = @([photoDictionary[FLICKR_LATITUDE] doubleValue]);
        photo.longitude = @([photoDictionary[FLICKR_LONGITUDE] doubleValue]);
        photo.thumbnailUrl = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        
        NSString *photgrpherName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photgrpherName inManagedObjectContext:context];
    }

    return photo;
}

+(void)loadPhotosFromFlickrArray:(NSArray *)photos
        intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}

@end
