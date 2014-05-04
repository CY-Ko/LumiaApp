#import "AppDelegate.h"
#import "PhotoViewController.h"
//#import "blurViewController.h"
//#import "GPS_test.h"
#import "IndexView.h"
//#import "FlashAirThumbnails.h"
//#import "ExampleViewController.h"
#import "FlickrKit.h"
@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");;
    NSString *apiKey = @"84fcdf3efa56b02e4e7870fd3d23ccd9";
	NSString *secret = @"bfff45dd572a2989";
    if (!apiKey) {
        NSLog(@"\n----------------------------------\nYou need to enter your own 'apiKey' and 'secret' in FKAppDelegate for the demo to run. \n\nYou can get these from your Flickr account settings.\n----------------------------------\n");
        exit(0);
    }
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:apiKey sharedSecret:secret];
    
    
    
    //*********** mask these lines all when using storyboard, just add main interface in project summary
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    //rootViewController = [[GPS_test alloc] initWithNibName:nil bundle:nil];
    rootViewController = [[IndexView alloc] initWithNibName:@"IndexView" bundle:nil];
    
    
    
    //self.window.rootViewController = rootViewController;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	self.window.rootViewController = self.navigationController;
    
    
    
    
    [self.window makeKeyAndVisible];
    //[self.window addSubview:rootViewController.view];
    //***********
    
    return YES;
    gpsFlag=YES;
    counter=0;
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *scheme = [url scheme];
	if([@"flickrkitdemolumia" isEqualToString:scheme]) {
		// I don't recommend doing it like this, it's just a demo... I use an authentication
		// controller singleton object in my projects
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UserAuthCallbackNotification" object:url userInfo:nil];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    gpsFlag=FALSE;
    //    UIApplication *app = [UIApplication sharedApplication];
    //
    //    //create new uiBackgroundTask
    //    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
    //        [app endBackgroundTask:bgTask];
    //        bgTask = UIBackgroundTaskInvalid;
    //    }];
    //
    //    //and create new timer with async call:
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        //run function methodRunAfterBackground
    //        NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:3 target:self  selector:@selector(startLocationManager) userInfo:nil repeats:YES];
    //
    //        [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
    //
    //        [[NSRunLoop currentRunLoop] run];
    //    });
    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{ [self backgroundHandler]; }];
    
    if (backgroundAccepted){
        NSLog(@"backgrounding accepted");
    }
    [self backgroundHandler];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    gpsFlag=YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)startLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setPausesLocationUpdatesAutomatically:NO];
    if(gpsFlag==FALSE){
        [locationManager startUpdatingLocation];
        NSLog(@"gpsFlag==YES");
    }
    [locationManager stopUpdatingLocation];
    NSLog(@"startLocationManager background");
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D currentLocation = location.coordinate;
    NSLog(@"%f, %f", currentLocation.latitude, currentLocation.longitude);
    //[locationManager stopUpdatingLocation];
}

- (void)backgroundHandler {
    
    
    
    NSLog(@"### -->backgroundinghandler");
    
    
    
    UIApplication*    app = [UIApplication sharedApplication];
    
    
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        [app endBackgroundTask:bgTask];
        
        bgTask = UIBackgroundTaskInvalid;
        
    }];
    
    
    
    // Start the long-running task
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        
        while (!gpsFlag) {
            
            NSLog(@"counter:%ld", counter++);
            
            sleep(1);
            
        }  
        NSLog(@"applicationWillEnterForeground");
    });
    
}

@end
