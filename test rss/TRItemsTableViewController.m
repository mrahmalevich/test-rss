//
//  TRItemsTableViewController.m
//  test rss
//
//  Created by Mikhail Rakhmalevich on 12.06.14.
//  Copyright (c) 2014 Mikhail Rahmalevich. All rights reserved.
//

#import "TRItemsTableViewController.h"
#import "TRItemViewController.h"

@interface TRItemsTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) NSFetchedResultsController *itemsFetchController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation TRItemsTableViewController

#pragma mark - Initialization
- (instancetype)initWithChannel:(Channel *)channel
{
    if (self = [super init]) {
        self.channel = channel;
        self.itemsFetchController = [Item MR_fetchAllSortedBy:@"pubDate" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"channel = %@", channel] groupBy:nil delegate:self];
        self.dateFormatter = [NSDateFormatter new];
        self.dateFormatter.dateStyle = NSDateFormatterFullStyle;
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Items";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [_itemsFetchController objectAtIndexPath:indexPath];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [_dateFormatter stringFromDate:item.pubDate];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = _itemsFetchController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseId = @"itemsTableReuseID";
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
    
    Item *item = _itemsFetchController.fetchedObjects[indexPath.row];
    TRItemViewController *itemController = [[TRItemViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:itemController animated:YES];
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
