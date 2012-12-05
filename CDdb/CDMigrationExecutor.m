//  Created by Cooper Du on 2012-12-03.
#import "CDMigrationExecutor.h"
#import "CDMigration.h"
#import "CDDatabase.h"


@implementation CDMigrationExecutor

- (id) initWithDatabase:(CDDatabase *)database andMigrations:(NSArray *)migrations
{
    self = [super init];

    NSAssert(database && migrations && database.open, @"Invalid arguments");
    for (int i = 0; i < migrations.count; ++i) {
        id<CDMigration> migration = migrations[i];
        NSAssert1(migration.version == (i + 1), @"Migration at version %d is invalid", migration.version);
    }
    _database = database;
    _migrations = migrations;
    [self setupMetaTables];
    return self;
}

- (void) close
{
    _database = nil;
    _migrations = nil;
}

- (void) dealloc
{
    [self close];
}

- (bool) migrate: (id<CDMigration>) migration from: (int) from to: (int) to
{
    bool succ = YES;
    succ = [_database beginTransaction];
    if (!succ) {
        return NO;
    }
    if (from < to) {
        succ &= [migration upgrade: _database];
        NSLog(@"Upgrade to version %d", to);
    }
    else {
        succ &= [migration downgrade: _database];
        NSLog(@"Downgrade to version %d", to);
    }
    succ &= [_database executeUpdate: @"@CDMigrationMeta:update_current_version", [NSNumber numberWithInt: to]];
    succ &= [_database executeUpdate: @"@CDMigrationMeta:insert_history", [NSNumber numberWithInt: from], [NSNumber numberWithInt: to], migration.description];
    if (succ) {
        NSLog(@"Success!");
        return [_database commit];
    }
    else {
        NSLog(@"Failed!");
        [_database rollback];
        return NO;
    }
}

- (int) migrateToVersion:(int)version
{
    [self setupMetaTables];
    int currentVersion = self.currentVersion;
    if (currentVersion == version) {
        return currentVersion;
    }
    bool upgrade = version > currentVersion;
    int step = upgrade ? 1 : -1;
    while (currentVersion != version) {
        int from = currentVersion;
        int to = currentVersion + step;
        int migrationVersion = MAX(from, to);
        if (migrationVersion <= 0 || migrationVersion > _migrations.count) {
            break;
        }
        id<CDMigration> migration = _migrations[migrationVersion - 1];
        bool succ = [self migrate: migration from: from to: to];
        if (!succ) {
            break;
        }
        currentVersion += step;
    }
    return currentVersion;
}

- (int) currentVersion
{
    FMResultSet *result = [_database executeQuery: @"@CDMigrationMeta:get_current_version"];
    if (result.next) {
        int version = [result intForColumnIndex: 0];
        [result close];
        return version;
    }
    else {
        NSAssert(NO, @"Failed to get current version");
        return 0;
    }
}

- (void)setupMetaTables
{
    bool succ = [_database beginTransaction];
    NSAssert(succ, @"Failed to init meta info tables");
    if (succ) {
        succ &= [_database executeUpdate: @"@CDMigrationMeta:create_version_table"];
        succ &= [_database executeUpdate: @"@CDMigrationMeta:init_version_table"];
        succ &= [_database executeUpdate: @"@CDMigrationMeta:create_history_table"];
    }
    if (succ) {
        [_database commit];
    }
    else {
        [_database rollback];
        NSAssert(succ, @"Failed to init meta info tables");
    }
}

@end
