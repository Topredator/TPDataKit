//
//  TPModelID.m
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import "TPModelID.h"

NSString *const TPIDKey = @"topredator.tpkit.base.model.id";

NSString *TPMakeMemoryAddressIdentify(id obj) {
    void *ptr = (__bridge void *)(obj);
    return [NSString stringWithFormat:@"%p", ptr];
}

@implementation NSString (TPModelID)
- (id)modelID {
    return self;
}
@end
@implementation NSNumber (TPModelID)
- (id)modelID {
    return self;
}
@end
@implementation NSValue (TPModelID)
- (id)modelID {
    return self;
}
@end

@implementation NSDictionary (TPModelID)
- (id)modelID {
    return [self objectForKey:TPIDKey];
}
@end
