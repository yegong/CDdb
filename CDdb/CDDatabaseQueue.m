//  Created by Cooper Du on 2012-12-03.
#import "CDDatabaseQueue.h"
#import "CDDatabase.h"

@implementation CDDatabaseQueue

- (id)initWithPath:(NSString*)databasePath {

    self = [super initWithPath:databasePath];

    if (self) {
        FMDBRelease(_db);
        _db = nil;
        NSLog(@"%@", _queue);
        [self database];
    }

    return self;
}

- (FMDatabase*)database {
    if (!_db) {
        _db = FMDBReturnRetained([CDDatabase databaseWithPath:_path]);

        if (![_db open]) {
            NSLog(@"CDDatabaseQueue could not reopen database for path %@", _path);
            FMDBRelease(_db);
            _db  = 0x00;
            return 0x00;
        }
    }

    return _db;
}

@end
