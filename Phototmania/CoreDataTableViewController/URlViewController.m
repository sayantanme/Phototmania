//
//  URlViewController.m
//  Phototmania
//
//  Created by Sayantan Chakraborty on 18/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import "URlViewController.h"

@interface URlViewController ()

@property (strong, nonatomic) IBOutlet UITextView *urlTextview;
@end

@implementation URlViewController

-(void)setUrl:(NSURL *)url
{
    _url = url;
    [self updateUI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateUI];
}

-(void)updateUI
{
    self.urlTextview.text = [self.url absoluteString];
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
