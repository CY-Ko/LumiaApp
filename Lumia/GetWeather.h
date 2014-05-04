#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GetWeather : NSObject

@property (strong, nonatomic) NSString *currentLocation;
@property (strong, nonatomic) NSString *currentTemperature;

- (void)getWeatherAtCurrentLocation:(CLLocationCoordinate2D)coordinate;

@end