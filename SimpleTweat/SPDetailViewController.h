//
//  SPDetailViewController.h
//  SimpleTweat
//
//  Created by sander on 10/15/12.
//  Copyright (c) 2012 sander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPListViewController.h"

@interface SPDetailViewController : UIViewController
{
    
    __weak IBOutlet UIImageView *profileImage;
    __weak IBOutlet UILabel *UserLabel;
    __weak IBOutlet UILabel *tweettext;
    

    
}
@property (strong, nonatomic) id detailItem;

@end
