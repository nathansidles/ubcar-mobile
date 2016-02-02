//
//  AppDelegate.m
//  UBCAR v4
//
//  Created by Nathan Sidles on 7/16/15.
//  Copyright (c) 2015 Nathan Sidles. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSError *error;
    
    NSURL *UBCARURL = [NSURL URLWithString:@"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_download_json&ubcar_aggregates"];
    NSString *jsonString = [NSString stringWithContentsOfURL:UBCARURL encoding:NSASCIIStringEncoding error:&error];
    
    if( jsonString != nil ) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        NSMutableArray *layers = [json[0] valueForKey:@"aggregates"];
        NSMutableArray *tours = [json[1] valueForKey:@"aggregates"];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"UBCARAggregate" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        for (NSManagedObject *managedObject in objects) {
            [context deleteObject:managedObject];
        }
        
        for( NSObject *layer in layers ) {
            NSManagedObject *newAggregate = [NSEntityDescription insertNewObjectForEntityForName:@"UBCARAggregate" inManagedObjectContext:context];
            [newAggregate setValue:[layer valueForKey:@"name"] forKey:@"name"];
            [newAggregate setValue:@"layer" forKey:@"type"];
            [newAggregate setValue:[[NSNumber alloc] initWithInt:0] forKey:@"checked"];
            [newAggregate setValue:[layer valueForKey:@"id"] forKey:@"idNumber"];
        }
        
        for( NSObject *tour in tours ) {
            NSManagedObject *newAggregate = [NSEntityDescription insertNewObjectForEntityForName:@"UBCARAggregate" inManagedObjectContext:context];
            [newAggregate setValue:[tour valueForKey:@"name"] forKey:@"name"];
            [newAggregate setValue:@"tour" forKey:@"type"];
            [newAggregate setValue:[[NSNumber alloc] initWithInt:0] forKey:@"checked"];
            [newAggregate setValue:[tour valueForKey:@"id"] forKey:@"idNumber"];
        }
        
        [context save:&error];
    
        NSURL *UBCARURL2 = [NSURL URLWithString:@"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_download_json"];
        if( objects.count != 0 ) {
            UBCARURL2 = [NSURL URLWithString:[NSString stringWithFormat:@"http://lfs-mpd.sites.olt.ubc.ca/test-page/?ubcar_download_json&ubcar_%@s[]=%@", [(NSManagedObject*)objects[0] valueForKey:@"type"], [(NSManagedObject*)objects[0] valueForKey:@"idNumber"]]];
        }
        NSString *jsonString2 = [NSString stringWithContentsOfURL:UBCARURL2 encoding:NSASCIIStringEncoding error:&error];
        const char *saves = [jsonString2 cStringUsingEncoding:NSASCIIStringEncoding];
        NSData *data = [[NSData alloc] initWithBytes:saves length:jsonString2.length];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile1.js"];
        [data writeToFile:appFile atomically:YES];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"You must be connected to the internet to use this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "NathanCorp.UBCAR_v4" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UBCAR_v4" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"UBCAR_v4.sqlite"];
    NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
        }
    }
}

@end
