//
//  FiltersViewController.m
//  Yelp
//
//  Created by Calvin Tuong on 2/12/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"
#import <QuartzCore/QuartzCore.h>

#define kSortBySectionIndex 0
#define kDistanceSectionIndex 1
#define kDealsSectionIndex 2
#define kCategoriesSectionIndex 3

// this must be less than the total number of categories available
#define kInitialNumCategories 1

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;

// an array of section headers
@property (nonatomic, strong) NSArray *filterSections;
// an array of arrays of strings, each representing one section value
@property (nonatomic, strong) NSArray *filterSectionValues;

// the index of the selected option for sort by
@property (nonatomic, assign) NSInteger selectedSortByIndex;
// the index of the selected option for distance
@property (nonatomic, assign) NSInteger selectedDistanceIndex;
// whether deals is on or off
@property (nonatomic, assign) BOOL dealsOn;

@property (nonatomic, assign) BOOL isSortByCollapsed;
@property (nonatomic, assign) BOOL isDistanceCollapsed;
@property (nonatomic, assign) BOOL isCategoryListExpanded;

- (void)initCategories;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        [self initCategories];
        [self initFilterSections];
        [self initFilterSectionValues];
        
        self.isSortByCollapsed = YES;
        self.isDistanceCollapsed = YES;
        self.isCategoryListExpanded = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set up the title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Filters";
    titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    // set up the navigation bar
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    
    // set up cancel button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    cancelButton.tintColor = [UIColor colorWithWhite:1 alpha:1];
    [cancelButton addTarget:self action:@selector(onCancelButton) forControlEvents:UIControlEventAllTouchEvents];
    [cancelButton sizeToFit];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    // set up search button
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [searchButton setTitle:@"Search" forState:UIControlStateNormal];
    searchButton.titleLabel.font = [UIFont systemFontOfSize:14];
    searchButton.tintColor = [UIColor colorWithWhite:1 alpha:1];
    [searchButton addTarget:self action:@selector(onSearchButton) forControlEvents:UIControlEventAllTouchEvents];
    [searchButton sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    // set up the table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filterSections.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.filterSections[section];
    [titleLabel sizeToFit];
    
    // center the title label in the header UIView
    CGFloat titleLabelY = header.frame.size.height / 2 - titleLabel.frame.size.height / 2;
    titleLabel.frame = CGRectMake(8, titleLabelY, header.frame.size.width, titleLabel.frame.size.height);
    
    [header addSubview:titleLabel];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    
    // change the default margin of the table divider length
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 3, 0, 3);
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    if (indexPath.section == kSortBySectionIndex && self.isSortByCollapsed) {
        cell.titleLabel.text = self.filterSectionValues[indexPath.section][self.selectedSortByIndex];
        cell.on = YES;
        [cell setCollapsed:YES];
    } else if (indexPath.section == kDistanceSectionIndex && self.isDistanceCollapsed) {
        cell.titleLabel.text = self.filterSectionValues[indexPath.section][self.selectedDistanceIndex];
        cell.on = YES;
        [cell setCollapsed:YES];
    } else if ([self indexPathIsShowAllCategories:indexPath]) {
        cell.titleLabel.text = @"Show All";
        [cell showLabelOnly];
    } else {
        cell.titleLabel.text = self.filterSectionValues[indexPath.section][indexPath.row];
        cell.on = [self switchIsOnForCellAtIndexPath:indexPath];
        [cell setCollapsed:NO];
    }
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

// for "sort by" or "distance":
// - if the section was collapsed, expand it
// - else if the cell was already on, collapse the section
// - else if it was off, turn it on, turn the others off, and collapse the section
// for "deals" or "categories", just turn it off
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL switchIsOn = [self switchIsOnForCellAtIndexPath:indexPath];
    SwitchCell *currentCell = (SwitchCell *)[tableView cellForRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case kSortBySectionIndex:
            if (self.isSortByCollapsed) {
                self.isSortByCollapsed = NO;
                [self reloadSection:indexPath.section];
            } else {
                if (!switchIsOn) {
                    [currentCell setOn:YES animated:YES];
                    SwitchCell *previouslySelectedCell = (SwitchCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedSortByIndex inSection:indexPath.section]];
                    if (previouslySelectedCell) {
                        // in case the cell was reused
                        [previouslySelectedCell setOn:NO animated:YES];
                    }
                    self.selectedSortByIndex = indexPath.row;
                }
                self.isSortByCollapsed = YES;
                [self reloadSection:indexPath.section];
            }
            break;
        case kDistanceSectionIndex:
            if (self.isDistanceCollapsed) {
                self.isDistanceCollapsed = NO;
                [self reloadSection:indexPath.section];
            } else {
                if (!switchIsOn) {
                    [currentCell setOn:YES animated:YES];
                    SwitchCell *previouslySelectedCell = (SwitchCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedDistanceIndex inSection:indexPath.section]];
                    if (previouslySelectedCell) {
                        // in case the cell was reused
                        [previouslySelectedCell setOn:NO animated:YES];
                    }
                    self.selectedDistanceIndex = indexPath.row;
                }
                self.isDistanceCollapsed = YES;
                [self reloadSection:indexPath.section];
            }
            break;
        case kDealsSectionIndex:
            [currentCell setOn:!switchIsOn animated:YES];
            self.dealsOn = !switchIsOn;
            break;
        case kCategoriesSectionIndex:
            if ([self indexPathIsShowAllCategories:indexPath]) {
                // pressed the "Show All" cell
                self.isCategoryListExpanded = YES;
                [self reloadSection:indexPath.section];
            } else {
                [currentCell setOn:!switchIsOn animated:YES];
                if (!switchIsOn) {
                    [self.selectedCategories addObject:self.categories[indexPath.row]];
                } else {
                    [self.selectedCategories removeObject:self.categories[indexPath.row]];
                }
            }
            break;
        default:
            break;
    }
}

