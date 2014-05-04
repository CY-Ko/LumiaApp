//
//  IndexView.h
//  Lumia
//
//  Created by CHIN-YU KO on 2014/3/2.
//  Copyright (c) 2014年 PhotoFan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface IndexView : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    NSTimeInterval locationManagerStartTimestamp;
    UILabel *singleLineLabel;
    NSTimer *timer;
}
- (void)startLocationManager;
@property (weak, nonatomic)  UILabel *singleLineLabel;

@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UILabel *authLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
- (IBAction)authButtonPressed:(id)sender;
@end



