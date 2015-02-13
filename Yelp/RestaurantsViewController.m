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
#import "FiltersViewController.h"
#import "SVProgressHUD.h"

@interface RestaurantsViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate>

@property (nonatomic, strong) YelpClient *client;

@property (nonatomic, strong) NSString *yelpConsumerKey;
@property (nonatomic, strong) NSString *yelpConsumerSecret;
@property (nonatomic, strong) NSString *yelpToken;
@property (nonatomic, strong) NSString *yelpTokenSecret;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *businesses;

@property (nonatomic, strong) NSString *currentSearchString;

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;

@end

@implementation RestaurantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadYelpConfig];
    
    self.client = [[YelpClient alloc] initWithConsumerKey:self.yelpConsumerKey consumerSecret:self.yelpConsumerSecret accessToken:self.yelpToken accessSecret:self.yelpTokenSecret];
    
    // set up the table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 86;
    
    self.currentSearchString = @"Restaurants";
    [self fetchBusinessesWithQuery:self.currentSearchString params:nil];
    
    // set up the filters button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filters" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithWhite:1 alpha:1];
    
    // set up the search bar
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar sizeToFit];
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
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

#pragma mark - UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.currentSearchString = searchText;
    [self fetchBusinessesWithQuery:searchText params:nil];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    
    // change the default margin of the table divider length
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    cell.business = self.businesses[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - FiltersViewControllerDelegate methods

- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    if ([self.currentSearchString length] == 0) {
        [self fetchBusinessesWithQuery:@"Restaurants" params:filters];
    } else {
        [self fetchBusinessesWithQuery:self.currentSearchString params:filters];
    }
}

#pragma mark - Private methods

- (void)onFilterButton {
    FiltersViewController *fvc = [[FiltersViewController alloc] init];
    fvc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:fvc];
    
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD show];
    
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        //NSLog(@"response: %@", response);
        
        self.businesses = [Business businessesWithDictionaries:response[@"businesses"]];
        
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
        [SVProgressHUD dismiss];
    }];
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
