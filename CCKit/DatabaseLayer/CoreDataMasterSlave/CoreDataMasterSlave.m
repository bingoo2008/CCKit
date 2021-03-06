//
//  CoreDataMasterSlave.m
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

#import "CoreDataMasterSlave.h"
#import "CoreDataManager.h"

NSString *const CoreDataMasterSlaveCurrentThreadContext = @"CoreDataMasterSlave_CurrentThread_Context";

@implementation CoreDataMasterSlave

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  单例
 *
 *  @return 返回对象
 */
+ (id)sharedlnstance
{
    static CoreDataMasterSlave *_sharedlnstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedlnstance = [[self alloc] init];
    });
    return _sharedlnstance;
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  默认私有管理对象
 *
 *  @return 返回私有管理对象
 */
+ (NSManagedObjectContext *)defaultPrivateContext
{
    return [CoreDataManager sharedlnstance].privateContext;
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  默认主管理对象
 *
 *  @return 返回主管理对象
 */
+ (NSManagedObjectContext *)defaultMainContext
{
    return [CoreDataManager sharedlnstance].mainContext;
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  当前管理对象
 *
 *  @return 返回当前管理对象
 */
+ (NSManagedObjectContext *)currentContext
{
    if ([NSThread isMainThread])
        return [self defaultMainContext];
    
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    NSManagedObjectContext *context = [threadDict objectForKey:CoreDataMasterSlaveCurrentThreadContext];
    
    if (!context) {
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [context setParentContext:[self defaultPrivateContext]];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        context.undoManager = nil;
        [threadDict setObject:context forKey:CoreDataMasterSlaveCurrentThreadContext];
    }
    
    return context;
}
@end
