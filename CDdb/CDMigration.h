//  Created by Cooper Du on 2012-12-03.
#import <Foundation/Foundation.h>

@class CDDatabase;

@protocol CDMigration<NSObject>

@required
- (int) version;
- (bool) upgrade: (CDDatabase*) db;
- (bool) downgrade: (CDDatabase*) db;
- (NSString*) description;

@end

@interface CDMigrationBuilder : NSObject

+ (NSArray*) migrationsByScriptFile: (NSString*) fileName atVersion: (int) version;

@end

