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
#import <MapKit/MapKit.h>
#import <UIImageView+AFNetworking.h>

@interface RestaurantsViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, FiltersViewControllerDelegate>

@property (nonatomic, strong) YelpClient *client;

@property (nonatomic, strong) NSString *yelpConsumerKey;
@property (nonatomic, strong) NSString *yelpConsumerSecret;
@property (nonatomic, strong) NSString *yelpToken;
@property (nonatomic, strong) NSString *yelpTokenSecret;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *businesses;
@property (nonatomic, assign) MKCoordinateRegion mapRegion;

@property (nonatomic, strong) NSString *currentSearchString;
@property (nonatomic, strong) NSNumber *currentSearchLimit;
@property (nonatomic, strong) NSNumber *currentSearchOffset;
// save the current filters for infinite loading
@property (nonatomic, strong) NSDictionary *currentFilters;

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
    
    // set up the map view
    self.mapView.delegate = self;
    
    self.currentSearchString = @"Restaurants";
    self.currentSearchLimit = @20;
    self.currentSearchOffset = @0;
    self.currentFilters = [NSDictionary dictionary];
    [self fetchBusinessesWithQuery:self.currentSearchString params:nil];
    
    // set up the filters button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filters" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithWhite:1 alpha:1];
    
    // set up the map button
    [self setUpRightBarButtonWithTitle:@"Map" action:@selector(onMapButton)];
    
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
    // typing a search term doesn't use the filters
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
    
    cell.row = indexPath.row + 1;
    cell.business = self.businesses[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"BusinessPin"];
    if (pin) {
        pin.annotation = annotation;
    } else {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BusinessPin"];
    }
    pin.animatesDrop = NO;
    pin.draggable = NO;
    pin.canShowCallout = YES;
    pin.leftCalloutAccessoryView = [self createLeftCalloutViewForBusiness:(Business *)annotation];
    return pin;
}

#pragma mark - FiltersViewControllerDelegate methods

- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    self.currentFilters = filters;
    
    if ([self.currentSearchString length] == 0) {
        [self fetchBusinessesWithQuery:@"Restaurants" params:filters];
    } else {
        [self fetchBusinessesWithQuery:self.currentSearchString params:filters];
    }
}

#pragma mark - Private methods

- (UIView *)createLeftCalloutViewForBusiness:(Business *)business {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [imageView setImageWithURL:[NSURL URLWithString:business.imageURL]];
    imageView.layer.cornerRadius = 3;
    imageView.clipsToBounds = YES;
    
    return imageView;
}

- (void)clearMapView {
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)onFilterButton {
    FiltersViewController *fvc = [[FiltersViewController alloc] init];
    fvc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:fvc];
    
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onMapButton {
    self.tableView.hidden = YES;
    self.mapView.hidden = NO;
    [self setUpRightBarButtonWithTitle:@"List" action:@selector(onListButton)];
}

- (void)onListButton {
    self.tableView.hidden = NO;
    self.mapView.hidden = YES;
    [self setUpRightBarButtonWithTitle:@"Map" action:@selector(onMapButton)];
}

- (void)setUpRightBarButtonWithTitle:(NSString *)title action:(SEL)action {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:action];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithWhite:1 alpha:1];
}

- (void)updateMapView {
    self.mapView.region = self.mapRegion;
    
    [self.mapView addAnnotations:self.businesses];
}

- (MKCoordinateRegion)regionFromDictionary:(NSDictionary *)dictionary {
    double latitude = [[dictionary valueForKeyPath:@"center.latitude"] doubleValue];
    double longitude = [[dictionary valueForKeyPath:@"center.longitude"] doubleValue];
    double latitudeDelta = [[dictionary valueForKeyPath:@"span.latitude_delta"] doubleValue];
    double longitudeDelta = [[dictionary valueForKeyPath:@"span.longitude_delta"] doubleValue];
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    
    return MKCoordinateRegionMake(centerCoordinate, span);
}

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD show];
    
    // remove the annotations from the map before doing the search
    [self clearMapView];
    
    [self.client searchWithTerm:query
                         params:params
                          limit:self.currentSearchLimit
                         offset:self.currentSearchOffset
                        success:^(AFHTTPRequestOperation *operation, id response) {
//        NSLog(@"region: %@", response[@"region"]);
//        NSLog(@"business: %@", response[@"businesses"][0]);
        
        self.businesses = [Business businessesWithDictionaries:response[@"businesses"]];
        self.mapRegion = [self regionFromDictionary:response[@"region"]];
        
        [self.tableView reloadData];
        [self updateMapView];
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
