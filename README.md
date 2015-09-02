# LGDelayedTaskManager
A manager allows you to register a task in the form of block or selector and fire later.

##Usage
Just include 4 files:

`ILSPPDelayedTaskManager.h`

`ILSPPDelayedTaskManager.m`

`NSPointerArray+AbstractionHelpers.h`

`NSPointerArray+AbstractionHelpers.m` 

and you are good to go. 

[NSPointerArray+AbstractionHelper](https://gist.github.com/RungeZhai/1f2607f57fbab6b5254a) is an encapsulated category making NSPointerArray NSArray/NSMutableArray-like and easier to use.

### Add/register task
```objective-c
- (void)addDelayAction:(SEL)action target:(id)target;

- (void)addDelayAction:(SEL)action target:(id)target identifier:(NSString *)ID;

- (void)addDelayTask:(ILSPPDelayedTask)task;

- (void)addDelayTask:(ILSPPDelayedTask)task identifier:(NSString *)ID;
```

### Fire task
```objective-c
- (void)fireTaskWithIdentifer:(NSString *)ID;

- (void)fireTasksWithIdentifer:(NSString *)ID;

- (void)fireTaskWithTarget:(id)target;

- (void)fireTasksWithTarget:(id)target;

- (void)fireTasksPassingIdentifierTest:(BOOL (^)(NSString *ID, BOOL *stop))predicate;

- (void)fireAllTasks;
```

### Remove task
```objective-c
- (void)removeTasksWithTarget:(id)target action:(SEL)action;

- (void)removeTasksWithTarget:(id)target action:(SEL)action identifier:(NSString *)ID;

- (void)removeTasksWithIdentifier:(NSString *)ID;

- (void)removeTasksWithTarget:(id)target;

- (void)removeTasksPassingIdentifierTest:(BOOL (^)(NSString *ID, BOOL *stop))predicate;

- (void)removeTasksAtIndexes:(NSIndexSet *)indexSet;

- (void)removeAllTasks;
```

### Retrive task
```objective-c
- (BOOL)hasTaskWithIdentifier:(NSString *)identifier;

/**
 Traverse every task by order
 @param target when the task type is ILSPPDelayedTaskTypeBlock, 
        or the object target points to was dealloced, target will be nil
 @param action either SEL or ILSPPDelayedTask, depends on the type parameter
 @param ID     the identifier of the task
 @param type   the type of the task, see ILSPPDelayedTaskType for details
 @param index  the index of the target
 */
- (void)enumerateTasksUsingBlock:(void (^)(id target, void *action, NSString *ID, ILSPPDelayedTaskType type, NSUInteger index, BOOL *stop))block;
```

### Caution
LGDelayedTaskManager is not thread-safe. It is intended to be as simple as possible.
