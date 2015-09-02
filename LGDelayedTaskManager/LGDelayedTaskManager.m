//
//  LGDelayedTaskManager.m
//  ZiXuWuYou
//
//  Created by liuge on 8/19/15.
//  Copyright (c) 2015 ZiXuWuYou. All rights reserved.
//

#import "LGDelayedTaskManager.h"
#import "NSPointerArray+AbstractionHelpers.h"

@interface LGDelayedTaskManager ()
{
    NSPointerArray *_actionStack;
    NSPointerArray *_targetStack;
    NSPointerArray *_identifierStack;
}
@end

@implementation LGDelayedTaskManager

+ (instancetype)defaultManager {
    
    static LGDelayedTaskManager *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [LGDelayedTaskManager new];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _actionStack     = [NSPointerArray strongObjectsPointerArray];
        _targetStack     = [NSPointerArray weakObjectsPointerArray];
        _identifierStack = [NSPointerArray strongObjectsPointerArray];
    }
    return self;
}

- (void)addDelayAction:(SEL)action target:(id)target {
    [self addDelayAction:action target:target identifier:nil];
}

- (void)addDelayAction:(SEL)action target:(id)target identifier:(NSString *)ID {
    [_actionStack addObject:NSStringFromSelector(action)];
    [_targetStack addObject:target];
    [_identifierStack addObject:ID];
}

- (void)addDelayTask:(LGDelayedTask)task {
    [self addDelayTask:task identifier:nil];
}

- (void)addDelayTask:(LGDelayedTask)task identifier:(NSString *)ID {
    [_actionStack addObject:task];
    [_targetStack addObject:nil];
    [_identifierStack addObject:ID];
}

- (void)removeTasksWithTarget:(id)target action:(SEL)action {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < _targetStack.count; ++i) {
        id aTarget = _targetStack[i];
        
        NSString *selector = _actionStack[i];
        if (![selector isKindOfClass:[NSString class]]) continue;
        
        SEL anAction = NSSelectorFromString(selector);
        
        if ([aTarget isEqual:target] && anAction == action) {
            [indexSet addIndex:i];
        }
    }
    
    [self removeTasksAtIndexes:indexSet];
}

- (void)removeTasksWithTarget:(id)target action:(SEL)action identifier:(NSString *)ID {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < _targetStack.count; ++i) {
        id aTarget = _targetStack[i];
        
        NSString *selector = _actionStack[i];
        if (![selector isKindOfClass:[NSString class]]) continue;
        
        SEL anAction = NSSelectorFromString(selector);
        
        NSString *aID = _identifierStack[i];
        
        if ([aTarget isEqual:target] && anAction == action && [aID isEqualToString:ID]) {
            [indexSet addIndex:i];
        }
    }
    
    [self removeTasksAtIndexes:indexSet];
}

- (void)removeTasksWithIdentifier:(NSString *)ID {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < _identifierStack.count; ++i) {
        NSString *identifier = _identifierStack[i];
        if ([ID isEqualToString:identifier]) {
            [indexSet addIndex:i];
        }
    }
    
    [self removeTasksAtIndexes:indexSet];
}

- (void)removeTasksWithTarget:(id)target {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < _targetStack.count; ++i) {
        id aTarget = _targetStack[i];
        if ([aTarget isEqual:target]) {
            [indexSet addIndex:i];
        }
    }
    
    [self removeTasksAtIndexes:indexSet];
}

- (void)removeTasksPassingIdentifierTest:(BOOL (^)(NSString *ID, BOOL *stop))predicate {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < _identifierStack.count; ++i) {
        NSString *identifier = _identifierStack[i];
        BOOL stopFlag = NO;
        
        if (predicate(identifier, &stopFlag)) {
            [indexSet addIndex:i];
        }
        
        if (stopFlag) break;
    }
    
    [self removeTasksAtIndexes:indexSet];
}

- (void)removeTasksAtIndexes:(NSIndexSet *)indexSet {
    [_actionStack removeObjectsAtIndexes:indexSet];
    [_targetStack removeObjectsAtIndexes:indexSet];
    [_identifierStack removeObjectsAtIndexes:indexSet];
}

