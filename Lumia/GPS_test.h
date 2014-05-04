//
//  GPS_test.h
//  Luminous
//
//  Created by CHIN-YU KO on 2013/12/15.
//  Copyright (c) 2013年 TheJokers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
//#import "MBXMapKit.h"
@interface GPS_test : UIViewController<CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    NSTimeInterval locationManagerStartTimestamp;
    UILabel *singleLineLabel;
    NSTimer *timer;
}
- (void)startLocationManager;
@property (weak, nonatomic)  UILabel *singleLineLabel;
@end
