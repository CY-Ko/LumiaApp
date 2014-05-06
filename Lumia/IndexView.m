//
//  IndexView.m
//  Lumia
//
//  Created by CHIN-YU KO on 2014/3/2.
//  Copyright (c) 2014年 PhotoFan. All rights reserved.
//

#import "IndexView.h"
#import "FlickrKit.h"
#import "FKAuthViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
@interface IndexView ()
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) FKDUNetworkOperation *completeAuthOp;
@property (nonatomic, retain) FKDUNetworkOperation *checkAuthOp;
@property (nonatomic, retain) FKImageUploadNetworkOperation *uploadOp;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, retain) NSString * dbPath;
@end


@implementation IndexView
@synthesize dbPath;
BOOL weatherCalled = 0;
int GpsCalled=0;
NSUserDefaults *standardDefaults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAuthenticateCallback:) name:@"UserAuthCallbackNotification" object:nil];
	
    // Check if there is a stored token
	// You should do this once on app launch
	self.checkAuthOp = [[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
				[self userLoggedIn:userName userID:userId];
			} else {
				[self userLoggedOut];
			}
        });
	}];
    
    
    //NSLog(@"GPS_test.m viewDidLoad");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"photo_db.sqlite"];
    self.dbPath = path;
    [self addViewButtons];
}
- (void) userAuthenticateCallback:(NSNotification *)notification {
	NSURL *callbackURL = notification.object;
    self.completeAuthOp = [[FlickrKit sharedFlickrKit] completeAuthWithURL:callbackURL completion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
				[self userLoggedIn:userName userID:userId];
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			}
			[self.navigationController popToRootViewControllerAnimated:YES];
		});
	}];
}
- (void) userLoggedIn:(NSString *)username userID:(NSString *)userID {
	self.userID = userID;
	[self.authButton setTitle:@"Logout" forState:UIControlStateNormal];
	self.authLabel.text = [NSString stringWithFormat:@"You are logged in as %@", username];
}

- (void) userLoggedOut {
	[self.authButton setTitle:@"Login" forState:UIControlStateNormal];
	self.authLabel.text = @"Login to flickr";
}
- (IBAction) authButtonPressed:(id)sender {
	if ([FlickrKit sharedFlickrKit].isAuthorized) {
		[[FlickrKit sharedFlickrKit] logout];
		[self userLoggedOut];
	} else {
		FKAuthViewController *authView = [[FKAuthViewController alloc] init];
        NSLog(@"authButtonPressed");
		[self.navigationController pushViewController:authView animated:YES];
	}
}

#pragma mark - GPS related

-(void)startLocationService {
    // init
    if (self.locationManager == nil) {
        self.locationManager = [CLLocationManager new];
    }
    [self.locationManager setDelegate: self];
    // config
    [self.locationManager setDesiredAccuracy: kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter: kCLDistanceFilterNone];
    // start service
    [self.locationManager startUpdatingLocation];
    
    // refresh periodic
    GpsCalled++;
    
    // refresh periodic
    if (timer == nil) {
        if(GpsCalled<4){
            timer=[NSTimer scheduledTimerWithTimeInterval:30
                                                   target:self
                                                 selector:@selector(startLocationService)
                                                 userInfo:nil
                                                  repeats:YES];
        }
    }
}
-(void)stopLocationService {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager setDelegate: nil];
    if (timer != nil) {
        if(GpsCalled>=4){
            [timer invalidate];
            timer = nil;
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D currentLocation = location.coordinate;
    NSLog(@"%f, %f", currentLocation.latitude, currentLocation.longitude);
    
    // GET CURRENT TIME
    // This is your currentDate
    NSDate *today = [NSDate date];
    // NSDateFormatter to separate the Year and Month from currentDate
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:today]; // Get necessary date components
    
    NSLog(@"lat = %@",[NSString stringWithFormat:@"%f",currentLocation.latitude]);
    NSLog(@"lng = %@",[NSString stringWithFormat:@"%f",currentLocation.longitude]);
    NSLog(@"yr = %@",[NSString stringWithFormat:@"%ld",(long)[components year]]);
    NSLog(@"mon = %@",[NSString stringWithFormat:@"%ld",[components month]]);
    NSLog(@"dd = %@",[NSString stringWithFormat:@"%ld",[components day]]);
    NSLog(@"hh = %@",[NSString stringWithFormat:@"%ld",[components hour]]);
    NSLog(@"minute = %@",[NSString stringWithFormat:@"%ld",[components minute]]);
    
    
    [self insertGpsDataFromGpsLat:[NSString stringWithFormat:@"%f",currentLocation.latitude]
                              lng:[NSString stringWithFormat:@"%f",currentLocation.longitude]
                               yr:[NSString stringWithFormat:@"%ld",(long)[components year]]
                              mon:[NSString stringWithFormat:@"%ld",[components month]]
                               dd:[NSString stringWithFormat:@"%ld",[components day]]
                               hh:[NSString stringWithFormat:@"%ld",[components hour]]
                               mm:[NSNumber numberWithInteger: [[NSString stringWithFormat:@"%ld",[components minute]] integerValue]]];
}

