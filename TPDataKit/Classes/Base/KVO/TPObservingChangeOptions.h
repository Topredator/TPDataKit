//
//  TPObservingChangeOptions.h
//  TPDataKit
//
//  Created by Topredator on 2019/3/9.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(NSUInteger, TPObservingChangeOptions)
{
    TPObservingChangeOptionsOld = 0x01,
    TPObservingChangeOptionsNew = 0x02
};

FOUNDATION_EXTERN NSString *const TPChangeOptionOldKey;
FOUNDATION_EXTERN NSString *const TPChangeOptionNewKey;
