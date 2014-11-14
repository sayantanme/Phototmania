//
//  PhotosByPhotographerMapViewController.m
//  Phototmania
//
//  Created by Sayantan Chakraborty on 23/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import "PhotosByPhotographerMapViewController.h"
#import <MapKit/MapKit.h>  
#import "Photo+Annotation.h"
#import "ImageViewController.h"

@interface PhotosByPhotographerMapViewController ()<MKMapViewDelegate>
@property (nonatomic,strong) NSArray *photosByPhotographers;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) ImageViewController *imageVC;
@end

@implementation PhotosByPhotographerMapViewController

-(ImageViewController *)imageVC
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isKindOfClass:[UINavigationController class]]) {
        detailVC = [((UINavigationController *)detailVC).viewControllers firstObject];
    }
    return ([detailVC isKindOfClass:[ImageViewController class]]?detailVC:nil);
}
-(void)updateMapviewAnnotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.photosByPhotographers];
    [self.mapView showAnnotations:self.photosByPhotographers animated:YES];
    if (self.imageVC) {
        Photo *autoSelected= [self.photosByPhotographers firstObject];
        if (autoSelected) {
            [self.mapView selectAnnotation:autoSelected animated:YES];
            [self prepareViewController:self.imageVC forSegue:nil toShowAnnotation:autoSelected];
        }
    }
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"PhotosByPhotographerMapViewController";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if(!view){
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        
        if(!self.imageVC){
            UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 36, 36)];
            view.leftCalloutAccessoryView = imageview;
            UIButton *disclosureButon = [[UIButton alloc]init];
            [disclosureButon setBackgroundImage:[UIImage imageNamed:@"disclosure" ] forState:UIControlStateNormal];
            [disclosureButon sizeToFit];
            view.rightCalloutAccessoryView = disclosureButon;
        }
        
    }
    view.annotation = annotation;
    
    return view;
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (self.imageVC)
    {
        [self prepareViewController:self.imageVC forSegue:nil toShowAnnotation:view.annotation];
    } else {
        [self updateLeftCalloutAccessoryViewInAnnotationView:view];
    }
}
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"Show Photos" sender:view];
}

-(void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifier toShowAnnotation:(id <MKAnnotation>)annotation
{
    Photo *photo = nil;
    if([annotation isKindOfClass:[Photo class]])
    {
        photo = (Photo *)annotation;
    }
    if (photo) {
        if (![segueIdentifier length] || [segueIdentifier isEqualToString:@"Show Photos"]) {
            if ([vc isKindOfClass:[ImageViewController class]]) {
                ImageViewController *ivc = (ImageViewController *)vc;
                ivc.imageUrl = [NSURL URLWithString:photo.imageURL];
                ivc.title = photo.title;
            }
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[MKAnnotationView class]]) {
        [self prepareViewController:segue.destinationViewController forSegue:segue.identifier toShowAnnotation:((MKAnnotationView *)sender).annotation];
    }
}

-(void)updateLeftCalloutAccessoryViewInAnnotationView:(MKAnnotationView *) annotationView
{
    UIImageView *img = nil;
    if ([annotationView.leftCalloutAccessoryView isKindOfClass:[UIImageView
                                                                class]]) {
        img = (UIImageView *) annotationView.leftCalloutAccessoryView;
    }
    if (img) {
        Photo *photo = nil;
        if ([annotationView.annotation isKindOfClass:[Photo class]]) {
            photo = (Photo *) annotationView.annotation;
        }
        if (photo) {
            img.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailUrl]]];
        }
    }
}
-(void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapviewAnnotations];
}
-(void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    self.photosByPhotographers = nil;
    [self updateMapviewAnnotations];
}

-(NSArray *)photosByPhotographers
{
    if (!_photosByPhotographers) {
        NSFetchRequest * request= [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@", self.photographer];
        _photosByPhotographers = [self.photographer.managedObjectContext executeFetchRequest:request error:NULL];
    }
    return _photosByPhotographers;
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
