//
//  GpxWriter.m
//  WhereIveBeen
//
//  Created by Ivan Zezyulya on 01.12.15.
//  Copyright © 2015 Ivan Zezyulya. All rights reserved.
//

#import "GpxWriter.h"
#import "DispatchQueue.h"

static NSString * const kGpxFileHeader_2params =
@"<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" version=\"1.1\" creator=\"%@\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\">\n"
@" <trk>\n"
@"  <name>%@</name>\n"
@"  <trkseg>\n";

static NSString * const kGpxFileFooter =
@"   </trkseg>\n"
@" </trk>\n"
@"</gpx>\n";

static NSString * const kGpxPointTemplate_4params =
@"    <trkpt lon=\"%f\" lat=\"%f\">\n"
@"     <ele>%f</ele>\n"
@"     <time>%@</time>\n"
@"    </trkpt>\n";

static NSString * const kCreator = @"Where I've Been app";

@implementation GpxWriter {
    NSUInteger _footerLength;
}

- (id) init
{
    if ((self = [super init])) {
        _footerLength = [kGpxFileFooter length];
    }
    return self;
}


#pragma mark - Public

- (void) writeLocation:(CLLocation *)location
{
    NSFileHandle *fileHandle = [self fileHandleForWritingNewPoint];

    NSData *pointData = [self pointDataForLocation:location];
    [fileHandle writeData:pointData];
    [fileHandle closeFile];
}

#pragma mark - Private

- (NSData *) headerDataWithCreator:(NSString *)creator name:(NSString *)name
{
    NSString *header = [NSString stringWithFormat:kGpxFileHeader_2params, creator, name];
    NSData *headerData = [header dataUsingEncoding:NSUTF8StringEncoding];
    return headerData;
}

- (NSData *) pointDataForLocation:(CLLocation *)location
{
    NSString *pointString = [NSString stringWithFormat:kGpxPointTemplate_4params, location.coordinate.longitude, location.coordinate.latitude, location.altitude, [self iso8601DateStringForDate:location.timestamp]];
    NSData *pointData = [pointString dataUsingEncoding:NSUTF8StringEncoding];
    return pointData;
}

- (NSData *) footerData
{
    NSData *footerData = [kGpxFileFooter dataUsingEncoding:NSUTF8StringEncoding];
    return footerData;
}

- (NSString *) iso8601DateStringForDate:(NSDate *)date
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    return dateString;
}

- (NSString *) currentDateString
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    return dateString;
}

- (NSString *) currentFileName
{
    NSString *fileName = [NSString stringWithFormat:@"%@.gpx", [self currentDateString]];
    return fileName;
}

- (NSURL *) documentsDirectoryUrl
{
    NSArray *cachesUrls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return cachesUrls[0];
}

- (NSURL *) pathToCurrentFile
{
    NSURL *documentsDirectoryUrl = [self documentsDirectoryUrl];
    NSURL *pathToCurrentFile = [documentsDirectoryUrl URLByAppendingPathComponent:[self currentFileName]];
    return pathToCurrentFile;
}

- (NSFileHandle *) createGpxFileAt:(NSURL *)path
{
    NSError *error = nil;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:path error:&error];

    NSData *headerData = [self headerDataWithCreator:kCreator name:[self currentDateString]];
    [fileHandle writeData:headerData];

    NSData *footerData = [self footerData];
    [fileHandle writeData:footerData];

    [fileHandle seekToFileOffset:[headerData length]];

    return fileHandle;
}

- (unsigned long long) sizeOfFileAtPath:(NSURL *)path
{
    NSError *error = nil;
    NSDictionary<NSString *, id> *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[path absoluteString] error:&error];

    NSNumber *fileSize = fileAttributes[NSFileSize];
    return [fileSize unsignedLongLongValue];
}

- (NSFileHandle *) fileHandleForWritingNewPoint
{
    NSURL *pathToCurrentFile = [self pathToCurrentFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSFileHandle *fileHandle = nil;

    if (![fileManager fileExistsAtPath:[pathToCurrentFile absoluteString]]) {
        fileHandle = [self createGpxFileAt:pathToCurrentFile];
    } else {
        NSError *error = nil;
        fileHandle = [NSFileHandle fileHandleForWritingToURL:pathToCurrentFile error:&error];
        unsigned long long fileSize = [self sizeOfFileAtPath:pathToCurrentFile];
        [fileHandle seekToFileOffset:fileSize - _footerLength];
    }

    if (!fileHandle) {
        return nil;
    }

    return fileHandle;
}

@end
