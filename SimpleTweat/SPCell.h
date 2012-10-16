//
//  SPCell.h
//  SimpleTweat
//
//  Created by sander on 10/16/12.
//  Copyright (c) 2012 sander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *UserImageView;
@property (weak, nonatomic) IBOutlet UILabel *TweetText;

@end
