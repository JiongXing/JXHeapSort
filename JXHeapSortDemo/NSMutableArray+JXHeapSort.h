//
//  NSMutableArray+JXHeapSort.h
//  JXHeapSortDemo
//
//  Created by JiongXing on 2016/11/8.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSComparisonResult(^JXSortComparator)(id obj1, id obj2);
typedef void(^JXSortExchangeCallback)(id obj1, id obj2);
typedef void(^JXSortCutCallback)(id obj, NSInteger index);

@interface NSMutableArray (JXHeapSort)

// 堆排序
- (void)jx_heapSortUsingComparator:(JXSortComparator)comparator didExchange:(JXSortExchangeCallback)exchangeCallback didCut:(JXSortCutCallback)cutCallback;

@end
