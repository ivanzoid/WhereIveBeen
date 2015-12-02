//
//  AppDelegate.m
//  WhereIveBeen
//
//  Created by Ivan Zezyulya on 24.11.15.
//  Copyright © 2015 Ivan Zezyulya. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "GpxWriter.h"

#import <CoreLocation/CoreLocation.h>

@interface AppDelegate () <CLLocationManagerDelegate>
@end

@implementation AppDelegate {
    CLLocationManager *_locationManager;
    GpxWriter *_gpxWriter;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    ViewController *viewController = [ViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];

    [self setupLocationManager];
    [self setupGpxWriter];
    [self startLocationMonitoring];

    return YES;
}

- (void) setupLocationManager
{
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
}

- (void) startLocationMonitoring
{
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        NSLog(@"Requesting always authorization.");
        [_locationManager requestAlwaysAuthorization];
    } else {
        NSLog(@"Starting monitoring significant location changes.");
        [_locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void) setupGpxWriter
{
    _gpxWriter = [GpxWriter new];
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        NSLog(@"Always authorization confirmed.");
        NSLog(@"Starting monitoring significant location changes.");
        [_locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    for (CLLocation *location in locations) {
        [_gpxWriter writeLocation:location];
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager didFailWithError: %@", error);
}

@end
