//
//  PhotographersCDTVC.h
//  Phototmania
//
//  Created by Sayantan Chakraborty on 15/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface PhotographersCDTVC : CoreDataTableViewController <UISearchDisplayDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
