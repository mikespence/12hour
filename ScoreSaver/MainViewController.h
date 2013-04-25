//
//  MainViewController.h
//  ScoreSaver
//
//  Created by Cameron Cooke on 24/04/2013.
//  Copyright (c) 2013 Cameron Cooke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NameCell.h"


@interface MainViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, NameCellDelegate, UIGestureRecognizerDelegate>
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@end