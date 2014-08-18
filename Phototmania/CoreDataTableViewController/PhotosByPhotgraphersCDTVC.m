//
//  PhotosByPhotgraphersCDTVC.m
//  Phototmania
//
//  Created by Sayantan Chakraborty on 17/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import "PhotosByPhotgraphersCDTVC.h"

@interface PhotosByPhotgraphersCDTVC ()

@end

@implementation PhotosByPhotgraphersCDTVC

-(void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    [self setupFetchedResultsController];
}

-(void) setupFetchedResultsController
{
    NSManagedObjectContext *context = self.photographer.managedObjectContext;
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@",self.photographer];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    }else{
        self.fetchedResultsController = nil;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
