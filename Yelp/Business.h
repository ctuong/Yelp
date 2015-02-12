//
//  Business.h
//  Yelp
//
//  Created by Calvin Tuong on 2/11/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface Business : NSObject

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ratingImageURL;
@property (nonatomic, assign) NSInteger numReviews;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, assign) CGFloat distance;

+ (NSArray *)businessesWithDictionaries:(NSArray *)dictionaries;

@end
