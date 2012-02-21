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
//  UIImage_Scaling.h
//  Pearl
//
//  Created by Maarten Billemont on 30/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (Scaling)

/** Scale an image such that its entire content fits in the given size.
 *
 * We scale until either the width or the height fills the image while the other either also fills the image or is smaller. */
- (UIImage*)imageByScalingAndFittingInSize:(CGSize)targetSize;
/** Scale an image such that its entire content fills the given size.
 *
 * We scale until either the width or the height fills the image while the other either also fills the image or is larger and cropping the excess. */
- (UIImage*)imageByScalingAndCroppingToSize:(CGSize)targetSize;
    
@end