- (void)removeAllTasks {
    [_actionStack removeAllObjects];
    [_targetStack removeAllObjects];
    [_identifierStack removeAllObjects];
}

- (BOOL)hasTaskWithIdentifier:(NSString *)identifier {
    return [_identifierStack containsObject:identifier];
}

- (void)enumerateTasksUsingBlock:(void (^)(id , void *, NSString *, LGDelayedTaskType , NSUInteger , BOOL *))block {
    for (NSUInteger index = 0; index < _identifierStack.count; ++index) {
        
        NSString *ID = _identifierStack[index];
        id target = _targetStack[index];
        void *action = [_actionStack pointerAtIndex:index];
        
        LGDelayedTaskType type = LGDelayedTaskTypeBlock;
        
        if ([(__bridge id)action isKindOfClass:[NSString class]]) {
            type = LGDelayedTaskTypeSEL;
            action = NSSelectorFromString((__bridge id)action);
        }
        
        BOOL stop = NO;
        
        if (block) {
            block(target, action, ID, type, index, &stop);
        }
        
        if (stop) break;
    }
}

- (void)fireTaskWithIdentifer:(NSString *)ID {
    [self fireTaskWithIdentifer:ID once:YES];
}

- (void)fireTasksWithIdentifer:(NSString *)ID {
    [self fireTaskWithIdentifer:ID once:NO];
}

- (void)fireTaskWithIdentifer:(NSString *)ID once:(BOOL)once {
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < _identifierStack.count; ++i) {
        NSString *identifier = _identifierStack[i];
        if ([ID isEqualToString:identifier]) {
            
            id action = _actionStack[i];
            
            if ([action isKindOfClass:[NSString class]]) {
                SEL selector = NSSelectorFromString(action);
                id target = _targetStack[i];
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                
                [target performSelector:selector withObject:nil];
                
#pragma clang diagnostic pop
            } else {
                ((LGDelayedTask)action)();
            }
            
            [indexSet addIndex:i];
            
            if (once) break;
        }
    }
    
    [self removeTasksAtIndexes:indexSet];
}

- (void)fireTaskWithTarget:(id)target {
    [self fireTaskWithTarget:target once:YES];
}

- (void)fireTasksWithTarget:(id)target {
    [self fireTaskWithTarget:target once:NO];
}

- (void)fireTaskWithTarget:(id)target once:(BOOL)once {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < _targetStack.count; ++i) {
        id aTarget = _targetStack[i];
        if ([target isEqual:aTarget]) {
            
            id action = _actionStack[i];
            SEL selector = NSSelectorFromString(action);
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            
            [target performSelector:selector withObject:nil];
            
#pragma clang diagnostic pop
            
            [indexSet addIndex:i];
            
            if (once) break;
        }
    }
    
    [self removeTasksAtIndexes:indexSet];
}

- (void)fireTasksPassingIdentifierTest:(BOOL (^)(NSString *ID, BOOL *stop))predicate {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < _identifierStack.count; ++i) {
        NSString *identifier = _identifierStack[i];
        BOOL stopFlag = NO;
        
        if (predicate(identifier, &stopFlag)) {
            id target = _targetStack[i];
            
            id action = _actionStack[i];
            
            if ([action isKindOfClass:[NSString class]]) {
                SEL selector = NSSelectorFromString(action);
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                
                [target performSelector:selector withObject:nil];
                
#pragma clang diagnostic pop
            } else {
                ((LGDelayedTask)action)();
            }
            
            [indexSet addIndex:i];
        }
        
        if (stopFlag) break;
    }
    
    [self removeTasksAtIndexes:indexSet];
}

- (void)fireAllTasks {
    for (NSInteger i = 0; i < _identifierStack.count; ++i) {
        id target = _targetStack[i];
        
        id action = _actionStack[i];
        
        if ([action isKindOfClass:[NSString class]]) {
            SEL selector = NSSelectorFromString(action);
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            
            [target performSelector:selector withObject:nil];
            
#pragma clang diagnostic pop
        } else {
            ((LGDelayedTask)action)();
        }
    }
    
    [_actionStack removeAllObjects];
    [_targetStack removeAllObjects];
    [_identifierStack removeAllObjects];
}

@end