- (void)getWeather:(CLLocation *)location {
    CLLocationCoordinate2D currentLocation = location.coordinate;
    NSLog(@"%f, %f", currentLocation.latitude, currentLocation.longitude);
    
}


#pragma mark - SQL Operations
- (void)createTable:(id)sender
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.dbPath] == YES) {
        // create it
        FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
        if ([db open]) {
            NSString * gps = @"CREATE TABLE 'gps' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'lat' VARCHAR(10),'lng' VARCHAR(10),'yr' VARCHAR(4),'mon' VARCHAR(2),'dd' VARCHAR(2),'hh' VARCHAR(2),'mm' INT(2),'ampm' VARCHAR(2))";
            NSString * photos = @"CREATE TABLE 'photos' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'imagePath' VARCHAR(50), 'flickrUrl' VARCHAR(50),'camera' VARCHAR(20),'aperture' VARCHAR(10),'focalLength' VARCHAR(10),'shutter' VARCHAR(10),'iso' VARCHAR(10),'yr' VARCHAR(4),'mon' VARCHAR(2),'dd' VARCHAR(2),'hh' VARCHAR(2),'mm' VARCHAR(2),'ampm' VARCHAR(2),'thumbPath' VARCHAR(50),'150SqPath' VARCHAR(50),'320Path' VARCHAR(50),'640Path' VARCHAR(50),'1024Path' VARCHAR(50),'originPath' VARCHAR(50),'md5' VARCHAR(100))";
            NSString * venues = @"CREATE TABLE 'venues' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'country' VARCHAR(50), 'city' VARCHAR(50),'4sqId' VARCHAR(20),'name' VARCHAR(50),'contact' VARCHAR(200))";
            BOOL res = [db executeUpdate:gps];
            if (!res) {
                NSLog(@"error when creating db gps table");
            } else {
                NSLog(@"succ to creating db gps table");
            }
            res = [db executeUpdate:photos];
            if (!res) {
                NSLog(@"error when creating db photos table");
            } else {
                NSLog(@"succ to creating db photos table");
            }
            res = [db executeUpdate:venues];
            if (!res) {
                NSLog(@"error when creating db venues table");
            } else {
                NSLog(@"succ to creating db venues table");
            }
            [db close];
        } else {
            NSLog(@"error when open db");
        }
    }else{
        NSLog(@"db has been created.");
    }
}

- (void)clearAllDb:(id)sender {
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString * gps = @"delete from gps";
        NSString * photos = @"delete from photos";
        NSString * venues = @"delete from venues";
        BOOL res = [db executeUpdate:gps];
        if (!res) {
            NSLog(@"error to delete db gps data");
        } else {
            NSLog(@"succ to deleta db gps data");
        }
        res = [db executeUpdate:photos];
        if (!res) {
            NSLog(@"error to delete db photos data");
        } else {
            NSLog(@"succ to deleta db photos data");
        }
        res = [db executeUpdate:venues];
        if (!res) {
            NSLog(@"error to delete db venues data");
        } else {
            NSLog(@"succ to delete db venues data");
        }
        [db close];
    }
}

- (void)queryGpsData:(id)sender {
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString * sql = @"select * from gps";
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            int userId = [rs intForColumn:@"id"];
            NSString * lat = [rs stringForColumn:@"lat"];
            NSString * lng = [rs stringForColumn:@"lng"];
            NSLog(@"user id = %d, lat = %@, lng = %@", userId, lat, lng);
        }
        [db close];
    }
}

