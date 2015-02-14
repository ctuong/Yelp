//
//  Business.m
//  Yelp
//
//  Created by Calvin Tuong on 2/11/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "Business.h"

#define kMilesPerMeter 0.000621371

@interface Business ()

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@property (nonatomic, strong) NSString *displayPhone;

@end

@implementation Business

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryNames = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryNames addObject:obj[0]];
        }];
        self.categories = [categoryNames componentsJoinedByString:@", "];
        
        self.name = dictionary[@"name"];
        self.imageURL = dictionary[@"image_url"];
        
        // parse out the address
        NSArray *addresses = [dictionary valueForKeyPath:@"location.address"];
        NSArray *neighborhoods = [dictionary valueForKeyPath:@"location.neighborhoods"];
        NSString *street;
        if (addresses.count == 0) {
            // no addresses
            street = @"";
        } else {
            street = addresses[0];
        }
        NSString *neighborhood;
        if (neighborhoods.count == 0) {
            // no neighborhoods
            self.address = street;
        } else {
            neighborhood = neighborhoods[0];
            if (addresses.count > 0) {
                // there is a street and a neighborhood
                self.address = [NSString stringWithFormat:@"%@, %@", street, neighborhood];
            } else {
                // only a neighborhood, no street
                self.address = neighborhood;
            }
        }
        
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageURL = dictionary[@"rating_img_url"];
        self.distance = [dictionary[@"distance"] integerValue] * kMilesPerMeter;
        self.displayPhone = dictionary[@"display_phone"];
        
        self.latitude = [[dictionary valueForKeyPath:@"location.coordinate.latitude"] doubleValue];
        self.longitude = [[dictionary valueForKeyPath:@"location.coordinate.longitude"] doubleValue];
    }
    
    return self;
}

+ (NSArray *)businessesWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *businesses = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Business *business = [[Business alloc] initWithDictionary:dictionary];
        
        [businesses addObject:business];
    }
    
    return businesses;
}

#pragma mark - MKAnnotation methods

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return self.displayPhone;
}

@end
