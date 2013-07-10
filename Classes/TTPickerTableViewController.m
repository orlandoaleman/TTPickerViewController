//
//  TTPickerTableViewController.m
//
//  Created by Orlando Aleman Ortiz on 08/07/13.
//  Copyright (c) 2013 orlandoaleman.com. All rights reserved.
//

#import "TTPickerTableViewController.h"

@interface TTPickerTableViewController () {
    NSMutableArray *selectedRows_;
}
@end


@implementation TTPickerTableViewController

@synthesize selectedRows = selectedRows_;

- (void)localInit
{
    selectedRows_ = [NSMutableArray array];
    _allowsMultipleSelection = NO;
}


- (id)init
{
    self = [super init];
    if (self) {
        [self localInit];
    }
    return self;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self localInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self localInit];
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self localInit];
    }
    return self;
}


#pragma mark - Setters, getters

- (void)setSelectedRows:(NSArray *)selectedRows
{
    selectedRows_ = [NSMutableArray arrayWithArray:selectedRows];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createMenu];
    [self createView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // La condición del assert equivale ¬(selectedRows.count > 1 && !self.allowsMultipleSelection)
    NSAssert(selectedRows_.count <= 1 || self.allowsMultipleSelection, @"selectedRows.count > 1 con selección simple");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)createMenu
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
}


- (void)createView
{
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(numberOfRowsInPickerTableViewController:)]) {
        return [self.delegate numberOfRowsInPickerTableViewController:self];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([self.delegate respondsToSelector:@selector(pickerTableViewController:tableView:cellForRowAt:)]) {
        cell = [self.delegate pickerTableViewController:self
                                              tableView:tableView
                                           cellForRowAt:indexPath.row];
    
        cell.accessoryType = [selectedRows_ containsObject:@(indexPath.row)] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [selectedRows_ removeObject:@(indexPath.row)];
    }
    else {
        if (!self.allowsMultipleSelection) {
            NSNumber *lastObj = [selectedRows_ lastObject];
            if (lastObj) {
                [selectedRows_ removeLastObject];
                [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:[lastObj integerValue] inSection:0]] withRowAnimation:NO];
            }
        }

        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedRows_ addObject:@(indexPath.row)];
    
        if ([self.delegate respondsToSelector:@selector(pickerTableViewController:didSelectRow:)]) {
            [self.delegate pickerTableViewController:self didSelectRow:indexPath.row];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Actions

- (void)cancelAction
{
    [self.delegate pickerTableViewControllerDidCancel:self];
}


- (void)doneAction
{
    [self.delegate pickerTableViewController:self didFinishWithSelectedRows:selectedRows_];
}


@end