- (void)queryGpsData_One:(id)sender{
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        //NSString * sql = @"select * from gps where mm > 41";
        NSString * sql = @"select * from gps where hh > 22 ORDER BY dd DESC,hh DESC,mm DESC;";
        
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            int userId = [rs intForColumn:@"id"];
            NSString * lat = [rs stringForColumn:@"lat"];
            NSString * lng = [rs stringForColumn:@"lng"];
            NSString * dd = [rs stringForColumn:@"dd"];
            NSString * mm = [rs stringForColumn:@"mm"];
            NSString * hh = [rs stringForColumn:@"hh"];
            NSLog(@"user id = %d, lat = %@, lng = %@, dd = %@, hh = %@, mm = %@", userId, lat, lng, dd, hh, mm);
        }
        [db close];
    }
}

- (void)insertGpsData:(id)sender {
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString * sql = @"insert into gps (lat, lng, yr, mon, dd, hh, mm, ampm) values(?, ?, ?, ?, ?, ?, ?, ?) ";
        BOOL res = [db executeUpdate:sql, @"301.00", @"302.22", @"2014", @"Feb", @"14", @"00", @"56", @"am"];
        if (!res) {
            NSLog(@"error to insert data");
        } else {
            NSLog(@"succ to insert data");
        }
        [db close];
    }
}

- (void)insertGpsDataFromGpsLat:(NSString *)lat lng:(NSString *)lng yr:(NSString *)yr mon:(NSString *)mon
                             dd:(NSString *)dd hh:(NSString *)hh mm:(NSNumber *)mm{
    
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    NSString * ampm=@"am";
    if([hh intValue]>12){ampm=@"pm";}
    if ([db open]) {
        NSString * sql = @"insert into gps (lat, lng, yr, mon, dd, hh, mm, ampm) values(?, ?, ?, ?, ?, ?, ?, ?) ";
        BOOL res = [db executeUpdate:sql, lat, lng, yr, mon, dd, hh, mm, ampm];
        if (!res) {
            NSLog(@"error to insert data");
        } else {
            NSLog(@"succ to insert data");
        }
        [db close];
    }
    NSLog(@"going to stop gps");
    [self stopLocationService];
    NSLog(@"gps stop");
    //[locationManager stopUpdatingLocation];
}