#pragma mark - SwitchCellDelegate methods

- (void)switchCell:(SwitchCell *)switchCell didUpdateValue:(BOOL)value {
}

#pragma mark - Private methods

- (void)reloadSection:(NSInteger)section {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kSortBySectionIndex:
            if (self.isSortByCollapsed) return 1;
            return ((NSArray *)self.filterSectionValues[section]).count;
        case kDistanceSectionIndex:
            if (self.isDistanceCollapsed) return 1;
            return ((NSArray *)self.filterSectionValues[section]).count;
        case kDealsSectionIndex:
            return ((NSArray *)self.filterSectionValues[section]).count;
        case kCategoriesSectionIndex:
            if (self.isCategoryListExpanded) {
                return ((NSArray *)self.filterSectionValues[section]).count;
            }
            return kInitialNumCategories + 1; // 1 extra for "Show All" cell
        default:
            return 0;
    }
}

- (BOOL)indexPathIsShowAllCategories:(NSIndexPath *)indexPath {
    return !self.isCategoryListExpanded && indexPath.section == kCategoriesSectionIndex && indexPath.row == kInitialNumCategories;
}

- (BOOL)switchIsOnForCellAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kSortBySectionIndex:
            return indexPath.row == self.selectedSortByIndex;
        case kDistanceSectionIndex:
            return indexPath.row == self.selectedDistanceIndex;
        case kDealsSectionIndex:
            return self.dealsOn;
        case kCategoriesSectionIndex:
            return [self.selectedCategories containsObject:self.categories[indexPath.row]];
        default:
            return NO;
    }
}

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    [filters setObject:[[NSNumber alloc] initWithInteger:self.selectedSortByIndex] forKey:@"sort"];
    
    if (self.selectedDistanceIndex > 0) {
        [filters setObject:[[NSNumber alloc] initWithInteger:[self getSearchRadius]] forKey:@"radius_filter"];
    }
    
    [filters setObject:[self getDealsFilter] forKey:@"deals_filter"];
    
    if (self.selectedCategories.count > 0) {
        [filters setObject:[self getCategoryFilterString] forKey:@"category_filter"];
    }
    
    return filters;
}

- (NSString *)getDealsFilter {
    if (self.dealsOn) {
        return @"true";
    } else {
        return @"false";
    }
}

// get the distance in meters based on the selected index
- (NSInteger)getSearchRadius {
    switch (self.selectedDistanceIndex) {
        case 1:
            return 482; // 0.3 miles
        case 2:
            return 1609; // 1 mile
        case 3:
            return 8046; // 5 miles
        case 4:
        default:
            return 32186; // 20 miles
    }
}

