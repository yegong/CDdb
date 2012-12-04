//  Created by Cooper Du on 2012-12-03.
#import "CDDatabase.h"

@interface FMDatabase ()

- (FMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;
- (BOOL)executeUpdate:(NSString*)sql error:(NSError**)outErr withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;
@end


@implementation CDDatabase

- (id)initWithPath:(NSString*)databasePath
{
    self = [super initWithPath: databasePath];
    _sqlMap = [NSMutableDictionary new];
    return self;
}

- (FMResultSet *)executeQuery:(NSString *)sqlIdentifier withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args
{
    NSString *sql = [self getSqlByIdentifier: sqlIdentifier];
    return [super executeQuery:sql withArgumentsInArray:arrayArgs orDictionary:dictionaryArgs orVAList:args];
}


- (BOOL)executeUpdate:(NSString*)sqlIdentifier error:(NSError**)outErr withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args
{
    NSString *sql = [self getSqlByIdentifier: sqlIdentifier];
    return [super executeUpdate:sql error:outErr withArgumentsInArray:arrayArgs orDictionary:dictionaryArgs orVAList:args];
}

- (NSString*) getSqlByIdentifier:(NSString *)sqlIdentifier
{
    if ([sqlIdentifier characterAtIndex:0] != '@') {
        return sqlIdentifier;
    }
    sqlIdentifier = [sqlIdentifier substringFromIndex: 1];
    NSArray *comps = [sqlIdentifier componentsSeparatedByString: @":"];
    NSAssert1(comps.count == 2, @"Invalid sql resouce identifier '%@'", sqlIdentifier);
    NSString *fileName = comps[0];
    NSString *scriptName = comps[1];
    NSDictionary *scriptMap = [self getOrCreateScriptMap: fileName];
    NSString *sql = scriptMap[scriptName];
    NSAssert1(sql, @"Cannot find sql for '%@'", sqlIdentifier);
    if (_traceExecution) {
        NSLog(@"SQL '%@' is now known as '%@'", sqlIdentifier, sql);
    }
    return sql;
}

- (NSDictionary*) getOrCreateScriptMap: (NSString*) fileName
{
    NSDictionary* scriptMap = _sqlMap[fileName];
    if (scriptMap == nil) {
        scriptMap = [CDDatabase createScriptMapByFileName: fileName];
        NSMutableDictionary *sqlMap = (NSMutableDictionary*) _sqlMap;
        [sqlMap setObject: scriptMap forKey: fileName];
    }
    return scriptMap;
}

+ (NSDictionary*) createScriptMapByFileName: (NSString *)fileName
{
    NSString *file = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist" inDirectory:nil];

    NSAssert1(file, @"Cannot load sql map file '%@'", fileName);
    return [NSDictionary dictionaryWithContentsOfFile: file];
}

@end