#pragma mark - View Layout
- (void)addViewButtons {
    NSLog(@"addViewButtons");
    
    //    singleLineLabel = [[UILabel alloc]init];
    //    singleLineLabel.frame = CGRectMake(10, 160, 300, 30);
    //    singleLineLabel.font = [UIFont systemFontOfSize:30];
    //    singleLineLabel.text = @"請按鈕";
    //    [self.view addSubview:singleLineLabel];
    //
    //
    
    UIButton *btnTwo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnTwo.frame=CGRectMake(130.0, 130.0, 40.0, 40.0);
    [btnTwo setTitle:@"S" forState:UIControlStateNormal];
    [btnTwo setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    btnTwo.backgroundColor = [UIColor blackColor];
    //btnTwo.frame = CGRectMake(110, 440, 100, 100);
    //[self.view addSubview:btnTwo];
    
    UIButton *startGps = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *stopGps = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *showGpsDb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *showPhotoDb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *showVenusDb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *deleteDb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *createDb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *insertGps = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *queryGpsData_One = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    float height_temp=60.0;
    startGps.frame=CGRectMake(30.0, height_temp+30.0, 120.0, 25.0);
    stopGps.frame=CGRectMake(30.0, height_temp+60.0, 120.0, 25.0);
    showGpsDb.frame=CGRectMake(30.0, height_temp+90.0, 120.0, 25.0);
    showPhotoDb.frame=CGRectMake(30.0, height_temp+120.0, 120.0, 25.0);
    showVenusDb.frame=CGRectMake(30.0, height_temp+150.0, 120.0, 25.0);
    deleteDb.frame=CGRectMake(30.0, height_temp+180.0, 120.0, 25.0);
    createDb.frame=CGRectMake(30.0, height_temp+210.0, 120.0, 25.0);
    insertGps.frame=CGRectMake(30.0, height_temp+240.0, 120.0, 25.0);
    queryGpsData_One.frame=CGRectMake(30.0, height_temp+270.0, 120.0, 25.0);
    
    
    [startGps addTarget:self action:@selector(startLocationService) forControlEvents:UIControlEventTouchUpInside];
    [stopGps addTarget:self action:@selector(stopLocationService) forControlEvents:UIControlEventTouchUpInside];
    [showGpsDb addTarget:self action:@selector(queryGpsData:) forControlEvents:UIControlEventTouchUpInside];
    [showPhotoDb addTarget:self action:@selector(createTable:) forControlEvents:UIControlEventTouchUpInside];
    [showVenusDb addTarget:self action:@selector(createTable:) forControlEvents:UIControlEventTouchUpInside];
    [deleteDb addTarget:self action:@selector(clearAllDb:) forControlEvents:UIControlEventTouchUpInside];
    [createDb addTarget:self action:@selector(createTable:) forControlEvents:UIControlEventTouchUpInside];
    [insertGps addTarget:self action:@selector(insertGpsData:) forControlEvents:UIControlEventTouchUpInside];
    [queryGpsData_One addTarget:self action:@selector(queryGpsData_One:) forControlEvents:UIControlEventTouchUpInside];
    
    [startGps setTitle:@"startGps" forState:UIControlStateNormal];
    [stopGps setTitle:@"stopGps" forState:UIControlStateNormal];
    [showGpsDb setTitle:@"showGpsDb" forState:UIControlStateNormal];
    [showPhotoDb setTitle:@"showPhotoDb" forState:UIControlStateNormal];
    [showVenusDb setTitle:@"showVenusDb" forState:UIControlStateNormal];
    [deleteDb setTitle:@"deleteDb" forState:UIControlStateNormal];
    [createDb setTitle:@"createDb" forState:UIControlStateNormal];
    [insertGps setTitle:@"insertGps" forState:UIControlStateNormal];
    [queryGpsData_One setTitle:@"queryGpsData_One" forState:UIControlStateNormal];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.5 alpha:1.0]];
    //
    //    [self.view addSubview:btnTwo];
    //
    [self.view addSubview:startGps];
    [self.view addSubview:stopGps];
    [self.view addSubview:showGpsDb];
    [self.view addSubview:showPhotoDb];
    [self.view addSubview:showVenusDb];
    [self.view addSubview:deleteDb];
    [self.view addSubview:createDb];
    [self.view addSubview:insertGps];
    [self.view addSubview:queryGpsData_One];
}
#pragma mark - Image Upload Related
- (IBAction) cameraRollButtonPressed:(id)sender {
	QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = 1;
    imagePickerController.maximumNumberOfSelection = 6;
    [self.navigationController pushViewController:imagePickerController animated:YES];
}
- (void)dismissImagePickerController
{
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popToViewController:self animated:YES];
    }
}

#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    NSLog(@"*** imagePickerController:didSelectAsset:");
    NSLog(@"%@", asset);
    
    [self dismissImagePickerController];
}

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    NSLog(@"*** imagePickerController:didSelectAssets:");
    NSLog(@"%@", assets);
    NSLog(@"%@",[assets objectAtIndex: 0]);
    //-----想要parse 單純URL出來，下列為測試碼，待測試
    UIImage * imagePicked;
    for (int i = 0; i < assets.count; i++) {
        ALAssetRepresentation *rep = [[assets objectAtIndex: i] defaultRepresentation];
        imagePicked  = [UIImage imageWithCGImage:[rep fullResolutionImage]];
    }
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 175, 175)];
    imageView.image = imagePicked;
    [self dismissImagePickerController];
    [self.view addSubview:imageView];
    
    
    //------- upload related
    
    NSDictionary *uploadArgs = @{@"title": @"自己的照片自己照", @"description": @"自己的App自己寫", @"is_public": @"1", @"is_friend": @"0", @"is_family": @"0", @"hidden": @"2"};
    
    self.progress.progress = 0.0;
	self.uploadOp =  [[FlickrKit sharedFlickrKit] uploadImage:imagePicked args:uploadArgs completion:^(NSString *imageID, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			} else {
				NSString *msg = [NSString stringWithFormat:@"Uploaded image ID %@", imageID];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			}
            [self.uploadOp removeObserver:self forKeyPath:@"uploadProgress" context:NULL];
        });
	}];
    [self.uploadOp addObserver:self forKeyPath:@"uploadProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
	//[self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"*** imagePickerControllerDidCancel:");
    
    [self dismissImagePickerController];
}
#pragma mark - Progress KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.progress.progress = progress;
        //[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    });
}


@end
