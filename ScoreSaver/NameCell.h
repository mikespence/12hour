//
//  NameCell.h
//  ScoreSaver
//
//  Created by Cameron Cooke on 24/04/2013.
//  Copyright (c) 2013 Cameron Cooke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"


@protocol NameCellDelegate;


@interface NameCell : UICollectionViewCell
@property (nonatomic, readonly) Person *person;
@property (nonatomic, weak) id<NameCellDelegate>delegate;

- (void)setPerson:(Person *)person;
- (void)updateUILabels;
@end


@protocol NameCellDelegate <NSObject>
- (void)nameCell:(NameCell *)nameCell goalValueDidChangeWithNewValue:(double)value;
@end
