//
//  SPSearchViewController.h
//  SimpleTweat
//
//  Created by sander on 10/16/12.
//  Copyright (c) 2012 sander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPCell.h"

@class SPSearchViewController;

@protocol SPSearchViewControllerDelegate
- (void)searchViewControllerDidFinish:(SPSearchViewController *)controller;
@end

@interface SPSearchViewController : UIViewController <UITableViewDataSource>

@property (weak, nonatomic)id <SPSearchViewControllerDelegate> delegate;

-(IBAction)done:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tabelView;

@end
