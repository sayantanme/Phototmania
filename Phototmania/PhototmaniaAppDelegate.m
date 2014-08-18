//
//  PhototmaniaAppDelegate.m
//  Phototmania
//
//  Created by Sayantan Chakraborty on 15/08/14.
//  Copyright (c) 2014 Sayantan Chakraborty. All rights reserved.
//

#import "PhototmaniaAppDelegate.h"
#import "Flickr Fetcher/FlickrFetcher.h"
#import "Photo.h"
#import "Photo+Flickr.h"
#import "PhotoDatabaseAvailability.h"

@interface PhototmaniaAppDelegate() <NSURLSessionDownloadDelegate>
@property (strong, nonatomic)UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *photoDatabaseContext;
@property(copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (strong, nonatomic) NSTimer *flickrForegroundFetchTimer;
@end

//name of Flickr Fetching background download session;
#define FLICKR_FETCH @"Flickr Just uploaded Fetch"

//how often (in secs) we fetch flickr photos if we are in the foreground
#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)
// how long we'll wait for a Flickr fetch to return when we're in the background
#define BACKGROUND_FLICKR_FETCH_TIMEOUT (10)

@implementation PhototmaniaAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
    NSString *documentName = @"FlickrDb";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc]initWithFileURL:url];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //check if file exists, if it exists open it if it doesnt create it
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if(success) [self documentIsReady];
            else NSLog(@"cldnt open document at %@",url);
        }];
    }else{
        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success) [self documentIsReady];
            else NSLog(@"cldnt create document at %@",url);
        }];
    }
    return YES;
}

-(void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext
{
    _photoDatabaseContext = photoDatabaseContext;
    
    [NSTimer scheduledTimerWithTimeInterval:20*60 target:self selector:@selector(startFlickrFetch:) userInfo:nil repeats:YES];
    NSDictionary *userInfo = self.photoDatabaseContext ? @{PhotoDatabseAvailabilityContext : self.photoDatabaseContext} : nil;
    [[NSNotificationCenter defaultCenter]postNotificationName:PhotoDatabseAvailabilityNotification object:self userInfo:userInfo];
}

-(void)documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        self.photoDatabaseContext = self.document.managedObjectContext;
        [self startFlickrFetch];
    }
}

-(void)startFlickrFetch:(NSTimer *)timer
{
    [self startFlickrFetch];
}
-(void)startFlickrFetch
{
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        }else{
            for(NSURLSessionDownloadTask *task in downloadTasks){
                [task resume];
            }
        }
    }];
}

-(NSURLSession *)flickrDownloadSession
{
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken,^{
        
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            urlSessionConfig.allowsCellularAccess = NO ;
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:nil];
        });
    }
    return _flickrDownloadSession;
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)localFile
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        [self loadFlickrPhotosFromLocalURL:localFile
                               intoContext:self.photoDatabaseContext
                       andThenExecuteBlock:^{
                           [self flickrDownloadTaskMightBeCompleted];
                       }
         ];
    }
}

//req by protocol
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

//req by protocol
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

-(NSArray *)flickrPhotosAtUrl:(NSURL *)url
{
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];
    NSDictionary *flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData options:0 error:NULL];
    return ([flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS]);
}

-(void) flickrDownloadTaskMightBeCompleted
{
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                void(^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
        }];
    }
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // in lecture, we relied on our background flickrDownloadSession to do the fetch by calling [self startFlickrFetch]
    // that was easy to code up, but pretty weak in terms of how much it will actually fetch (maybe almost never)
    // that's because there's no guarantee that we'll be allowed to start that discretionary fetcher when we're in the background
    // so let's simply make a non-discretionary, non-background-session fetch here
    // we don't want it to take too long because the system will start to lose faith in us as a background fetcher and stop calling this as much
    // so we'll limit the fetch to BACKGROUND_FETCH_TIMEOUT seconds (also we won't use valuable cellular data)
    
    if (self.photoDatabaseContext) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT; // want to be a good background citizen!
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                            if (error) {
                                                                NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                                                                completionHandler(UIBackgroundFetchResultNoData);
                                                            } else {
                                                                [self loadFlickrPhotosFromLocalURL:localFile
                                                                                       intoContext:self.photoDatabaseContext
                                                                               andThenExecuteBlock:^{
                                                                                   completionHandler(UIBackgroundFetchResultNewData);
                                                                               }
                                                                 ];
                                                            }
                                                        }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData); // no app-switcher update if no database!
    }

}

- (void)loadFlickrPhotosFromLocalURL:(NSURL *)localFile
                         intoContext:(NSManagedObjectContext *)context
                 andThenExecuteBlock:(void(^)())whenDone
{
    if (context) {
        NSArray *photos = [self flickrPhotosAtUrl:localFile];
        [context performBlock:^{
            [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
            //[context save:NULL]; // NOT NECESSARY if this is a UIManagedDocument's context
            if (whenDone) whenDone();
        }];
    } else {
        if (whenDone) whenDone();
    }
}

-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
