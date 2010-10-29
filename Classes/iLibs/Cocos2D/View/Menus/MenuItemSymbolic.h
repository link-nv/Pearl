/*
 *   Copyright 2009, Maarten Billemont
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

//
//  MenuItemSymbolic.h
//  iLibs
//
//  Created by Maarten Billemont on 08/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "cocos2d.h"


@interface MenuItemSymbolic : MenuItemFont {

}

+ (MenuItemSymbolic *)itemFromString:(NSString *)symbol;
+ (MenuItemSymbolic *)itemFromString:(NSString *)symbol target:(id)target selector:(SEL)selector;

- (id)initFromString:(NSString *)symbol;
- (id)initFromString:(NSString *)symbol target:(id)target selector:(SEL)selector;

@end
