//
//  UBCARListTableViewController.m
//  UBCAR v4
//
//  Created by Nathan Sidles on 7/16/15.
//  Copyright (c) 2015 Nathan Sidles. All rights reserved.
//

#import "UBCARListTableViewController.h"
#import "AppDelegate.h"
#import "UBCARAggregate.h"

@interface UBCARListTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *selectedRow;

@end

@implementation UBCARListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self loadInitialData];
    
}

-(void)loadInitialData {
    
    self.UBCARAggregates = [[NSMutableArray alloc] init];
    self.UBCARLayers = [[NSMutableArray alloc] init];
    self.UBCARTours = [[NSMutableArray alloc] init];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"UBCARAggregate" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(type = %@)", @"layer"];
    [request setPredicate:pred ];
    NSArray *objects = [context executeFetchRequest:request error:&error];

    UBCARAggregate *item = [[UBCARAggregate alloc] init];
    item.name = @"All";
    item.type = @"layer";
    item.idNumber = 0;
    item.checked = 0;
    [self.UBCARLayers addObject: item];
    
    item = [[UBCARAggregate alloc] init];
    item.name = @"All";
    item.type = @"tour";
    item.idNumber = 0;
    item.checked = 0;
    [self.UBCARTours addObject: item];
    
    for(NSObject *object in objects) {
        UBCARAggregate *item = [[UBCARAggregate alloc] init];
        item.name = [object valueForKey:@"name"];
        item.type = [object valueForKey:@"type"];
        item.idNumber = [object valueForKey:@"idNumber"];
        item.checked = (bool)[object valueForKey:@"checked"];
        [self.UBCARLayers addObject: item];
    }
    
    [self.UBCARAggregates addObject: self.UBCARLayers];
    
    pred = [NSPredicate predicateWithFormat:@"(type = %@)", @"tour"];
    [request setPredicate:pred ];
    objects = [context executeFetchRequest:request error:&error];
    
    for(NSObject *object in objects) {
        UBCARAggregate *item = [[UBCARAggregate alloc] init];
        item.name = [object valueForKey:@"name"];
        item.type = [object valueForKey:@"type"];
        item.idNumber = [object valueForKey:@"idNumber"];
        item.checked = (bool)[object valueForKey:@"checked"];
        [self.UBCARTours addObject: item];
    }
    
    [self.UBCARAggregates addObject: self.UBCARTours];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.UBCARAggregates objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    UBCARAggregate *toDoItem = [[self.UBCARAggregates objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = toDoItem.name;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    if( section == 0 ) {
        return @"Layers";
    }
    if( section == 1 ) {
        return @"Tours";
    }
    
    return @"Layers";
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UBCARAggregate *toDoItem = [[self.UBCARAggregates objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"UBCARAggregate" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(checked = %@)", [[NSNumber alloc] initWithInt:1]];
    [request setPredicate:pred ];
    NSArray *objects = [context executeFetchRequest:request error:&error];
    for( NSManagedObject *object in objects ) {
        [object setValue: [[NSNumber alloc] initWithInt:0] forKey:@"checked"];
    }
    
    pred = [NSPredicate predicateWithFormat:@"(idNumber = %@)", toDoItem.idNumber];
    [request setPredicate:pred ];
    objects = [context executeFetchRequest:request error:&error];
    for( NSManagedObject *object in objects ) {
        [object setValue: [[NSNumber alloc] initWithInt:1] forKey:@"checked"];
    }
    
    [context save:&error];
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UBCARAggregate *toDoItem = [[self.UBCARAggregates objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    _selectedID = [toDoItem.idNumber stringValue];
    _selectedType = toDoItem.type;
    
}

@end
