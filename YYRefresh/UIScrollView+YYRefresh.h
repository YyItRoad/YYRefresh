/**
 *
 *  整合DZNEmptyDataSet 和 MJRefresh
 *  11/04/2017
 *
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YYRefreshState) {
    YYRefreshNone = 0,          //无
    YYRefreshDefault,           //默认
    YYRefreshLoading,           //加载
    YYRefreshNetworkError,      //网络错误
};

typedef NS_ENUM(NSInteger, YYRefreshSupport) {
    //提供刷新和加载更多功能
    YYRefreshSupportAll,
    //不提供
    YYRefreshSupportNone,
    //提供刷新
    YYRefreshSupportRefresh,
    //提供加载更多
    YYRefreshSupportLoadMore
};

@interface YYRefreshStateModel : NSObject

@property (nonatomic,strong) NSAttributedString *title;

@property (nonatomic,strong) NSAttributedString *desc;

@property (nonatomic,strong) UIImage *image;

+ (instancetype)defaultModelWithState:(YYRefreshState)state;

@end

@class MJRefreshHeader,MJRefreshFooter;
@protocol YYRefreshDelegate <NSObject>

@optional

- (void)viewWillRefresh:(UIScrollView *)view;

- (void)viewWillLoadMore:(UIScrollView *)view;

//自定义下拉刷新视图
- (MJRefreshHeader *)refreshHeaderViewWithTarget:(id)target refreshingAction:(SEL)action;
//自定义上拉加载视图
- (MJRefreshFooter *)refreshFooterViewWithTarget:(id)target refreshingAction:(SEL)action;

//自定义空视图
- (UIView *)refreshView:(UIScrollView *)view customViewForState:(YYRefreshState)state;
//自定义空数据
- (YYRefreshStateModel *)refreshView:(UIScrollView *)view customDataState:(YYRefreshState)state;

@end

@interface UIScrollView (YYRefresh)

//@property (assign, nonatomic) SEL refreshingAction;

@property (nonatomic, weak) IBOutlet id <YYRefreshDelegate> refreshDelegate;

@property (nonatomic, assign) YYRefreshState refreshState;

@property (nonatomic, assign) YYRefreshSupport refreshSupport;

/**
 设置空状态信息
 @param refreshState 状态
 @param stateModel 数据
 */
- (void)setRefreshState:(YYRefreshState)refreshState customData:(YYRefreshStateModel *)stateModel;

@end
