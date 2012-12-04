//  Created by Cooper Du on 2012-12-03.
#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface CDDatabase : FMDatabase

@property (readonly, strong, atomic) NSDictionary *sqlMap;

- (id)initWithPath:(NSString*)databasePath;

@end
