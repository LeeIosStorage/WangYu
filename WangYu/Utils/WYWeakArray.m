//
//  WYWeakArray.m
//  WangYu
//
//  Created by Leejun on 15/6/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYWeakArray.h"

@interface WYWeakRefObject : NSObject

@property(nonatomic, weak) id target;

+ (id)refWithTarget: (id)target;
@end
@implementation WYWeakRefObject

+ (id)refWithTarget: (id)target {
    WYWeakRefObject* weakRef = [[WYWeakRefObject alloc] init];
    weakRef.target = target;
    return weakRef;
}

@end

@interface WYWeakArray () {
    NSMutableArray *_weakRefs;
}

@end

@implementation WYWeakArray

- (id)init
{
    if((self = [super init]))
    {
        _weakRefs = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)numItems
{
    if((self = [super init]))
    {
        _weakRefs = [[NSMutableArray alloc] initWithCapacity:numItems];
    }
    return self;
}

- (id)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    self = [self initWithCapacity:cnt];
    
    for(NSInteger i = 0; i < cnt; i++)
        if(objects[i] != nil)
            [self addObject:objects[i]];
    
    return self;
}


- (NSUInteger)count
{
    return [_weakRefs count];
}

- (id)objectAtIndex: (NSUInteger)index
{
    return [[_weakRefs objectAtIndex: index] target];
}

- (void)addObject: (id)anObject
{
    if (!anObject) {
        return;
    }
    [_weakRefs addObject: [WYWeakRefObject refWithTarget: anObject]];
}

- (void)insertObject: (id)anObject atIndex: (NSUInteger)index
{
    if (!anObject) {
        return;
    }
    [_weakRefs insertObject: [WYWeakRefObject refWithTarget: anObject]
                    atIndex: index];
}
- (void)removeObject:(id)anObject {
    for (WYWeakRefObject *ref in _weakRefs) {
        id obj = [ref target];
        if (obj == nil || obj == anObject) {
            [_weakRefs removeObject:ref];
            return;
        }
    }
}
- (void)removeLastObject
{
    [_weakRefs removeLastObject];
}

- (void)removeObjectAtIndex: (NSUInteger)index
{
    [_weakRefs removeObjectAtIndex: index];
}

- (void)replaceObjectAtIndex: (NSUInteger)index withObject: (id)anObject
{
    if (!anObject) {
        return;
    }
    [_weakRefs replaceObjectAtIndex: index
                         withObject: [WYWeakRefObject refWithTarget: anObject]];
}

-(id)copy{
    int count = (int)_weakRefs.count;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];
    NSMutableArray *nilTargetObjArray = nil;//target为nil的情况，ios下很诡异，有时候target会等于nil
    for (int i =0 ; i<count; i++) {
        WYWeakRefObject *obj =_weakRefs[i];
        if (obj && obj.target) {
            [array addObject:obj.target];
        }else {
            //如果target==nil，把这个obj移除掉免得引起crash
            if (nilTargetObjArray == nil) {
                nilTargetObjArray = [[NSMutableArray alloc] init];
            }
            [nilTargetObjArray addObject:obj];
        }
    }
    if (nilTargetObjArray) {
        [_weakRefs removeObjectsInArray:nilTargetObjArray];
    }
    return array;
}

@end
