//
//  HCKCoreDataManager.m
//  Hackerati_TimeTracker
//
//  Created by Ethan on 1/5/15.
//  Copyright (c) 2015 Hackerati. All rights reserved.
//

#import "HCKCoreDataManager.h"

static NSString *const INCoreDataModelFileName = @"CoreDataModel";

@interface HCKCoreDataManager  ()
@property (strong, nonatomic, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic, readwrite) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic, readwrite) NSManagedObjectContext *mainQueueContext;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *privateQueueContext;

@end

@implementation HCKCoreDataManager

+(instancetype)defaultStore{
    static HCKCoreDataManager *_defaultStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultStore = [[HCKCoreDataManager alloc]init];
    });
    return _defaultStore;
}

+ (NSManagedObjectContext*)mainQueueContext{
    return [[self defaultStore] mainQueueContext];
}

+ (NSManagedObjectContext*)privateQueueContext{
    return [[self defaultStore] privateQueueContext];
}

- (id)init{
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSavePrivateQueueContext:) name:NSManagedObjectContextDidSaveNotification object:[self privateQueueContext]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSaveMainQueueContext:) name:NSManagedObjectContextDidSaveNotification object:[self mainQueueContext]];
    }
    
    return self;
}

-(void) contextDidSavePrivateQueueContext:(NSNotification*)notification{
    @synchronized(self){
        [self.mainQueueContext performBlock:^{
            [self.mainQueueContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void) contextDidSaveMainQueueContext:(NSNotification*)notification{
    @synchronized(self){
        [self.privateQueueContext performBlock:^{
            [self.privateQueueContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (NSManagedObjectContext*)mainQueueContext{
    if (_mainQueueContext != nil) {
        return _mainQueueContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _mainQueueContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainQueueContext.persistentStoreCoordinator = coordinator;
    }
    return _mainQueueContext;
}

- (NSManagedObjectContext*)privateQueueContext{
    if (_privateQueueContext != nil) {
        return _privateQueueContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _privateQueueContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateQueueContext.persistentStoreCoordinator = coordinator;
    }
    return _privateQueueContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    
    if (_persistentStoreCoordinator != nil){
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError *error = nil;
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self persistentStoreURL] options:[self persistentStoreOptions] error:&error]){
        // TODO: Replace this implementation with code to handle the error appropriately.
        NSLog(@"Error adding persistent store. %@, %@", error, error.userInfo);
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel{
    
    if (_managedObjectModel != nil){
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:INCoreDataModelFileName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSURL *)persistentStoreURL{
    
    NSString *storeName = [INCoreDataModelFileName stringByAppendingString:@"HackeratiTimeTracker.sqlite"];
    NSURL *url = [[self appLibraryDirectory] URLByAppendingPathComponent:storeName];
    [self createPathToStoreFileIfNeccessary:url];
    return url;
}

- (NSURL *)appLibraryDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)createPathToStoreFileIfNeccessary:(NSURL *)urlForStore{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathToStore = [urlForStore URLByDeletingLastPathComponent];
    
    NSError *error = nil;
    
    [fileManager createDirectoryAtPath:[pathToStore path] withIntermediateDirectories:YES attributes:nil error:&error];
}

- (NSDictionary *)persistentStoreOptions{
    
    return @{NSInferMappingModelAutomaticallyOption: @YES, NSMigratePersistentStoresAutomaticallyOption: @YES, NSSQLitePragmasOption: @{@"synchronous": @"OFF"}};
}


- (void) saveMainQueueContext{
    NSManagedObjectContext *managedObjectContext = self.mainQueueContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Handle saveMainQueueContext Error\n");
        }
    }
}

- (void) savePrivateQueueContext{
    NSManagedObjectContext *managedObjectContext = self.privateQueueContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Handle savePrivateQueueContext Error\n");
        }
    }
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
