//
//  CCKeyboardManager.m
//  CCKit
//
//  Created by CC on 2017/4/11.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#import "CCKeyboardManager.h"
#import "UIView+CCHierarchy.h"


NSString *const kCCTextFiled = @"kCCTextFiled";
NSString *const kCCTextFiledDelegate = @"kCCTextFiledDelegate";
NSString *const kCCTextFiledReturnKeyType = @"kCCTextFiledRetrurnKeyType";

@interface CCKeyboardManager () <UITextFieldDelegate, UITextViewDelegate>

@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;

@property(nonatomic, weak) UIViewController *rootViewController;
@property(nonatomic, assign) CGRect topViewBeginRect;

@property(nonatomic, strong) NSMutableSet *textFieldInfoCache;

@property(nonatomic, weak) UIView *textFieldView;

@property(nonatomic, assign) CGSize kSize;

@property(nonatomic, assign) CGFloat animationDuration;
@property(nonatomic, assign) NSInteger animationCurve;

@property(nonatomic, assign) BOOL keyboardShowing;

@end

@implementation CCKeyboardManager

static CCKeyboardManager *keyboardManager;
static dispatch_once_t onceToken;

+ (instancetype)manager
{
    dispatch_once(&onceToken, ^{
        keyboardManager = [[CCKeyboardManager alloc] init];
    });
    return keyboardManager;
}

- (void)dealloc
{
    for (NSDictionary *dict in _textFieldInfoCache) {
        UIView *view = dict[kCCTextFiled];
        
        if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
            UITextField *textField = (UITextField *)view;
            textField.returnKeyType = [dict[kCCTextFiledReturnKeyType] integerValue];
            textField.delegate = dict[kCCTextFiledDelegate];
        }
    }
    
    [_textFieldInfoCache removeAllObjects];
}

/**
 销毁单列
 */
- (void)freed
{
    onceToken = 0;
    keyboardManager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    if (self = [super init]) {
        [self registeredWithViewController:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        _keyboardDistanceFromTextField = 10;
        _animationDuration = 0.25;
    }
    return self;
}

#pragma mark -
#pragma mark :. 初始化注册
- (void)registeredWithViewController:(nullable UIViewController *)controller
{
    if (controller.view) {
        _rootViewController = controller;
        _topViewBeginRect = controller.view.frame;
        _textFieldInfoCache = [NSMutableSet set];
        [self addResponderFromView:controller.view];
    }
}

- (NSDictionary *)textFieldViewCachedInfo:(UIView *)textField
{
    for (NSDictionary *infoDict in _textFieldInfoCache)
        if (infoDict[kCCTextFiled] == textField) return infoDict;
    
    return nil;
}

#pragma mark -
#pragma mark :. UIKeyboad Notification methods
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    _keyboardShowing = YES;
    NSInteger curve = [[aNotification userInfo][UIKeyboardAnimationCurveUserInfoKey] integerValue];
    _animationCurve = curve << 16;
    CGFloat duration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (duration != 0.0) _animationDuration = duration;
    
    CGSize oldKBSize = _kSize;
    CGRect kbFrame = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGRect intersectRect = CGRectIntersection(kbFrame, screenSize);
    
    if (CGRectIsNull(intersectRect))
        _kSize = CGSizeMake(screenSize.size.width, 0);
    else
        _kSize = intersectRect.size;
    
    if (!CGSizeEqualToSize(_kSize, oldKBSize)) {
        if (_keyboardShowing == YES &&
            _textFieldView != nil &&
            [_textFieldView isAlertViewTextField] == NO) {
            [self adjustFrame];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    _keyboardShowing = NO;
    
    CGFloat aDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (aDuration != 0.0f)
        _animationDuration = aDuration;
    
    [self setRootViewFrame:self.topViewBeginRect];
    _kSize = CGSizeZero;
}

/**
 调整位置
 */
- (void)adjustFrame
{
    UIWindow *keyWindow = [self keyWindow];
    CGRect textFieldViewRect = [[_textFieldView superview] convertRect:_textFieldView.frame toView:keyWindow];
    CGRect rootViewRect = self.rootViewController.view.frame;
    
    CGSize kbSize = _kSize;
    kbSize.height += _keyboardDistanceFromTextField;
    
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat topLayoutGuide = CGRectGetHeight(statusBarFrame);
    
    CGFloat move = MIN(CGRectGetMinY(textFieldViewRect) - (topLayoutGuide + 5), CGRectGetMaxY(textFieldViewRect) - (CGRectGetHeight(keyWindow.frame) - kbSize.height));
    
    if (move >= 0) {
        rootViewRect.origin.y -= move;
        rootViewRect.origin.y = MAX(rootViewRect.origin.y, MIN(0, -kbSize.height + _keyboardDistanceFromTextField));
        [self setRootViewFrame:rootViewRect];
    } else {
        CGFloat disturbDistance = CGRectGetMinY(rootViewRect) - CGRectGetMinY(_topViewBeginRect);
        if (disturbDistance < 0) {
            rootViewRect.origin.y -= MAX(move, disturbDistance);
            [self setRootViewFrame:rootViewRect];
        }
    }
}

- (void)setRootViewFrame:(CGRect)controllerFrame
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_animationDuration
                          delay:0
                        options:(_animationCurve | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         __strong typeof(self) strongSelf = weakSelf;
                         [strongSelf.rootViewController.view setFrame:controllerFrame];
                     }
                     completion:NULL];
}

