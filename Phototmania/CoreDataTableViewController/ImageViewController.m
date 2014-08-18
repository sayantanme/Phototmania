//
//  ImageViewController.m
//  Imaginarium
//
//  Created by Sayantan Chakraborty on 09/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage* image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation ImageViewController

-(void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

-(void)setImageUrl:(NSURL *)imageUrl
{
    _imageUrl = imageUrl;
    //self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageUrl]];
    [self startDownloadinImage];
}
-(void)startDownloadinImage
{
    self.image = nil;
    if(self.imageUrl)
    {
        [self.spinner startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageUrl];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                        completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                            if (!error) {
                                if ([request.URL isEqual:self.imageUrl]) {
                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localFile]];
                                    dispatch_async(dispatch_get_main_queue(), ^{self.image = image;});
                                    //NSLog(@"Downloadin: %@", self.imageUrl);
                                }
                            }
                        }];
        [task resume];
    }
    
}


-(UIImageView *)imageView
{
    if(!_imageView) _imageView =[[UIImageView alloc]init];
    
    return _imageView;
}

-(UIImage *)image
{
    return self.imageView.image;
}

-(void)setImage:(UIImage *)image
{
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = image;
    //[self.imageView sizeToFit];
    self.imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self.spinner stopAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView addSubview:self.imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISPlitviewControllerDelegate

-(void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
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
