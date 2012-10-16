//
//  SPDetailViewController.m
//  SimpleTweat
//
//  Created by sander on 10/15/12.
//  Copyright (c) 2012 sander. All rights reserved.
//

#import "SPDetailViewController.h"

@interface SPDetailViewController ()
- (void)config;
@end

@implementation SPDetailViewController

@synthesize detailItem = _detailItem;
- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self config];
    }
}
-(void)config
{
    if (self.detailItem) {
        NSDictionary *tweet = self.detailItem;
        
        NSString *user = [[tweet objectForKey:@"user"] objectForKey:@"name"];
  
        tweettext.numberOfLines = 0;
        
        tweettext.text = [tweet objectForKey:@"text"];
        UserLabel.text = user;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageUrl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                profileImage.image = [UIImage imageWithData:data];
            });
        });
    }


}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self config];
  
}

-(void)viewWillAppear:(BOOL)animated{
    }


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
