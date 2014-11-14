//
//  Photo.h
//  Phototmania
//
//  Created by Sayantan Chakraborty on 23/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) Photographer *whoTook;

@end
