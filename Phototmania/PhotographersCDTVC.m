//
//  PhotographersCDTVC.m
//  Phototmania
//
//  Created by Sayantan Chakraborty on 15/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import "PhotographersCDTVC.h"
#import "Photographer.h"
#import "PhotoDatabaseAvailability.h"
#import "PhotosByPhotgraphersCDTVC.h"

@interface PhotographersCDTVC ()

@end

@implementation PhotographersCDTVC

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.managedObjectContext = note.userInfo[PhotoDatabseAvailabilityContext];
    }];
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request =[NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photographer Cell" forIndexPath:indexPath];
    
    Photographer *photogrpher = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photogrpher.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [photogrpher.photos count]];
    
    return cell;
}

#pragma mark - Navigation For table view cells

-(void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifier fromIndexPath:(NSIndexPath *)indexPath
{
    Photographer *photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if([vc isKindOfClass:[PhotosByPhotgraphersCDTVC class]])
        if(![segueIdentifier length] || [segueIdentifier isEqualToString:@"Show Photos By Photgraphers"])
        {
            PhotosByPhotgraphersCDTVC *pbpcdtvc = (PhotosByPhotgraphersCDTVC *)vc;
            pbpcdtvc.photographer = photographer;
        }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController forSegue:segue.identifier fromIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailVc = [self.splitViewController.viewControllers lastObject];
    if ([detailVc isKindOfClass:[UINavigationController class]]) {
        detailVc =[((UINavigationController *)detailVc).viewControllers lastObject];
        [self prepareViewController:detailVc forSegue:nil fromIndexPath:indexPath];
    }
}

@end






































