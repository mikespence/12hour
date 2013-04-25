//
//  MainViewController.m
//  ScoreSaver
//
//  Created by Cameron Cooke on 24/04/2013.
//  Copyright (c) 2013 Cameron Cooke. All rights reserved.
//

#import "MainViewController.h"
#import "Person.h"
#import <objc/runtime.h>


@interface MainViewController ()
@property (nonatomic) NSMutableArray *people;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end


static char const * const alertTagKey = "alertTag";


@implementation MainViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _people = [@[] mutableCopy];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadPeople];
}


- (IBAction)addButtonWasTouched:(UIBarButtonItem *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Player's Name"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Add Person", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    alert.tag = 0;
    [alert show];
}

- (IBAction)refreshButtonWasTouched:(UIBarButtonItem *)sender
{
    [self loadPeople];
}


# pragma mark -
# pragma mark Data

- (void)loadPeople
{
    if (self.managedObjectContext == nil) {
        return;
    }
    
    [self.people removeAllObjects];
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    
    // sorting
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"goals" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // perform query
    NSError *error = nil;
    NSArray *people = [moc executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"Error getting stored people: %@", error);
        return;
    }
    
    self.people = [people mutableCopy];
    
    [self.collectionView reloadData];
}


- (void)deletePerson:(Person *)person
{
    [self.managedObjectContext deleteObject:person];
    
    // save
    NSError *e = nil;
    [self.managedObjectContext save:&e];
    if (e != nil) {
        NSLog(@"Error deleting person: %@", e);
        return;
    }
    
    // remove from array of people
    [self.people removeObject:person];
    
    // attempt to find cell
    NSMutableArray *indexPathsToDelete = [@[] mutableCopy];
    for (NameCell *cell in self.collectionView.visibleCells) {
        if (cell.person == person) {
            [indexPathsToDelete addObject:[self.collectionView indexPathForCell:cell]];
            break;
        }
    }
    
    [self.collectionView deleteItemsAtIndexPaths:indexPathsToDelete];
}


# pragma mark -
# pragma mark UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.people.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"NameCell";
    
    Person *person = self.people[indexPath.item];
    
    NameCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.delegate = self;
    cell.contentView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.200];
    [cell setPerson:person];
    
    if (cell.gestureRecognizers.count == 0) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
        [panGesture addTarget:self action:@selector(panGestureWasPerformed:)];
        panGesture.delegate = self;
        [cell.contentView addGestureRecognizer:panGesture];
    }
    
    return cell;
}


# pragma mark -
# pragma mark Gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (void)panGestureWasPerformed:(UIPanGestureRecognizer *)gesture
{
    NSLog(@"Panning");
    if (![gesture.view.superview isKindOfClass:[NameCell class]]) {
        return;
    }
    
    static CGPoint originalCenter;
    static UIView *v;
    static CGFloat const width = 60.0f;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        originalCenter = gesture.view.center;
        
        UIView  *superview = gesture.view.superview;
        v = [[UIView alloc] initWithFrame:CGRectMake(superview.bounds.size.width, 0, 0, superview.bounds.size.height)];
        v.backgroundColor = [UIColor colorWithRed:0.752 green:0.025 blue:0.000 alpha:1.000];
        v.clipsToBounds = YES;
        [superview addSubview:v];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trash.png"]];
        iconImageView.frame = CGRectMake(0, (v.bounds.size.height / 2) - 10.5f, 16, 21);
        iconImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [v addSubview:iconImageView];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translate = [gesture translationInView:gesture.view.superview];
        
        CGFloat x = originalCenter.x + translate.x;
        CGFloat diff = originalCenter.x-x;
        if (diff > width || diff <= 0) {
            return;
        }
        
        CGRect vFrame = v.frame;
        vFrame.size.width = diff;
        vFrame.origin.x = v.superview.bounds.size.width - diff;
        v.frame = vFrame;
               
        gesture.view.center = CGPointMake(x, originalCenter.y);
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed ||
        gesture.state == UIGestureRecognizerStateCancelled)
    {
        [UIView animateWithDuration:0.4f animations:^{
            gesture.view.center = originalCenter;
            
            CGRect vFrame = v.frame;
            vFrame.size.width = 0;
            vFrame.origin.x = v.superview.bounds.size.width;
            v.frame = vFrame;
        }];
        
        CGPoint translate = [gesture translationInView:gesture.view.superview];        
        CGFloat x = originalCenter.x + translate.x;
        CGFloat diff = originalCenter.x-x;
        
        if (diff >= width) {
            NameCell *cell = (NameCell *)gesture.view.superview;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to delete %@?", cell.person.name]
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Delete Person", nil];
            alert.tag = 1;            
            objc_setAssociatedObject(alert, alertTagKey, cell.person, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [alert show];
        }
    }
}


# pragma mark -
# pragma mark UIAlertView

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag != 0) {
        return YES;
    }
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    return textField.text.length > 0;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        
        // new person alert
        
        if (buttonIndex == 1) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            
            Person *newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
            newPerson.name = textField.text;
            newPerson.goals = @0;
            
            // save
            NSError *e = nil;
            [self.managedObjectContext save:&e];
            if (e != nil) {
                NSLog(@"Error storing person: %@", e);
                return;
            }
            
            [self loadPeople];
        }
    }
    else if (alertView.tag == 1) {
        
        // delete person alert
        
        if (buttonIndex == 1) {
            Person *person = objc_getAssociatedObject(alertView, alertTagKey);
            [self deletePerson:person];
        }
    }
}


# pragma mark -
# pragma mark NameCellDelegate

- (void)nameCell:(NameCell *)nameCell goalValueDidChangeWithNewValue:(double)value
{
    nameCell.person.goals = @(value);
    [nameCell updateUILabels];
    
    // save
    NSError *e = nil;
    [self.managedObjectContext save:&e];
    if (e != nil) {
        NSLog(@"Error storing person: %@", e);
        return;
    }
}


@end
