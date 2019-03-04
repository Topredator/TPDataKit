//
//  TPModelID.h
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *const TPIDKey;

/// obj 内存地址
NSString *TPMakeMemoryAddressIdentify(id obj);

@protocol TPModelID <NSObject>
- (id)modelID;
@end

@interface NSString (TPModelID) <TPModelID>
@end

@interface NSNumber (TPModelID) <TPModelID>
@end
@interface NSValue (TPModelID) <TPModelID>
@end
@interface NSDictionary (TPModelID) <TPModelID>
@end
