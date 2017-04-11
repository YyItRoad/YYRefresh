
#import "UIScrollView+YYRefresh.h"
#import "MJRefresh.h"
#import "UIScrollView+EmptyDataSet.h"
#import <objc/runtime.h>

@interface YYWeakObjectContainer : NSObject

@property (nonatomic, readonly, weak) id weakObject;

- (instancetype)initWithWeakObject:(id)object;

@end


static char const * const kRefreshDelegate =    "refreshDelegate";
static char const * const kRefreshState =       "refreshState";
static char const * const kRefreshSupport =     "refreshSupport";
static char const * const kRefreshStateModel =  "refreshStateModel";

@interface UIScrollView (__YYRefresh)<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic, strong) YYRefreshStateModel *stateModel;

@end

@implementation UIScrollView (YYRefresh)

- (void)setRefreshState:(YYRefreshState)refreshState {
    [self setRefreshState:refreshState customData:nil];
}

- (void)setRefreshState:(YYRefreshState)refreshState customData:(YYRefreshStateModel *)stateModel {
    if (!stateModel) {
        stateModel = [YYRefreshStateModel defaultModelWithState:refreshState];
    }
    self.stateModel = stateModel;
    objc_setAssociatedObject(self, kRefreshState, @(refreshState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}


- (YYRefreshState)refreshState {
    return (YYRefreshState)[objc_getAssociatedObject(self, kRefreshState) integerValue];
}

#pragma mark - DZNEmptyDataSetDelegate & DZNEmptyDataSetSource
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(refreshView:customViewForState:)]) {
        [self.refreshDelegate refreshView:self customViewForState:self.refreshState];
    }
    return nil;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return self.stateModel.title;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    return self.stateModel.desc;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return self.stateModel.image;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return YES;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView{
    //默认不展示，需要自行设置
    if (self.refreshState == YYRefreshNone) {
        return NO;
    }
    return YES;
}

- (BOOL)emptyDataSetShouldFadeIn:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark- refresh/loadMore
- (void)offerRefreshHeaderView {
    if ([self.refreshDelegate respondsToSelector:@selector(refreshHeaderViewWithTarget:refreshingAction:)]) {
        self.mj_header = [self.refreshDelegate refreshHeaderViewWithTarget:self refreshingAction:@selector(mj_refresh)];
    }else{
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(mj_refresh)];
    }
}

- (void)offerRefreshFooterView {
    if ([self.refreshDelegate respondsToSelector:@selector(refreshFooterViewWithTarget:refreshingAction:)]) {
        self.mj_footer = [self.refreshDelegate refreshFooterViewWithTarget:self refreshingAction:@selector(mj_loadMore)];
    }else{
        self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(mj_loadMore)];
    }
}

- (void)mj_loadMore {
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(viewWillRefresh:)]) {
        [self.refreshDelegate viewWillLoadMore:self];
    }
}

- (void)mj_refresh {
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(viewWillRefresh:)]) {
        [self.refreshDelegate viewWillRefresh:self];
    }
}

#pragma mark - set/get

- (void)setStateModel:(YYRefreshStateModel *)stateModel {
    objc_setAssociatedObject(self, kRefreshStateModel, stateModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (YYRefreshStateModel *)stateModel {
    return objc_getAssociatedObject(self, kRefreshStateModel);
}

- (void)setRefreshSupport:(YYRefreshSupport)refreshSupport {
    objc_setAssociatedObject(self, kRefreshSupport, @(refreshSupport), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    switch (refreshSupport) {
        case YYRefreshSupportNone:
        {
            self.mj_header = nil;
            self.mj_footer = nil;
        }
            break;
        case YYRefreshSupportRefresh:
        {
            [self offerRefreshHeaderView];
            self.mj_footer = nil;
        }
            break;
        case YYRefreshSupportLoadMore:
        {
            [self offerRefreshFooterView];
            self.mj_header = nil;
        }
            break;
        case YYRefreshSupportAll:
        {
            [self offerRefreshHeaderView];
            [self offerRefreshFooterView];
        }
            break;
        default:
            break;
    }
}

- (YYRefreshSupport)refreshSupport {
    return (YYRefreshSupport)[objc_getAssociatedObject(self, kRefreshSupport) integerValue];
}

- (id<YYRefreshDelegate>)refreshDelegate
{
    YYWeakObjectContainer *container = objc_getAssociatedObject(self, kRefreshDelegate);
    return container.weakObject;
}

- (void)setRefreshDelegate:(id<YYRefreshDelegate>)refreshDelegate {
    if (refreshDelegate) {
        objc_setAssociatedObject(self, kRefreshDelegate, [[YYWeakObjectContainer alloc] initWithWeakObject:refreshDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        class_addProtocol([self class],objc_getProtocol([@"DZNEmptyDataSetSource" UTF8String]));
        class_addProtocol([self class],objc_getProtocol([@"DZNEmptyDataSetDelegate" UTF8String]));
        self.emptyDataSetSource = self;
        self.emptyDataSetDelegate = self;
        self.refreshSupport = YYRefreshSupportRefresh;
        self.refreshState = YYRefreshLoading;
    }
}

@end

#pragma mark - DZNWeakObjectContainer

@implementation YYWeakObjectContainer

- (instancetype)initWithWeakObject:(id)object
{
    self = [super init];
    if (self) {
        _weakObject = object;
    }
    return self;
}

@end

@implementation YYRefreshStateModel


+ (instancetype)defaultModelWithState:(YYRefreshState)state {
    YYRefreshStateModel *stateModel = [YYRefreshStateModel new];
    
    NSString *titleText = nil;
    UIFont *titleFont = nil;
    UIColor *titleTextColor = nil;
    
    NSString *descText = nil;
    UIFont *descFont = nil;
    UIColor *descTextColor = nil;
    
    switch (state)
    {
        case YYRefreshDefault:
        {
            titleText = @"暂无数据";
            titleFont = [UIFont systemFontOfSize:16];
            titleTextColor = [UIColor lightGrayColor];
            stateModel.image = [UIImage imageNamed:@"dzn_empty"];
        }
            break;
        case YYRefreshLoading:
        {
            titleText = @"正在加载";
            titleFont = [UIFont systemFontOfSize:16];
            titleTextColor = [UIColor lightGrayColor];
            stateModel.image = [UIImage imageNamed:@"dzn_loading"];
        }
            break;
        case YYRefreshNetworkError:
        {
            titleText = @"网络错误";
            titleFont = [UIFont systemFontOfSize:16];
            titleTextColor = [UIColor lightGrayColor];
            stateModel.image = [UIImage imageNamed:@"dzn_netError"];
        }
            break;
        default:
            break;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (titleText) {
        if (titleFont) [attributes setObject:titleFont forKey:NSFontAttributeName];
        if (titleTextColor) [attributes setObject:titleTextColor forKey:NSForegroundColorAttributeName];
        stateModel.title = [[NSMutableAttributedString alloc] initWithString:titleText attributes:attributes];
    }
    if (descText) {
        if (descFont) [attributes setObject:descFont forKey:NSFontAttributeName];
        if (descTextColor) [attributes setObject:descTextColor forKey:NSForegroundColorAttributeName];
        stateModel.desc = [[NSMutableAttributedString alloc] initWithString:descText attributes:attributes];
    }
    return stateModel;
}

@end
