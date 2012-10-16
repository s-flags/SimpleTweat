//
//  SPSearchViewController.m
//  SimpleTweat
//
//  Created by sander on 10/16/12.
//  Copyright (c) 2012 sander. All rights reserved.
//

#import "SPSearchViewController.h"
#import "SPListViewController.h"
#import "SPCell.h"

@interface SPSearchViewController ()
@property (nonatomic,strong) NSArray *searchresults;

@property (nonatomic,copy) NSString *searchText;
@end

@implementation SPSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - Search

-(void)showSearchAlert
{
    UIAlertView *av=[[UIAlertView alloc]
                     
                     initWithTitle:@"Search text" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Search", nil];
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    
    
    [av show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        NSString *searchstring=[alertView textFieldAtIndex:0].text;
       // NSLog(@"Otsing1 %@",searchstring);
        if (searchstring.length>0) {
            _searchText=[searchstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
     //   NSLog(@"Otsingutekst on:%@", _searchText);
        [self searchTweets];
    }
    else{
        [self.delegate searchViewControllerDidFinish:self];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    //Asking for search text
    [self showSearchAlert];
}

- (void)viewDidLoad
{
     UINib *nib=[UINib nibWithNibName:@"SPCell" bundle:nil];
      [[self tabelView] registerNib:nib forCellReuseIdentifier:@"SPCell"];
    [super viewDidLoad];
   
}


-(void)searchTweets {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter ];

    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL success, NSError *error) {
        
        if(success) {
			
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			
			if ([accountsArray count] > 0) {
				
				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
            
                NSDictionary *parameters=@{@"q":_searchText,@"include_entities":@"false"};
                NSURL *requestURL=[NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
                SLRequest *postRequest=[SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:parameters];
                [postRequest setAccount:twitterAccount];
                
           
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *output;
                    
                    if ([urlResponse statusCode] == 200) {
                       
                        NSError *jsonParsingError = nil;
                        //Takeing out matadata
                        NSDictionary *allresults= [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
                        _searchresults = [allresults objectForKey:@"statuses"];
                        
                        
                        
                        output = [NSString stringWithFormat:@"HTTP response status: %i\n Search results:\n%@", [urlResponse statusCode], _searchresults];
                        
                        
                    }
                    else {
                        output = [NSString stringWithFormat:@"HTTP response status: %i\n", [urlResponse statusCode]];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tabelView reloadData];
                        //  NSLog(@"logg %@",output);
                    });
                   
                }];
            }
        }
	}];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate searchViewControllerDidFinish:self];
}
#pragma mark - Tabelview

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int total=[_searchresults count];

   // NSLog(@"Results total on %i",total);
    return total;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SPCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SPCell"];
    NSDictionary *result=[_searchresults objectAtIndex:indexPath.row];
    [[cell TweetText] setText:[result objectForKey:@"text"]];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imageUrl = [[result objectForKey:@"user"] objectForKey:@"profile_image_url"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.UserImageView.image = [UIImage imageWithData:data];
        });
    });
    return cell;
}

@end