- (UIWindow *)keyWindow
{
    if (_textFieldView.window) {
        return _textFieldView.window;
    } else {
        static UIWindow *_keyWindow = nil;
        UIWindow *originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
        if (originalKeyWindow != nil && _keyWindow != originalKeyWindow)
            _keyWindow = originalKeyWindow;
        
        return _keyWindow;
    }
}

#pragma mark -
#pragma mark :. add/remove TextFields
- (void)addResponderFromView:(UIView *)view
{
    NSArray *textFields = [view deepResponderViews];
    
    for (UIView *textField in textFields)
        [self addTextFieldView:textField];
}

- (void)removeResponderFromView:(UIView *)view
{
    NSArray *textFields = [view deepResponderViews];
    
    for (UIView *textField in textFields)
        [self removeTextFieldView:textField];
}

- (void)removeTextFieldView:(UIView *)view
{
    NSDictionary *dict = [self textFieldViewCachedInfo:view];
    
    if (dict) {
        if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
            UITextField *textField = (UITextField *)view;
            textField.returnKeyType = [dict[kCCTextFiledReturnKeyType] integerValue];
            textField.delegate = dict[kCCTextFiledDelegate];
        }
        [_textFieldInfoCache removeObject:dict];
    }
}

- (void)addTextFieldView:(UIView *)view
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kCCTextFiled] = view;
    
    if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
        UITextField *textField = (UITextField *)view;
        dict[kCCTextFiledReturnKeyType] = @(textField.returnKeyType);
        if (textField.delegate) dict[kCCTextFiledDelegate] = textField.delegate;
        [textField setDelegate:self];
    }
    
    [_textFieldInfoCache addObject:dict];
}

#pragma mark -
#pragma mark :. TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
        return [delegate textFieldShouldBeginEditing:textField];
    else
        return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _textFieldView = textField;
    
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
        [delegate textFieldDidBeginEditing:textField];
    
    if (_keyboardShowing == YES &&
        _textFieldView != nil &&
        [_textFieldView isAlertViewTextField] == NO) {
        [self adjustFrame];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
        return [delegate textFieldShouldEndEditing:textField];
    else
        return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
        [delegate textFieldDidEndEditing:textField];
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    id<UITextFieldDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textField];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:reason:)])
        [delegate textFieldDidEndEditing:textField reason:reason];
}

#endif

#pragma mark -
#pragma mark :. TextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
        return [delegate textViewShouldBeginEditing:textView];
    else
        return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewShouldEndEditing:)])
        return [delegate textViewShouldEndEditing:textView];
    else
        return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _textFieldView = textView;
    
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidBeginEditing:)])
        [delegate textViewDidBeginEditing:textView];
    
    if (_keyboardShowing == YES &&
        _textFieldView != nil &&
        [_textFieldView isAlertViewTextField] == NO) {
        [self adjustFrame];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidEndEditing:)])
        [delegate textViewDidEndEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    BOOL shouldReturn = YES;
    if ([delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
        shouldReturn = [delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    
    return shouldReturn;
}

- (void)textViewDidChange:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidChange:)])
        [delegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textViewDidChangeSelection:)])
        [delegate textViewDidChangeSelection:textView];
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:interaction:)])
        return [delegate textView:textView shouldInteractWithURL:URL inRange:characterRange interaction:interaction];
    else
        return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:interaction:)])
        return [delegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange interaction:interaction];
    else
        return YES;
}
#endif

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)])
        return [delegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
    else
        return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    id<UITextViewDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        NSDictionary *dict = [self textFieldViewCachedInfo:textView];
        delegate = dict[kCCTextFiledDelegate];
    }
    
    if ([delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)])
        return [delegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    else
        return YES;
}

@end
