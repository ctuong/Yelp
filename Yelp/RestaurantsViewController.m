//
//  RestaurantsViewController.m
//  Yelp
//
//  Created by Calvin Tuong on 2/10/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "RestaurantsViewController.h"
#import "YelpClient.h"

NSString * const kYelpConsumerKey = @"BgDak75yTFuO536tApDhQQ";
NSString * const kYelpConsumerSecret = @"BLkhdUq6SkdgwFP540tQJoMV9jI";
NSString * const kYelpToken = @"6gfbfpypucP7zB59tCCVXwJiKeUkj1Nd";
NSString * const kYelpTokenSecret = @"5A30-BxsK9Ej5mdRg0Y9QJL9eJ8";

@interface RestaurantsViewController ()

@property (nonatomic, strong) YelpClient *client;

@end

@implementation RestaurantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
    
    [self.client searchWithTerm:@"Thai" success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"response: %@", response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
