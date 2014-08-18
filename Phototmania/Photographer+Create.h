//
//  Photographer+Create.h
//  Phototmania
//
//  Created by Sayantan Chakraborty on 15/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)
+(Photographer *) photographerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
@end
