//
//  TRFeedsTableViewController.m
//  test rss
//
//  Created by Mikhail Rakhmalevich on 12.06.14.
//  Copyright (c) 2014 Mikhail Rahmalevich. All rights reserved.
//

#import "TRFeedsTableViewController.h"
#import "TRItemsTableViewController.h"
#import "TRFeedsController.h"
#import "MBProgressHUD.h"
#import "UIAlertView+Blocks.h"

@interface TRFeedsTableViewController () <TRFeedControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) TRFeedsController *feedsDataController;
@property (nonatomic, strong) NSFetchedResultsController *feedsFetchController;

@end

@implementation TRFeedsTableViewController

#pragma mark - Initialization
- (instancetype)init
{
    if (self = [super init]) {
        self.feedsDataController = [[TRFeedsController alloc] initWithDelegate:self];
        self.feedsFetchController = [Channel MR_fetchAllSortedBy:@"title" ascending:YES withPredicate:nil groupBy:nil delegate:self];
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.title = @"Channels";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefresh:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAdd:)];
}

#pragma mark - Private
- (void)actionRefresh:(UIBarButtonItem *)sender
{
    [self.feedsDataController refreshFeeds];
}

- (void)actionAdd:(UIBarButtonItem *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please enter URL of RSS feed" message:nil cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:nil];
    RIButtonItem *doneItem = [RIButtonItem itemWithLabel:@"Done" action:^{
        BOOL feedAdded = [self.feedsDataController addFeedWithPath:[alertView textFieldAtIndex:0].text];
        if (!feedAdded) {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"URL is invalid" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [errorAlertView show];
        }
    }];
    [alertView addButtonItem:doneItem];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Channel *channel = [_feedsFetchController objectAtIndexPath:indexPath];
    cell.textLabel.text = channel.title ?: channel.link;
    cell.detailTextLabel.text = channel.subtitle ?: @"Data isn't loaded";
}

#pragma mark - TRFeedController delegate
- (void)feedsControllerWillStardLoading:(TRFeedsController *)controller
{
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
}

- (void)feedsControllerDidEndLoading:(TRFeedsController *)controller withError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = _feedsFetchController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseId = @"feedsTableReuseID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Channel *channel = _feedsFetchController.fetchedObjects[indexPath.row];
    if ([channel.items count] > 0) {
        TRItemsTableViewController *itemsController = [[TRItemsTableViewController alloc] initWithChannel:channel];
        [self.navigationController pushViewController:itemsController animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Channel *channel = _feedsFetchController.fetchedObjects[indexPath.row];
        [channel MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark - NSFetchedResultsController delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
