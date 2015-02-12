//
//  RestaurantsViewController.m
//  Yelp
//
//  Created by Calvin Tuong on 2/10/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "RestaurantsViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"

@interface RestaurantsViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YelpClient *client;

@property (nonatomic, strong) NSString *yelpConsumerKey;
@property (nonatomic, strong) NSString *yelpConsumerSecret;
@property (nonatomic, strong) NSString *yelpToken;
@property (nonatomic, strong) NSString *yelpTokenSecret;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *businesses;

@end

@implementation RestaurantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadYelpConfig];
    
    self.client = [[YelpClient alloc] initWithConsumerKey:self.yelpConsumerKey consumerSecret:self.yelpConsumerSecret accessToken:self.yelpToken accessSecret:self.yelpTokenSecret];
    
    [self.client searchWithTerm:@"Thai" success:^(AFHTTPRequestOperation *operation, id response) {
//        NSLog(@"response: %@", response);
        
        self.businesses = [Business businessesWithDictionaries:response[@"businesses"]];
        
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate methods

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
