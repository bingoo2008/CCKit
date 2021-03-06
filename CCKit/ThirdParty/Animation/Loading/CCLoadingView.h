//
//  CCLoadingView.h
//  CCFramework
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <UIKit/UIKit.h>

/**
 Enum for different animations
 */
typedef NS_ENUM(NSInteger, CCCircleAnimation) {
    CCCircleAnimationFullCircle,
    CCCircleAnimationSemiCircle
};

@interface CCLoadingView : UIView

/**
 Changes the duration of one complete cycle
 */
@property(assign, nonatomic) CGFloat duration;

/**
 Changes the direction the animation spins
 */
@property(assign, nonatomic) bool clockwise;

/**
 Changes the color of the segments
 */
@property(strong, nonatomic) UIColor *segmentColor;

/**
 Changes the line cap styles of the segments
 */
@property(assign, nonatomic) NSString *lineCap;


/**
 Initializes the segments.
 */
- (void)initialize;

/**
 starts the animation that spins in a full circle or in a semi circle
 
 @param animationType
 Lets you chose between the full circle animation or the semi circle
 */
- (void)startAnimation:(CCCircleAnimation)animationType;

/**
 stops all animations
 */
- (void)stopAnimation;

@end
