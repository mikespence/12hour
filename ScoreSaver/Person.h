//
//  Scores.h
//  ScoreSaver
//
//  Created by Cameron Cooke on 24/04/2013.
//  Copyright (c) 2013 Cameron Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSNumber * goals;
@property (nonatomic, retain) NSString * name;

@end
