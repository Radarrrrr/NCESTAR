#import <UIKit/UIKit.h>

@interface ISGumView : UIView

@property (nonatomic) BOOL shrinking;
@property (nonatomic) CGFloat distance;
@property (nonatomic, retain) UIColor *tintColor;

- (void)shrink;

@end
