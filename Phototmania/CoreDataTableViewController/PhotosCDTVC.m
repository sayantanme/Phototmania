//
//  PhotosCDTVC.m
//  Phototmania
//
//  Created by Sayantan Chakraborty on 18/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import "PhotosCDTVC.h"
#import "Photo.h"
#import "ImageViewController.h"

@interface PhotosCDTVC ()

@end

@implementation PhotosCDTVC

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photo Cell"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    return cell;
}

#pragma mark - Navigation For table view cells

-(void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifier fromIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if([vc isKindOfClass:[ImageViewController class]])
        if(![segueIdentifier length] || [segueIdentifier isEqualToString:@""])
        {
            ImageViewController *ivc = (ImageViewController *)vc;
            ivc.imageUrl = [NSURL URLWithString:photo.imageURL];
            ivc.title = photo.title;
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
