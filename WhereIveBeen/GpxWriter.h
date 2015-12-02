//
//  GpxWriter.h
//  WhereIveBeen
//
//  Created by Ivan Zezyulya on 01.12.15.
//  Copyright © 2015 Ivan Zezyulya. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface GpxWriter : NSObject

- (void) writeLocation:(CLLocation *)location;

@end
