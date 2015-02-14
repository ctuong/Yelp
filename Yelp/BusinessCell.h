//
//  BusinessCell.h
//  Yelp
//
//  Created by Calvin Tuong on 2/11/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"

@interface BusinessCell : UITableViewCell

@property (nonatomic, strong) Business *business;
@property (nonatomic, assign) NSInteger row;

@end
