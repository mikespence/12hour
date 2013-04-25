//
//  NameCell.m
//  ScoreSaver
//
//  Created by Cameron Cooke on 24/04/2013.
//  Copyright (c) 2013 Cameron Cooke. All rights reserved.
//

#import "NameCell.h"

@interface NameCell ()
@property (nonatomic, readwrite) Person *person;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@end


@implementation NameCell


- (void)setPerson:(Person *)person
{
    _person = person;
    
    self.stepper.value = [person.goals doubleValue];
    [self updateUILabels];
}


- (void)updateUILabels
{
    self.nameLabel.text = self.person.name;
    self.scoreLabel.text = [NSString stringWithFormat:@"%i", [self.person.goals integerValue]];
}


- (IBAction)stepperValueChanged:(UIStepper *)sender
{
    [self.delegate nameCell:self goalValueDidChangeWithNewValue:sender.value];
}


@end
