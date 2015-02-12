//
//  SwitchCell.h
//  Yelp
//
//  Created by Calvin Tuong on 2/12/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchCell;

@protocol SwitchCellDelegate <NSObject>

- (void)switchCell:(SwitchCell *)switchCell didUpdateValue:(BOOL)value;

@end

@interface SwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) BOOL on;
@property (weak, nonatomic) id<SwitchCellDelegate> delegate;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
