//
//  SPListViewController.m
//  SimpleTweat
//
//  Created by sander on 10/15/12.
//  Copyright (c) 2012 sander. All rights reserved.
//

#import "SPListViewController.h"
#import "SPCell.h"

@interface SPListViewController()
@property (nonatomic,strong) NSArray *tweets;
@end

@implementation SPListViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load nib
    UINib *nib=[UINib nibWithNibName:@"SPCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"SPCell"];
    [[UINavigationBar appearance] setTintColor:[UIColor lightGrayColor]];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self showHome];
}

-(id)init
{
    self=[super initWithStyle:UITableViewStylePlain];
    self.tableView.rowHeight=60.0;
    if (self) {
        UINavigationItem *n=[self navigationItem];
        [n setTitle:@"SPTweet"];
        UIBarButtonItem *bbi=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(tweetTapped:)];
        [[self navigationItem]setRightBarButtonItem:bbi];
        UIBarButtonItem *search=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
        [[self navigationItem]setLeftBarButtonItem:search];
       // self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLineEtched;
        self.tableView.separatorColor=[UIColor lightGrayColor];
    }
    return self;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


-(void)showHome {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter ];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL success, NSError *error) {
        
        if(success) {
			
        NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			
			if ([accountsArray count] > 0) {
				//  Twitter account to tweet from.
				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                //Link for homepage
                NSURL *requestURL=[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
                SLRequest *postRequest=[SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
                [postRequest setAccount:twitterAccount];
                
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *output;
                    
                    if ([urlResponse statusCode] == 200) {
                        // Parse into an NSDictionary using NSJSONSerialization.
                        NSError *jsonParsingError = nil;
                        _tweets = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
                        //Just for log
                        output = [NSString stringWithFormat:@"HTTP response status: %i\nPublic timeline:\n%@", [urlResponse statusCode], _tweets];
                        
                    }
                    else {
                        output = [NSString stringWithFormat:@"HTTP response status: %i\n", [urlResponse statusCode]];
                    }
                    //UI must happen in main queue
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                      //  NSLog(@"logg %@",output);
                    });
                  
                }];
            }
        }
	}];
}

#pragma mark - TabelView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // NSLog(@"Tweets total %i",[_tweets count]);
    return [_tweets count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SPCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SPCell"];
    NSDictionary *tweet=[_tweets objectAtIndex:indexPath.row];
                         [[cell TweetText] setText:[tweet objectForKey:@"text"]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imageUrl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        //Loading pictures async
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.UserImageView.image = [UIImage imageWithData:data];
        });
    });
  
    return cell;
}
  
//Push to Deatilview
  
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSDictionary *tweet=[_tweets objectAtIndex:indexPath.row];
   
    SPDetailViewController *dvc=[[SPDetailViewController alloc]init];

    dvc.detailItem = tweet;
    [[self navigationController]pushViewController:dvc animated:YES];
    
}

#pragma mark - Actions

-(IBAction)tweetTapped:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *newTweet=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [newTweet setInitialText:@"My important tweet"];
        [self presentViewController:newTweet animated:YES completion:nil];
        
    }
    else
    {
        UIAlertView *av=[[UIAlertView alloc]
                         initWithTitle:nil message:@"Can't tweet, make sure your device is an internet connectoin and you had set up Twitter in preferences" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

-(IBAction)search:(id)sender
{
    SPSearchViewController *controller = [[SPSearchViewController alloc] initWithNibName:@"SPSearchViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Flipside View

- (void)searchViewControllerDidFinish:(SPSearchViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
