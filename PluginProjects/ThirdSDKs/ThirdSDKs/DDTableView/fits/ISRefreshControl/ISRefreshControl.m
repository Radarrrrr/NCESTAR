#import "ISRefreshControl.h"
#import "ISGumView.h"
#import "ISScalingActivityIndicatorView.h"
#import "ISMethodSwizzling.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, ISRefreshingState) {
    ISRefreshingStateNormal,
    ISRefreshingStateRefreshing,
    ISRefreshingStateRefreshed,
};

static CGFloat const ISThreshold = 100.f;

@interface ISRefreshControl ()

@property (nonatomic) BOOL addedTopInset;
@property (nonatomic) CGFloat offset;
@property (nonatomic) ISRefreshingState refreshingState;
@property (nonatomic, retain) ISGumView *gumView;
@property (nonatomic, retain) ISScalingActivityIndicatorView *indicatorView;
@property (nonatomic, retain) UILabel *label;

@property (nonatomic) CGFloat ISAdditionalTopInset;

@end


@implementation ISRefreshControl

+ (void)load
{
    @autoreleasepool {
        if (![UIRefreshControl class]) {
            objc_registerClassPair(objc_allocateClassPair([ISRefreshControl class], "UIRefreshControl", 0));
        } else {
#ifndef IS_TEST_FROM_COMMAND_LINE
            ISSwizzleClassMethod([ISRefreshControl class], @selector(alloc), @selector(_alloc));
#endif
        }
    }
}

+ (id)_alloc
{
    if ([UIRefreshControl class]) {
        return (id)[UIRefreshControl alloc];
    }
    return [self _alloc];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.gumView = [[[ISGumView alloc] init] autorelease];
    [self addSubview:self.gumView];
    
    self.indicatorView = [[[ISScalingActivityIndicatorView alloc] init] autorelease];
    [self addSubview:self.indicatorView];
    
    [self addObserver:self forKeyPath:@"tintColor" options:0 context:NULL];
    
    UIColor *tintColor = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0) {
        tintColor = [[ISRefreshControl appearance] tintColor];
    }
    if (tintColor) {
        self.tintColor = tintColor;
    }
    
    self.ISAdditionalTopInset = 50.f;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle{
    if (_attributedTitle) {
        [_attributedTitle release];
        _attributedTitle = nil;
    }
    _attributedTitle = [[NSAttributedString alloc] initWithAttributedString:attributedTitle];
    if (!self.label) {
        self.label = [[[UILabel alloc] init] autorelease];
        self.ISAdditionalTopInset = 70.0;
        self.frame = CGRectMake(0, -70.0, self.superview.frame.size.width, 70.0);
        self.label.frame = CGRectMake(0, 50 - 5.0, 320, 20.0);
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:12];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor colorWithRed:149/255.0 green:156/255.0 blue:165/255.0 alpha:1.0];
        [self addSubview:self.label];
        
        UIScrollView *scrollView = (id)self.superview;
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = self.ISAdditionalTopInset;
        scrollView.contentInset = inset;
    }
    self.label.text = [_attributedTitle string];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"tintColor"];
    
    [_tintColor release];
    [_attributedTitle release];
    
    [_gumView release];
    [_indicatorView release];
    [_label release];
    [super dealloc];
}

#pragma mark -

- (BOOL)isRefreshing
{
    return self.refreshingState == ISRefreshingStateRefreshing;
}

#pragma mark - view events

- (void)layoutSubviews
{
    CGFloat width = self.frame.size.width;
    self.gumView.frame = CGRectMake(width/2.f-17.5, 25-15, 35, 90);
    self.indicatorView.frame = CGRectMake(width/2.f-15, 25-15, 30, 30);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)didMoveToSuperview
{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
        
        self.frame = CGRectMake(0, -50, self.superview.frame.size.width, 50);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self setNeedsLayout];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.superview && [keyPath isEqualToString:@"contentOffset"]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        self.offset = scrollView.contentOffset.y;
        
        //改变label的位置
        if (self.label) {
            CGPoint origin = CGPointMake(0, 50 - 5);
            CGRect frame = self.label.frame;
            if (-self.offset > 70.0) {
                frame.origin.y = origin.y + (- self.offset - 70);
            }
            else {
                frame.origin.y = origin.y;
            }
            self.label.frame = frame;
        }
        
        [self keepOnTopOfView];
        [self sendDistanceToGumView];
        [self updateGumViewVisible];
        
        if (self.refreshingState == ISRefreshingStateNormal && self.offset <= -ISThreshold && scrollView.isTracking) {
            [self beginRefreshing];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        if (self.refreshingState == ISRefreshingStateRefreshing && !scrollView.isDragging && !self.addedTopInset) {
            [self addTopInsets];
        }
        if (self.refreshingState == ISRefreshingStateRefreshed && self.offset >= scrollView.contentInset.top - 5.f) {
            [self reset];
        }
        return;
    }
    
    if (object == self && [keyPath isEqualToString:@"tintColor"]) {
        self.gumView.tintColor = self.tintColor;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0) {
            self.indicatorView.color = self.tintColor;
        }
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)keepOnTopOfView
{
    if (self.offset < -self.ISAdditionalTopInset) {
        self.frame = CGRectMake(0, self.offset, self.frame.size.width, self.frame.size.height);
    } else {
        self.frame = CGRectMake(0, -self.ISAdditionalTopInset, self.frame.size.width, self.frame.size.height);
    }
}

- (void)sendDistanceToGumView
{
    if (self.gumView.shrinking) {
        return;
    }
    self.gumView.distance = self.offset < -self.ISAdditionalTopInset ? -self.offset-self.ISAdditionalTopInset : 0.f;
}

- (void)updateGumViewVisible
{
    // hides gumView when it is about to appear by inertial scrolling.
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    if (scrollView.isTracking && !self.isRefreshing) {
        self.hidden = (self.offset > 0);
    }
}

#pragma mark -

- (void)beginRefreshing
{
    if (self.isRefreshing) {
        return;
    }
    
    self.refreshingState = ISRefreshingStateRefreshing;
    [self.indicatorView startAnimating];
    [self.gumView shrink];
}

- (void)endRefreshing
{
    if (!self.isRefreshing) {
        return;
    }
    
    [self.indicatorView stopAnimating];
    
    if (self.addedTopInset) {
        [self subtractTopInsets];
    } else {
        self.refreshingState = ISRefreshingStateRefreshed;
    }
}

- (void)reset
{
    self.gumView.hidden = NO;
    self.indicatorView.hidden = YES;
    self.refreshingState = ISRefreshingStateNormal;
}

- (void)addTopInsets
{
    self.addedTopInset = YES;
    
    UIScrollView *scrollView = (id)self.superview;
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top += self.ISAdditionalTopInset;
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         scrollView.contentInset = inset;
                     }];
}

- (void)subtractTopInsets
{
    UIScrollView *scrollView = (id)self.superview;
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top -= self.ISAdditionalTopInset;
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         scrollView.contentInset = inset;
                     }
                     completion:^(BOOL finished) {
                         self.addedTopInset = NO;
                         
                         if (self.offset <= [(UIScrollView *)self.superview contentInset].top) {
                             [self reset];
                         } else {
                             self.refreshingState = ISRefreshingStateRefreshed;
                         }
                     }];
}

@end
