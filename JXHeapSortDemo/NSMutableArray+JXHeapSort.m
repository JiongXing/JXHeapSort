//
//  NSMutableArray+JXHeapSort.m
//  JXHeapSortDemo
//
//  Created by JiongXing on 2016/11/8.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "NSMutableArray+JXHeapSort.h"

@implementation NSMutableArray (JXHeapSort)

/// 堆排序
- (void)jx_heapSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback didCut:(JXSortCutCallback)cutCallback {
    // 排序过程中不使用第0位
    [self insertObject:[NSNull null] atIndex:0];
    
    // 构造大顶堆
    // 遍历所有非终结点，把以它们为根结点的子树调整成大顶堆
    // 最后一个非终结点位置在本队列长度的一半处
    for (NSInteger index = self.count / 2; index > 0; index --) {
        // 根结点下沉到合适位置
        [self sinkIndex:index bottomIndex:self.count - 1 usingComparator:comparator didExchange:exchangeCallback];
    }
    
    // 完全排序
    // 从整棵二叉树开始，逐渐剪枝
    for (NSInteger index = self.count - 1; index > 1; index --) {
        // 每次把根结点放在列尾，下一次循环时将会剪掉
        [self jx_exchangeWithIndexA:1 indexB:index didExchange:exchangeCallback];
        if (cutCallback) {
            cutCallback(self[index], index - 1);
        }
        // 下沉根结点，重新调整为大顶堆
        [self sinkIndex:1 bottomIndex:index - 1 usingComparator:comparator didExchange:exchangeCallback];
    }
    
    // 排序完成后删除占位元素
    [self removeObjectAtIndex:0];
}

/// 下沉，传入需要下沉的元素位置，以及允许下沉的最底位置
- (void)sinkIndex:(NSInteger)index bottomIndex:(NSInteger)bottomIndex usingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback {
    for (NSInteger maxChildIndex = index * 2; maxChildIndex <= bottomIndex; maxChildIndex *= 2) {
        // 如果存在右子结点，并且左子结点比右子结点小
        if (maxChildIndex < bottomIndex && (comparator(self[maxChildIndex], self[maxChildIndex + 1]) == NSOrderedAscending)) {
            // 指向右子结点
            ++ maxChildIndex;
        }
        // 如果最大的子结点元素小于本元素，则本元素不必下沉了
        if (comparator(self[maxChildIndex], self[index]) == NSOrderedAscending) {
            break;
        }
        // 否则
        // 把最大子结点元素上游到本元素位置
        [self jx_exchangeWithIndexA:index indexB:maxChildIndex didExchange:exchangeCallback];
        // 标记本元素需要下沉的目标位置，为最大子结点原位置
        index = maxChildIndex;
    }
}

/// 交换两个元素
- (void)jx_exchangeWithIndexA:(NSInteger)indexA indexB:(NSInteger)indexB didExchange:(JXSortExchangeCallback)exchangeCallback {
    id temp = self[indexA];
    self[indexA] = self[indexB];
    self[indexB] = temp;
    
    if (exchangeCallback) {
        exchangeCallback(temp, self[indexA]);
    }
}

@end
