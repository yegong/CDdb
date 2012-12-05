//  Created by Cooper Du on 2012-12-03.
#import <Foundation/Foundation.h>

@class CDDatabase;

@interface CDMigrationExecutor : NSObject

@property(readonly, nonatomic) CDDatabase *database;
@property(readonly, nonatomic) NSArray *migrations;

- (id) initWithDatabase: (CDDatabase*) database andMigrations: (NSArray*) migrations;

- (int) migrateToVersion: (int) version;

- (void) close;
- (void) dealloc;

@end
