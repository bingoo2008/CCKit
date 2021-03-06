//
//  UIViewController+Additions.m
//  CCKit
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

#import "UIViewController+CCProperties.h"
#import <objc/runtime.h>

@implementation UIViewController (CCProperties)

- (CCViewManger *)cc_viewManger
{
    CCViewManger *curVM = objc_getAssociatedObject(self, @selector(cc_viewManger));
    if (curVM) return curVM;
    if (![self respondsToSelector:@selector(cc_classOfViewManger)]) {
        NSException *exp = [NSException exceptionWithName:@"not found cc_classOfViewManger" reason:@"you forgot to add cc_classOfViewManger() in VivewController" userInfo:nil];
        [exp raise];
    }
    curVM = [[[self cc_classOfViewManger] alloc] init];
    self.cc_viewManger = curVM;
    return curVM;
}

- (void)setCc_viewManger:(__kindof NSObject *)cc_viewManger
{
    objc_setAssociatedObject(self, @selector(cc_viewManger), cc_viewManger, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CCViewModel *)cc_viewModel
{
    CCViewModel *curVM = objc_getAssociatedObject(self, @selector(cc_viewModel));
    if (curVM) return curVM;
    if (![self respondsToSelector:@selector(cc_classOfViewModel)]) {
        NSException *exp = [NSException exceptionWithName:@"not found cc_classOfViewModel" reason:@"you forgot to add cc_classOfViewModel() in VivewController" userInfo:nil];
        [exp raise];
    }
    curVM = [[[self cc_classOfViewModel] alloc] init];
    self.cc_viewModel = curVM;
    return curVM;
}

- (void)setCc_viewModel:(__kindof NSObject *)cc_viewModel
{
    objc_setAssociatedObject(self, @selector(cc_viewModel), cc_viewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
