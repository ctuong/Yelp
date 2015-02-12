//
//  RestaurantsViewController.m
//  Yelp
//
//  Created by Calvin Tuong on 2/10/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "RestaurantsViewController.h"
#import "YelpClient.h"

@interface RestaurantsViewController () <UISearchBarDelegate>

@property (nonatomic, strong) YelpClient *client;

@property (nonatomic, strong) NSString *yelpConsumerKey;
@property (nonatomic, strong) NSString *yelpConsumerSecret;
@property (nonatomic, strong) NSString *yelpToken;
@property (nonatomic, strong) NSString *yelpTokenSecret;

@end

@implementation RestaurantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadYelpConfig];
    
    self.client = [[YelpClient alloc] initWithConsumerKey:self.yelpConsumerKey consumerSecret:self.yelpConsumerSecret accessToken:self.yelpToken accessSecret:self.yelpTokenSecret];
    
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

- (void)loadYelpConfig {
    NSDictionary *yelpConfig = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
    
    self.yelpConsumerKey = yelpConfig[@"yelpConsumerKey"];
    self.yelpConsumerSecret = yelpConfig[@"yelpConsumerSecret"];
    self.yelpToken = yelpConfig[@"yelpToken"];
    self.yelpTokenSecret = yelpConfig[@"yelpTokenSecret"];
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
