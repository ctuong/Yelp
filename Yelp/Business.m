//
//  Business.m
//  Yelp
//
//  Created by Calvin Tuong on 2/11/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "Business.h"

#define kMilesPerMeter 0.000621371

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
        // TODO error handling for businesses with no addresses or neighborhoods
        NSString *street = [dictionary valueForKeyPath:@"location.address"][0];
        NSString *neighborhood = [dictionary valueForKeyPath:@"location.neighborhoods"][0];
        self.address = [NSString stringWithFormat:@"%@, %@", street, neighborhood];
        
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageURL = dictionary[@"rating_img_url"];
        self.distance = [dictionary[@"distance"] integerValue] * kMilesPerMeter;
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

@end
