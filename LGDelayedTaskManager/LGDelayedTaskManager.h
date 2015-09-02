//
//  LGDelayedTaskManager.h
//  ZiXuWuYou
//
//  Created by liuge on 8/19/15.
//  Copyright (c) 2015 ZiXuWuYou. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^LGDelayedTask)();

typedef enum : NSUInteger {
    LGDelayedTaskTypeBlock,
    LGDelayedTaskTypeSEL,
} LGDelayedTaskType;

@interface LGDelayedTaskManager : NSObject

+ (instancetype)defaultManager;

- (void)addDelayAction:(SEL)action target:(id)target;

- (void)addDelayAction:(SEL)action target:(id)target identifier:(NSString *)ID;

- (void)addDelayTask:(LGDelayedTask)task;

- (void)addDelayTask:(LGDelayedTask)task identifier:(NSString *)ID;

- (void)removeTasksWithTarget:(id)target action:(SEL)action;

- (void)removeTasksWithTarget:(id)target action:(SEL)action identifier:(NSString *)ID;

- (void)removeTasksWithIdentifier:(NSString *)ID;

- (void)removeTasksWithTarget:(id)target;

- (void)removeTasksPassingIdentifierTest:(BOOL (^)(NSString *ID, BOOL *stop))predicate;

- (void)removeTasksAtIndexes:(NSIndexSet *)indexSet;

- (void)removeAllTasks;

- (BOOL)hasTaskWithIdentifier:(NSString *)identifier;

/**
 Traverse every task by order
 @param target when the task type is LGDelayedTaskTypeBlock, 
        or the object target points to was dealloced, target will be nil
 @param action either SEL or LGDelayedTask, depends on the type parameter
 @param ID     the identifier of the task
 @param type   the type of the task, see LGDelayedTaskType for details
 @param index  the index of the target
 */
- (void)enumerateTasksUsingBlock:(void (^)(id target, void *action, NSString *ID, LGDelayedTaskType type, NSUInteger index, BOOL *stop))block;

/**
 *  Fire 1st task of specific identifier.
 */
- (void)fireTaskWithIdentifer:(NSString *)ID;

/**
 *  Fire ALL tasks of specific identifier.
 */
- (void)fireTasksWithIdentifer:(NSString *)ID;

/**
 *  Fire 1st task of specific target.
 */
- (void)fireTaskWithTarget:(id)target;

/**
 *  Fire ALL tasks of specific target
 */
- (void)fireTasksWithTarget:(id)target;

- (void)fireTasksPassingIdentifierTest:(BOOL (^)(NSString *ID, BOOL *stop))predicate;

- (void)fireAllTasks;

@end
