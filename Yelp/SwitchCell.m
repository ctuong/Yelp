//
//  SwitchCell.m
//  Yelp
//
//  Created by Calvin Tuong on 2/12/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "SwitchCell.h"

@interface SwitchCell ()

@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *dropdownArrowImageView;

- (IBAction)switchValueChanged:(id)sender;

@end

@implementation SwitchCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// not connected
- (IBAction)switchValueChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(switchCell:didUpdateValue:)]) {
        [self.delegate switchCell:self didUpdateValue:self.toggleSwitch.on];
    }
}

- (void)setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    _on = on;
    [self.toggleSwitch setOn:on animated:animated];
}

- (void)setCollapsed:(BOOL)collapsed {
    // if collapsed, hide the switch and show the dropdown arrow
    if (collapsed) {
        self.toggleSwitch.hidden = YES;
        self.dropdownArrowImageView.hidden = NO;
    } else {
        self.dropdownArrowImageView.hidden = YES;
        self.toggleSwitch.hidden = NO;
    }
}

@end
