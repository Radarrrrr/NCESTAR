//
//  DDScrollButton.h
//  DDDevLib
//
//  Created by Radar on 12-10-15.
//  Copyright (c) 2012年 www.dangdang.com. All rights reserved.
//

// PS: 本模块目前仅支持使用图片来做item元素，不含文字
// PS: 同一时间，只能有一个按钮处于选中状态，或者全部都不是选中状态
/* 使用方法:
    1.创建scrollBtnView
    DDScrollButton *scrollBtnView = [[DDScrollButton alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width, self.frame.size.height-10)];
    scrollBtnView.delegate = self;
    scrollBtnView.selectionSyle = styleNone;
    [self addSubview:scrollBtnView];
    [scrollBtnView release];

    2.给scrollBtnView添加按钮，使用按钮元素数组和按钮配置参数字典
    NSArray *items = @[
                         @{@"image_name":@"xxx.png", @"image_name_sel":@"xxx_sel.png"},
                         @{@"image_name":@"yyy.png", @"image_name_sel":@"yyy_sel.png"}
                      ]
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:60], @"btn_width",
                            [NSNumber numberWithInt:60], @"btn_height",
                            [NSNumber numberWithInt:70], @"btn_blank_offset",
                            [NSNumber numberWithInt:80], @"btn_pos_offset_x",
                            [NSNumber numberWithInt:50], @"btn_move_offset",
                            nil];
    [scrollBtnView addButtonsForItems:items withParams:params];
*/

#import <UIKit/UIKit.h>



typedef enum {
	styleNone,          //任何选择状态都不做
	styleSelected,      //选中以后切换到UIControlStateSelected状态
	styleDisabled       //选中以后切换到UIControlStateDisabled状态
} SelectionStyle;   //button的选中状态


typedef enum {
	posNomal,
	posMaxLeft,
	posMaxRight
} ScrollButtonsPositon; //按钮队列滚动到的位置



@class DDScrollButton;
@protocol DDScrollButtonDelegate <NSObject>
@optional
-(void)scrollButtonChooseIndex:(NSInteger)index; //return index for choose, can use this index find the item attached to button
-(void)scrollButtonsScrollToPosition:(ScrollButtonsPositon)position; //按钮队列左右滑动停止以后，返回当前处于那种位置状态
-(void)scrollButtonsContentViewOverLoad:(BOOL)bOverLoad contentPositon:(ScrollButtonsPositon)contentPosition; //所有按钮队列超出了本类范围，有pos类型返回来确认是处于那种状态
@end


@interface DDScrollButton : UIView <UIScrollViewDelegate> {

	NSArray *_buttons;    
    NSDictionary *_btnParams;  
    
    UIScrollView *_scrollView;
    NSInteger _selectedIndex; //default is -1
    
    SelectionStyle _selectionSyle; //default is styleNone
    
@private
	id _delegate;	
}

@property (assign) id<DDScrollButtonDelegate> delegate;  //(必选) 设定代理
@property (nonatomic) SelectionStyle selectionSyle;      //(可选) 设定按钮的选中状态, default is styleNone

@property (nonatomic) NSInteger selectedIndex;           //(供外部使用) 当前选中的按钮的index，如果一个都没选中则为－1
@property (nonatomic, retain) UIScrollView *scrollView;  //(供外部使用) 滚动按钮的容器，大小和本类view的大小相同，如果需要改变，则需要使用-(void)setScrollButtonFrame:(CGRect)frame;




#pragma mark -
#pragma mark out use functions && can also be use in class
//给scrollview添加按钮数组，并附带配置属性
/*参数结构如下: //PS:文字和图片任选其一，不可以同时存在
 
//[可选]数据结构1: 有图片的时候需要设定的属性 
items = @[
            @{
                @"image_name"     :@"xxx.png",                        //[必须]按钮图片
                @"image_name_sel" :@"xxx_sel.png",                    //[可选]按钮选中状态图片
            },
            ....
         ];
 
//[可选]数据结构2: 有title的时候需要设定的属性
items = @[
            @{
                @"title"             :@"xxxxx",                       //[必须]title文字
                @"title_sel"         :@"xxxxx",                       //[可选]title选中状态文字
                @"title_color"       :[UIColor whiteColor],           //[可选]title的颜色
                @"title_color_sel"   :[UIColor redColor],             //[可选]title的选中时高亮颜色
                @"title_font"        :[UIFont systemFontOfSize:14.0], //[可选]title的字体大小
                @"bg_color"          :[UIColor grayColor],            //[可选]背景的颜色
                @"bg_color_sel"      :[UIColor darkGrayColor]         //[可选]背景的选中颜色
             },
             ....
         ];
 
//[必须]按钮行的属性
params = @{
             @"btn_width"        :[NSNumber numberWithInt:60], //按钮宽度
             @"btn_height"       :[NSNumber numberWithInt:60], //按钮高度
             @"btn_blank_offset" :[NSNumber numberWithInt:60], //两个按钮之间空白的宽度
             @"btn_pos_offset_x" :[NSNumber numberWithInt:60], //第一个按钮起始位置距离scrollview最左侧的偏移量
             @"btn_move_offset"  :[NSNumber numberWithInt:60], //向左右两侧滑动时最大偏移量距离
          };
*/
//PS: "image_name"字段必须有，否则会crash 
//PS: "image_name_sel" 字段可以不写，如果不写，则默认没有选中状态
//PS: 字典key必须和这个例子一样，否则找不到配置数据
-(void)addButtonsForItems:(NSArray*)items withParams:(NSDictionary*)params;


-(void)chooseButtonForIndex:(NSInteger)index bReturnToDelegate:(BOOL)bReturnTodele; //选择一个index对应的按钮，并添加是否需要返回代理的标志
-(void)clearChoose;                              //清空选择状态，让所有的按钮都处于未选择状态，完成后 selectedIndex＝－1
-(void)moveButtonsToLeft;                        //把按钮都移动到最左侧
-(void)moveButtonsToRight;                       //把按钮都移动到最右侧
-(void)setScrollButtonFrame:(CGRect)frame;       //重新设定当前scrollbuttonview的位置frame




@end
