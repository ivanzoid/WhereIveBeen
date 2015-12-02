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

    NSData *footerData = [self footerData];
    [fileHandle writeData:footerData];

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

- (NSString *) documentsDirectory
{
    NSArray *documentsDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [documentsDirectories count] ? documentsDirectories[0] : @"";
    return documentsDirectory;
}

- (NSString *) pathToCurrentFile
{
    NSString *documentsDirectory = [self documentsDirectory];
    NSString *pathToCurrentFile = [documentsDirectory stringByAppendingPathComponent:[self currentFileName]];
    return pathToCurrentFile;
}

- (NSFileHandle *) createGpxFileAt:(NSString *)path
{
    if (![[NSFileManager defaultManager] createFileAtPath:path contents:[NSData data] attributes:nil]) {
        return nil;
    }

    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    if (!fileHandle) {
        return nil;
    }

    NSData *headerData = [self headerDataWithCreator:kCreator name:[self currentDateString]];
    [fileHandle writeData:headerData];

    NSLog(@"Created file at %@ (fileHandle = %@)", path, fileHandle);

    return fileHandle;
}

- (unsigned long long) sizeOfFileAtPath:(NSString *)path
{
    NSError *error = nil;
    NSDictionary<NSString *, id> *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];

    NSNumber *fileSize = fileAttributes[NSFileSize];

    NSLog(@"Size of file at %@ = %llu", path, [fileSize unsignedLongLongValue]);

    return [fileSize unsignedLongLongValue];
}

- (NSFileHandle *) fileHandleForWritingNewPoint
{
    NSString *pathToCurrentFile = [self pathToCurrentFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSFileHandle *fileHandle = nil;

    NSError *error = nil;

    if (![fileManager fileExistsAtPath:pathToCurrentFile]) {
        fileHandle = [self createGpxFileAt:pathToCurrentFile];
    } else {
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:pathToCurrentFile];
        if (fileHandle) {
            unsigned long long truncateOffset = [self sizeOfFileAtPath:pathToCurrentFile] - _footerLength;
            [fileHandle truncateFileAtOffset:truncateOffset];
            NSLog(@"Opened file at %@, truncated at offset %llu", pathToCurrentFile, truncateOffset);
        }
    }

    if (fileHandle == nil) {
        NSLog(@"Can't open or create file at %@: %@", pathToCurrentFile, error);
        return nil;
    }

    return fileHandle;
}

@end
