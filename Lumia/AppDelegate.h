//
//  AppDelegate.h
//  Luminous
//
//  Created by CHIN-YU KO on 2013/11/16.
//  Copyright (c) 2013年 TheJokers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ObjectiveFlickr.h"   // ==== flickr
//@class PhotoViewController;
//@class FlashAirThumbnails;
//@class ExampleViewController;
//@class GPS_test;


extern NSString *SnapAndRunShouldUpdateAuthInfoNotification;
@class IndexView;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate,OFFlickrAPIRequestDelegate>
{
    //PhotoViewController *rootViewController;
    //GPS_test *rootViewController;
    IndexView *rootViewController;
    //ExampleViewController *rootViewController;
    BOOL gpsFlag;
    CLLocationManager *locationManager;
    
    UIBackgroundTaskIdentifier bgTask;
    NSUInteger counter;
    
    //==== flickr
    UINavigationController *viewController;
    UIWindow *window;
	
	UIActivityIndicatorView *activityIndicator;
	UIView *progressView;
	UIButton *cancelButton;
	UILabel *progressDescription;
    
    OFFlickrAPIContext *flickrContext;
	OFFlickrAPIRequest *flickrRequest;
	NSString *flickrUserName;
    //==== flickr

}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (strong, nonatomic) IndexView *viewController;
@end