- (NSString *)getCategoryFilterString {
    NSMutableArray *categoryNames = [NSMutableArray array];
    for (NSDictionary *category in self.selectedCategories) {
        [categoryNames addObject:category[@"code"]];
    }
    return [categoryNames componentsJoinedByString:@","];
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSearchButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCategories {
    //    self.categories =
    //    @[@{@"name" : @"Afghan", @"code": @"afghani" },
    //      @{@"name" : @"African", @"code": @"african" },
    //      @{@"name" : @"American, New", @"code": @"newamerican" }];
    self.categories =
    @[@{@"name" : @"Afghan", @"code": @"afghani" },
      @{@"name" : @"African", @"code": @"african" },
      @{@"name" : @"American, New", @"code": @"newamerican" },
      @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
      @{@"name" : @"Argentine", @"code": @"argentine" },
      @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
      @{@"name" : @"Australian", @"code": @"australian" },
      @{@"name" : @"Austrian", @"code": @"austrian" },
      @{@"name" : @"Barbeque", @"code": @"bbq" },
      @{@"name" : @"Basque", @"code": @"basque" },
      @{@"name" : @"Belgian", @"code": @"belgian" },
      @{@"name" : @"Bistros", @"code": @"bistros" },
      @{@"name" : @"Brasseries", @"code": @"brasseries" },
      @{@"name" : @"Brazilian", @"code": @"brazilian" },
      @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
      @{@"name" : @"British", @"code": @"british" },
      @{@"name" : @"Buffets", @"code": @"buffets" },
      @{@"name" : @"Burgers", @"code": @"burgers" },
      @{@"name" : @"Burmese", @"code": @"burmese" },
      @{@"name" : @"Cafes", @"code": @"cafes" },
      @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
      @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
      @{@"name" : @"Cambodian", @"code": @"cambodian" },
      @{@"name" : @"Caribbean", @"code": @"caribbean" },
      @{@"name" : @"Chilean", @"code": @"chilean" },
      @{@"name" : @"Chinese", @"code": @"chinese" },
      @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
      @{@"name" : @"Creperies", @"code": @"creperies" },
      @{@"name" : @"Cuban", @"code": @"cuban" },
      @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
      @{@"name" : @"Danish", @"code": @"danish" },
      @{@"name" : @"Delis", @"code": @"delis" },
      @{@"name" : @"Diners", @"code": @"diners" },
      @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
      @{@"name" : @"Fast Food", @"code": @"hotdogs" },
      @{@"name" : @"Filipino", @"code": @"filipino" },
      @{@"name" : @"Fondue", @"code": @"fondue" },
      @{@"name" : @"Food Court", @"code": @"food_court" },
      @{@"name" : @"Food Stands", @"code": @"foodstands" },
      @{@"name" : @"French", @"code": @"french" },
      @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
      @{@"name" : @"German", @"code": @"german" },
      @{@"name" : @"Greek", @"code": @"greek" },
      @{@"name" : @"Halal", @"code": @"halal" },
      @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
      @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
      @{@"name" : @"Hot Pot", @"code": @"hotpot" },
      @{@"name" : @"Indian", @"code": @"indpak" },
      @{@"name" : @"Indonesian", @"code": @"indonesian" },
      @{@"name" : @"International", @"code": @"international" },
      @{@"name" : @"Irish", @"code": @"irish" },
      @{@"name" : @"Israeli", @"code": @"israeli" },
      @{@"name" : @"Italian", @"code": @"italian" },
      @{@"name" : @"Japanese", @"code": @"japanese" },
      @{@"name" : @"Jewish", @"code": @"jewish" },
      @{@"name" : @"Kebab", @"code": @"kebab" },
      @{@"name" : @"Korean", @"code": @"korean" },
      @{@"name" : @"Kosher", @"code": @"kosher" },
      @{@"name" : @"Laotian", @"code": @"laotian" },
      @{@"name" : @"Latin American", @"code": @"latin" },
      @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
      @{@"name" : @"Malaysian", @"code": @"malaysian" },
      @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
      @{@"name" : @"Mexican", @"code": @"mexican" },
      @{@"name" : @"Mongolian", @"code": @"mongolian" },
      @{@"name" : @"Moroccan", @"code": @"moroccan" },
      @{@"name" : @"New Zealand", @"code": @"newzealand" },
      @{@"name" : @"Night Food", @"code": @"nightfood" },
      @{@"name" : @"Pakistani", @"code": @"pakistani" },
      @{@"name" : @"Persian/Iranian", @"code": @"persian" },
      @{@"name" : @"Peruvian", @"code": @"peruvian" },
      @{@"name" : @"Pizza", @"code": @"pizza" },
      @{@"name" : @"Polish", @"code": @"polish" },
      @{@"name" : @"Portuguese", @"code": @"portuguese" },
      @{@"name" : @"Romanian", @"code": @"romanian" },
      @{@"name" : @"Russian", @"code": @"russian" },
      @{@"name" : @"Salad", @"code": @"salad" },
      @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
      @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
      @{@"name" : @"Scottish", @"code": @"scottish" },
      @{@"name" : @"Seafood", @"code": @"seafood" },
      @{@"name" : @"Singaporean", @"code": @"singaporean" },
      @{@"name" : @"Soul Food", @"code": @"soulfood" },
      @{@"name" : @"Spanish", @"code": @"spanish" },
      @{@"name" : @"Steakhouses", @"code": @"steak" },
      @{@"name" : @"Sushi Bars", @"code": @"sushi" },
      @{@"name" : @"Swedish", @"code": @"swedish" },
      @{@"name" : @"Swiss Food", @"code": @"swissfood" },
      @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
      @{@"name" : @"Tapas Bars", @"code": @"tapas" },
      @{@"name" : @"Thai", @"code": @"thai" },
      @{@"name" : @"Turkish", @"code": @"turkish" },
      @{@"name" : @"Vegan", @"code": @"vegan" },
      @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
      @{@"name" : @"Venison", @"code": @"venison" },
      @{@"name" : @"Vietnamese", @"code": @"vietnamese" }];
}

- (void)initFilterSections {
    self.filterSections = @[@"Sort by", @"Distance", @"Deals", @"Categories"];
}

- (void)initFilterSectionValues {
    self.filterSectionValues =
    @[@[@"Best Match", @"Distance", @"Rating"],
      @[@"Best Match", @"0.3 miles", @"1 mile", @"5 miles", @"20 miles"],
      @[@"Offering a Deal"],
      [self getCategoryNames]];
}

- (NSArray *)getCategoryNames {
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:self.categories.count];
    [self.categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [names addObject:obj[@"name"]];
    }];
    return names;
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
