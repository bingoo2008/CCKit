//
//  LoadLogoView.h
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

typedef enum {
    CCLoadLogoViewModeIndeterminate,
    CCLoadLogoViewModeFloatingPoint,
} CCLoadLogoViewMode;

@interface CCLoadLogoView : UIView

@property(nonatomic, strong) UIColor *lineColor;

- (instancetype)initWithLogo:(NSString *)Logo Frame:(CGRect)frame;

- (instancetype)initWithLoading:(CGRect)frame;

- (void)startAnimation;

- (void)stopAnimation;

@property(assign) CCLoadLogoViewMode mode;

@end

@interface CCLoadView : UIView

@property(assign) CCLoadLogoViewMode mode;

//default is 1.0f
@property(nonatomic, assign) CGFloat lineWidth;

//default is [UIColor whiteColor]
@property(nonatomic, strong) UIColor *lineColor;

@property(nonatomic, readonly) BOOL isAnimating;

//use this to init
- (id)initWithFrame:(CGRect)frame;

- (void)startAnimation;
- (void)stopAnimation;

@end
