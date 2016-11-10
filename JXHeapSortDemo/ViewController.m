//
//  ViewController.m
//  JXHeapSortDemo
//
//  Created by JiongXing on 2016/11/8.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "ViewController.h"
#import "LineView.h"
#import "NSMutableArray+JXHeapSort.h"

static const CGFloat kNodeSize = 34;

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray<UILabel *> *nodeArray;
@property (nonatomic, strong) NSMutableArray<LineView *> *lineArray;

@property (nonatomic, assign) BOOL signal;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化资源
    self.nodeArray = [NSMutableArray array];
    self.lineArray = [NSMutableArray array];
    [self onReset:nil];
}

- (IBAction)onSort:(UIButton *)sender {
    if (self.signal) {
        return;
    }
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    // 定时发出信号，以允许继续交换
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.6 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (self.signal) {
            dispatch_semaphore_signal(sema);
        }
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.signal = YES;
        [self.nodeArray jx_heapSortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            // 比较两个结点
            return [self compareWithNodeA:obj1 nodeB:obj2];
        } didExchange:^(id obj1, id obj2) {
            // 交换两结点
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            [self exchangeNodeA:obj1 nodeB:obj2];
        } didCut:^(id obj, NSInteger index) {
            // 剪枝
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            [self cutNode:obj index:index];
        }];
        [timer invalidate];
        self.signal = NO;
    });
}

- (NSComparisonResult)compareWithNodeA:(UILabel *)nodeA nodeB:(UILabel *)nodeB {
    NSInteger num1 = [nodeA.text integerValue];
    NSInteger num2 = [nodeB.text integerValue];
    if (num1 == num2) {
        return NSOrderedSame;
    }
    return num1 < num2 ? NSOrderedAscending : NSOrderedDescending;
}

- (void)exchangeNodeA:(UILabel *)nodeA nodeB:(UILabel *)nodeB {
    dispatch_async(dispatch_get_main_queue(), ^{
        nodeA.backgroundColor = [UIColor yellowColor];
        nodeB.backgroundColor = [UIColor yellowColor];
        [UIView animateWithDuration:0.4 animations:^{
            CGRect temp = nodeA.frame;
            nodeA.frame = nodeB.frame;
            nodeB.frame = temp;
        } completion:^(BOOL finished) {
            nodeA.backgroundColor = [UIColor whiteColor];
            nodeB.backgroundColor = [UIColor whiteColor];
        }];
    });
}

- (void)cutNode:(UILabel *)node index:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        node.backgroundColor = [UIColor lightGrayColor];
        [self.lineArray[index - 1] removeFromSuperview];
    });
}

- (IBAction)onReset:(UIButton *)sender {
    if (self.signal) {
        return;
    }
    
    [self.nodeArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.nodeArray removeAllObjects];
    
    [self.lineArray enumerateObjectsUsingBlock:^(LineView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.lineArray removeAllObjects];
    
    NSArray<NSNumber *> *data = @[@50, @10, @80, @30, @70, @20, @90, @40, @100, @60];
    [data enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self nodeWithIndex:idx].text = [NSString stringWithFormat:@"%@", obj];
    }];
    [self reloadData];
}

- (void)reloadData {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat nodeSpaceHeight = 60;
    for (NSInteger index = 1; index <= self.nodeArray.count; index ++) {
        // 从0开始
        NSInteger level = log2f(index);
        // 本层最多有多少个结点
        NSInteger count = powf(2, level);
        // 给本层的结点编号，从0开始
        NSInteger sequence = index % count;
        // 一个结点所属的空间宽度
        CGFloat nodeSpaceWidth = width / (2 * count);
        CGFloat centerX = (1 + sequence * 2) * nodeSpaceWidth;
        CGFloat centerY = (1 + level) * nodeSpaceHeight;
        
        // 画结点
        UILabel *node = self.nodeArray[index - 1];
        node.center = CGPointMake(centerX, centerY);
        node.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:node];
        
        // 画线
        if (index > 1) {
            UILabel *parentNode = [self nodeWithIndex:index / 2 - 1];
            LineView *line = [self lineWithIndex:index - 1];
            line.isRight = sequence % 2 == 1;
            CGFloat lineX = line.isRight ? parentNode.center.x : node.center.x;
            line.frame = CGRectMake(lineX,
                                    parentNode.center.y,
                                    ABS(node.center.x - parentNode.center.x),
                                    ABS(node.center.y - parentNode.center.y));
            [self.view insertSubview:line atIndex:0];
        }
    }
}

- (UILabel *)nodeWithIndex:(NSInteger)index {
    if (self.nodeArray.count < index + 1) {
        return [self generateNode];
    }
    return self.nodeArray[index];
}

- (LineView *)lineWithIndex:(NSInteger)index {
    if (self.lineArray.count < index + 1) {
        return [self generateLine];
    }
    return self.lineArray[index];
}

- (UILabel *)generateNode {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kNodeSize, kNodeSize)];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.borderColor = [UIColor blackColor].CGColor;
    label.layer.borderWidth = 1;
    label.layer.cornerRadius = kNodeSize / 2;
    label.layer.masksToBounds = YES;
    [self.nodeArray addObject:label];
    return label;
}

- (LineView *)generateLine {
    LineView *line = [[LineView alloc] init];
    [self.lineArray addObject:line];
    return line;
}

@end
