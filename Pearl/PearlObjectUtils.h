/**
 * Copyright Maarten Billemont (http://www.lhunath.com, lhunath@lyndir.com)
 *
 * See the enclosed file LICENSE for license information (LGPLv3). If you did
 * not receive this file, see http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * @author   Maarten Billemont <lhunath@lyndir.com>
 * @license  http://www.gnu.org/licenses/lgpl-3.0.txt
 */

//
//  ObjectUtils.h
//  RedButton
//
//  Created by Maarten Billemont on 08/11/10.
//  Copyright 2010 Lyndir. All rights reserved.
//

#import <Foundation/Foundation.h>

#define va_array(__firstParameter)                                                              \
            ({                                                                                  \
                NSMutableArray *__array = [NSMutableArray array];                               \
                va_list __list;                                                                 \
                va_start(__list, __firstParameter);                                             \
                for (id __object = __firstParameter; __object; __object = va_arg(__list, id))   \
                    [__array addObject:__object];                                               \
                va_end(__list);                                                                 \
                __array;                                                                        \
            })


#define NilToNull(__O)                                                                          \
            ({ __typeof__(__O) __o = __O; __o == nil? (id)[NSNull null]: __o; })
#define NullToNil(__O)                                                                          \
            ({ __typeof__(__O) __o = __O; __o == (id)[NSNull null]? nil: __o; })

#define Throw(__reason)                                                                         \
            @throw [NSException                                                                 \
                    exceptionWithName:NSInternalInconsistencyException                          \
                    reason:__reason                                                             \
                    userInfo:nil]
#define ThrowInfo(__reason, __userInfo)                                                         \
            @throw [NSException                                                                 \
                    exceptionWithName:NSInternalInconsistencyException                          \
                    reason:__reason                                                             \
                    userInfo:__userInfo]

#define PearlInteger(__number) \
            [NSNumber numberWithInteger:__number]
#define PearlUnsignedInteger(__number) \
            [NSNumber numberWithUnsignedInteger:__number]
#define PearlFloat(__number) \
            [NSNumber numberWithFloat:__number]
#define PearlIntegerOp(__number, __operation) \
            PearlInteger([__number integerValue] __operation)
#define PearlUnsignedIntegerOp(__number, __operation) \
            PearlUnsignedInteger([__number unsignedIntegerValue] __operation)
#define PearlFloatOp(__number, __operation) \
            PearlFloat([__number floatValue] __operation)

@interface PearlObjectUtils : NSObject {

}

@end
