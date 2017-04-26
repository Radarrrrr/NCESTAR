//
//  DDTableView.h
//  Radar Use
//
//  Created by Radar on 13-5-29.
//  Copyright (c) 2012年 www.dangdang.com. All rights reserved.
//

#import "DDTableView.h"
#import "DDFunction.h"



#pragma mark -
#pragma mark in use functions and params
@interface DDTableView ()

@property (nonatomic, retain) NSMutableArray *insertArray;  //插入数据的NSIndexPath数组，用来做动画插入的
@property (nonatomic, retain) NSMutableArray *deleteArray;  //删除数据的NSIndexPath数组，用来做动画删除的

- (NSString*)cellClassNameForIndexPath:(NSIndexPath *)indexPath;
- (id)cellDataForIndexPath:(NSIndexPath*)indexPath;

- (float)lastCellHeight;  //获取最后一个section的最后一个cell的高度

- (NSMutableDictionary*)emptyDictionaryForSectionStucture;       //创建空的字典供section使用
- (NSMutableDictionary*)dictionaryForSection:(NSInteger)section; //检查并创建然后获取section对应的字典, 返回的secDic必然存在

- (void)dragRefreshAction:(ISRefreshControl *)refreshControl; //下拉刷新触发事件

- (NSMutableArray*)rowsDatasForSection:(NSInteger)section; //找到section对应的组里边的所有行的数据数组

@end



@implementation DDTableView
@synthesize delegate = _delegate;
@synthesize tableView = _tableView;
@synthesize dataArray = _dataArray;
@synthesize refreshStyle = _refreshStyle;
@synthesize loadMoreStyle = _loadMoreStyle;
@synthesize moreFooterView = _moreFooterView;
@synthesize refreshCoverView = _refreshCoverView;
@synthesize dragRefreshControll = _dragRefreshControll;
@synthesize insertArray = _insertArray;
@synthesize deleteArray = _deleteArray;
@synthesize editRowEnabled = _editRowEnabled;
@synthesize moveRowEnabled = _moveRowEnabled;

@dynamic multiSelectEnabled;
@dynamic refreshDateParams;
@dynamic headerLogo;
@dynamic footerLogo;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        
        _refreshStyle = RefreshStyleNone;
        _loadMoreStyle = LoadMoreStyleNone;

        _loadingType = loadingNone;
        
        _editRowEnabled = NO;
        _moveRowEnabled = NO;
        
        //初始化dataArray
        self.dataArray = [[[NSMutableArray alloc] init] autorelease];
        self.insertArray = [[[NSMutableArray alloc] init] autorelease];
        self.deleteArray = [[[NSMutableArray alloc] init] autorelease];

		//add table view
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		[self addSubview:_tableView];
        
        //add _moreFooterView
        self.moreFooterView = [[[DDTMoreFooterView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1000)] autorelease];
        _moreFooterView.delegate = self;
        
        //add _refreshCoverView
        self.refreshCoverView = [[[DDTRefreshCoverView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
        _refreshCoverView.delegate = self;
        
        //add _dragRefreshControll
        self.dragRefreshControll = [[[ISRefreshControl alloc] init] autorelease];
        [_dragRefreshControll addTarget:self action:@selector(dragRefreshAction:) forControlEvents:UIControlEventValueChanged];
        
        //这俩可以通过外面调用dragRefreshControll来修改，这里只是用来作备忘的
        //_dragRefreshControll.attributedTitle = [[NSAttributedString alloc] initWithString:@"123"];
        //_dragRefreshControll.tintColor = [UIColor greenColor];
        
        
        //这两个在调用的地方修改，这里只是用来做备忘的
        //_tableView.backgroundColor = [UIColor whiteColor];
        //_tableView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
        
    }
    return self;
}

- (void)dealloc 
{
	[_tableView release];
	[_dataArray release];
    [_moreFooterView release];
    [_refreshCoverView release];
    [_logoHeaderView release];
    [_logoFooterView release];
    [_dragRefreshControll release];
    [_refreshDateParams release];
    [_headerLogo release];
    [_footerLogo release];
    [_insertArray release];
    [_deleteArray release];
	
    [super dealloc];
}





#pragma mark -
#pragma mark setter & getter functions
- (void)setMultiSelectEnabled:(BOOL)multiSelectEnabled
{
    _multiSelectEnabled = multiSelectEnabled;
    _tableView.allowsMultipleSelection = _multiSelectEnabled;
}
- (BOOL)multiSelectEnabled
{
    return _multiSelectEnabled;
}


- (void)setHeaderLogo:(UIImage *)aheaderLogo
{
    [_headerLogo release];
    _headerLogo = nil;
    if(aheaderLogo)
    {
        _headerLogo = [aheaderLogo retain];
    }
    
    //创建logoview
    if(_headerLogo)
    {
        if(!_logoHeaderView)
        {
            _logoHeaderView = [[DDTLogoView alloc] initWithFrame:CGRectMake(0, -1000, self.frame.size.width, 1000) withPosition:positionHeader];
            _logoHeaderView.logo = _headerLogo;
        }
    }
    else
    {
        if(_logoHeaderView && [_logoHeaderView superview])
        {
            [_logoHeaderView removeFromSuperview];
        }
    }
}
- (UIImage*)headerLogo
{
    return _headerLogo;
}


- (void)setFooterLogo:(UIImage *)afooterLogo
{
    [_footerLogo release];
    _footerLogo = nil;
    if(afooterLogo)
    {
        _footerLogo = [afooterLogo retain];
    }
    
    //创建logoview
    if(_footerLogo)
    {
        if(!_logoFooterView)
        {
            _logoFooterView = [[DDTLogoView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 1000) withPosition:positionFooter];
            _logoFooterView.logo = _footerLogo;
        }
    }
    else
    {
        if(_logoFooterView && [_logoFooterView superview])
        {
            [_logoFooterView removeFromSuperview];
        }
    }
}
- (UIImage*)footerLogo
{
    return _footerLogo;
}

- (void)setRefreshDateParams:(NSDictionary *)params
{
    [_refreshDateParams release];
    _refreshDateParams = nil;
    if(params)
    {
        _refreshDateParams = [params retain];
    }
    
    //用这个数据的placeholde改动_dragRefreshControll的默认文字
    NSAttributedString *placeHolder = [DDTableView lastRefreshDateAttributed:_refreshDateParams isPlaceholder:YES];
    if(_dragRefreshControll && placeHolder)
    {
        _dragRefreshControll.attributedTitle = placeHolder;
        
        if(![_dragRefreshControll superview])
        {
            [_tableView addSubview:_dragRefreshControll];
        }
    }

}
- (NSDictionary*)refreshDateParams
{
    return _refreshDateParams;
}




#pragma mark -
#pragma mark in use functions and params
- (NSString*)cellClassNameForIndexPath:(NSIndexPath*)indexPath
{
    if(!indexPath) return nil;
    if(!_dataArray || [_dataArray count] == 0) return nil;
    
    NSString *cellClassName = nil;
    
    NSString *path = [NSString stringWithFormat:@"%d.rows.%d.cell", (int)indexPath.section, (int)indexPath.row];
    cellClassName = (NSString*)[DDFunction valueOfData:_dataArray byPath:path];
    
    return cellClassName;
}
- (id)cellDataForIndexPath:(NSIndexPath*)indexPath
{
    if(!indexPath) return nil;
    if(!_dataArray || [_dataArray count] == 0) return nil;
    
    id data = nil;
    
    NSString *path = [NSString stringWithFormat:@"%d.rows.%d.data", (int)indexPath.section, (int)indexPath.row];
    data = [DDFunction valueOfData:_dataArray byPath:path];
    
    return data;
}

- (float)lastCellHeight
{
    //获取最后一个section的最后一个cell的高度
    float cellHeight = ddtableview_default_row_height;
    
    if(!_dataArray || [_dataArray count] == 0 || [self checkIfDatasClear]) return cellHeight;
    
    //找到最后一个section
    NSInteger section = [_dataArray count]-1;
    
    //找到最后一个row
    NSMutableDictionary *secDic = [_dataArray objectAtIndex:section];
    NSMutableArray *rows = [secDic objectForKey:@"rows"];
    if(!rows || [rows count] == 0)
    {
        return cellHeight;
    }
    
    NSInteger row = [rows count]-1;
    
    //组合indexpath
    NSUInteger ints[2] = {section, row};
	NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
    
    //获取该cell的高度
    cellHeight = [self tableView:_tableView heightForRowAtIndexPath:indexPath];
    
    return cellHeight;
}

- (NSMutableDictionary*)emptyDictionaryForSectionStucture 
{
    //创建空的字典供section使用
    NSMutableDictionary *emptyDic = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSMutableDictionary *paramsDic = [[[NSMutableDictionary alloc] init] autorelease];
    NSMutableArray      *rowsArray = [[[NSMutableArray alloc] init] autorelease];
    
    [emptyDic setObject:paramsDic forKey:@"section_params"];
    [emptyDic setObject:rowsArray forKey:@"rows"];
    
    return emptyDic;
}

- (NSMutableDictionary*)dictionaryForSection:(NSInteger)section
{
    //检查并创建然后获取section对应的字典, 返回的secDic必然存在
    if(!_dataArray)
    {
        self.dataArray = [[[NSMutableArray alloc] init] autorelease];
    }
    
    NSString *spath = [NSString stringWithFormat:@"%d", (int)section];
    id secDic = [DDFunction valueOfData:_dataArray byPath:spath];
    
    //有现成的secDic，就直接返回使用
    if(secDic) return secDic;
    
    
    //没有现成的secDic，那么创建新的补齐从现有个数直到section指定的个数
    NSInteger count = [_dataArray count];
    for(NSInteger i=count; i<=section; i++)
    {
        //创建空字典添加到数组里边去,补齐需要的个数
        NSMutableDictionary *emptyDic = [self emptyDictionaryForSectionStucture];
        [_dataArray addObject:emptyDic];
    }
    
    //再重新取一次secDic
    NSString *npath = [NSString stringWithFormat:@"%d", (int)section];
    id useDic = [DDFunction valueOfData:_dataArray byPath:npath];
    
    return useDic;
}

- (void)dragRefreshAction:(ISRefreshControl *)refreshControl
{
    //下拉刷新触发事件
    //只有当前读取状态是None的时候才触发刷新, 否则这次就算白下拉了
    if(_loadingType == loadingNone)
    {
        [self tableTrigger:triggerRefresh];
    }
    else
    {
        if(_dragRefreshControll)
        {
            [_dragRefreshControll endRefreshing];
        }
    }
}


- (void)checkAndTriggerLoadMore
{
    if(_loadingType != loadingNone) return;
    if(_loadMoreStyle != LoadMoreStyleAuto) return;
    if(!_moreFooterView) return;
    
    
    //检查是否需要加载更多
    CGPoint cntOffset = _tableView.contentOffset;
    CGSize  cntSize   = _tableView.contentSize;
    CGRect  rect = _tableView.frame;
    
    if(cntSize.height >= rect.size.height)
    {
        if(cntOffset.y >= cntSize.height-rect.size.height-more_footer_height)
        {
            //加载更多触发                
            [self tableTrigger:triggerLoadMore];
        }
    }
}

- (NSMutableArray*)rowsDatasForSection:(NSInteger)section
{
    //找到section对应的组里边的所有行的数据数组
    if(!_dataArray || [_dataArray count] == 0) return nil;
    
    NSString *secPath = [NSString stringWithFormat:@"%d", (int)section];
    NSMutableDictionary *secDic = [DDFunction valueOfData:_dataArray byPath:secPath];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return nil;
    
    NSMutableArray *rows = [secDic objectForKey:@"rows"];
    if(!rows || ![rows isKindOfClass:[NSMutableArray class]]) return nil;
    
    return rows;
}




#pragma mark -
#pragma mark Table View DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    NSInteger count = 1;
    
    if(_dataArray && [_dataArray count] != 0)
    {
        count = [_dataArray count];
    }
    
	return count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if(!_dataArray || [_dataArray count] == 0) return 0;
    
    NSInteger count = 0;
        
    NSString *path = [NSString stringWithFormat:@"%d.rows", (int)section];
    NSArray *rows = [DDFunction valueOfData:_dataArray byPath:path];
    if(rows && [rows count] != 0)
    {
        count = [rows count];
    }
    
	return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //获取cellID 
    //PS: 这里的kCellID其实就是要用到的类的类名，用类名直接做cell的重用ID了
    NSString *cellClassName = [self cellClassNameForIndexPath:indexPath];
    
	
    //开始创建cell
    UITableViewCell *cell = nil;
    
    if(cellClassName && [cellClassName compare:@""] != NSOrderedSame)
    {
        //获得cell的类型
        Class CellClass = NSClassFromString(cellClassName);
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellClassName];
        if(cell == nil)
        {
            cell = [[[CellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellClassName] autorelease];
            
            //这两个在调用的地方修改，这里只是用来做备忘的
            //cell.accessoryType = UITableViewCellAccessoryNone;
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        
        //获取cell所用的数据
        id data = [self cellDataForIndexPath:indexPath];
        
        
        //设定cell的data
        if(cell && [[cell class] isSubclassOfClass:[UITableViewCell class]])
        {
            if([cell respondsToSelector:@selector(setCellData:atIndexPath:)])
            {
                [cell performSelector:@selector(setCellData:atIndexPath:) withObject:data withObject:indexPath];
            }
        }
        
        //设定cell所处的indexPath
        if(cell && [[cell class] isSubclassOfClass:[UITableViewCell class]])
        {
            if([cell respondsToSelector:@selector(setCellIndexPath:)])
            {
                [cell performSelector:@selector(setCellIndexPath:) withObject:indexPath];
            }
        }
    }
    
    
    //如果cell没创建成功，返回一个空白页面，防止crash
    if(!cell)
    {
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"a blank cell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"a blank cell"];
            cell.backgroundColor = [UIColor clearColor];
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //获取该cell所用的数据
    id data = [self cellDataForIndexPath:indexPath];
    	
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(DDTableViewDidSelectIndexPath:withData:ontable:)])
	{
		[self.delegate DDTableViewDidSelectIndexPath:indexPath withData:data ontable:self];
	}
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //获取该cell所用的数据
    id data = [self cellDataForIndexPath:indexPath];
    
	if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(DDTableViewDidDeselectIndexPath:withData:ontable:)])
	{
		[self.delegate DDTableViewDidDeselectIndexPath:indexPath withData:data ontable:self];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //创造一个testcell
    NSString *cellClassName = [self cellClassNameForIndexPath:indexPath];
    if(!cellClassName || [cellClassName compare:@""] == NSOrderedSame) return ddtableview_default_row_height;
    
    Class CellClass = NSClassFromString(cellClassName);
    UITableViewCell *testcell = [[CellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"testCell"];
    
    float height = ddtableview_default_row_height;
    
	if([[testcell class] isSubclassOfClass:[UITableViewCell class]])
    {
        if([testcell respondsToSelector:@selector(setCellData:atIndexPath:)])
        {
            id data = [self cellDataForIndexPath:indexPath];
            [testcell performSelector:@selector(setCellData:atIndexPath:) withObject:data withObject:indexPath];
            
            height = testcell.contentView.frame.size.height;
        }
    }
    
    [testcell release];
    
	return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    float height = 0.0;
    
    NSString *hhpath = [NSString stringWithFormat:@"%d.section_params.header_height", (int)section];
    NSString *hvpath = [NSString stringWithFormat:@"%d.section_params.header_view", (int)section];
    
    NSString *headerH = (NSString*)[DDFunction valueOfData:_dataArray byPath:hhpath];
    UIView   *headerV = (UIView*)[DDFunction valueOfData:_dataArray byPath:hvpath];
    
    if(headerH || headerV)
    {
        if(headerV)
        {
            height = headerV.frame.size.height;
        }
        else
        {
            height = [headerH floatValue];
        }
    }
        
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    float height = 0.0;
    
    NSString *fhpath = [NSString stringWithFormat:@"%d.section_params.footer_height", (int)section];
    NSString *fvpath = [NSString stringWithFormat:@"%d.section_params.footer_view", (int)section];
    
    NSString *footerH = (NSString*)[DDFunction valueOfData:_dataArray byPath:fhpath];
    UIView   *footerV = (UIView*)[DDFunction valueOfData:_dataArray byPath:fvpath];
    
    if(footerH || footerV)
    {
        if(footerV)
        {
            height = footerV.frame.size.height;
        }
        else
        {
            height = [footerH floatValue];
        }
    }

    return height;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *hView = nil;
    
    NSString *hvpath = [NSString stringWithFormat:@"%d.section_params.header_view", (int)section];
    UIView   *headerV = (UIView*)[DDFunction valueOfData:_dataArray byPath:hvpath];
    if(headerV)
    {
        hView = headerV;
    }
    
    return hView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *fView = nil;
    
    NSString *fvpath = [NSString stringWithFormat:@"%d.section_params.footer_view", (int)section];
    UIView   *footerV = (UIView*)[DDFunction valueOfData:_dataArray byPath:fvpath];
    if(footerV)
    {
        fView = footerV;
    }
        
    return fView;
}



//编辑行相关方法
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath  
{  
    return UITableViewCellEditingStyleDelete;  
}  
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath  
{  
    return  @"完成";  
}  
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) 
    {  
        //点击了删除
        [self deleteDataAtIndexPath:indexPath];
        [self refreshTableWithAnimation:UITableViewRowAnimationFade];
        
        //返回给代理
        if(self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(DDTableViewDidDeleteRowAtIndexPath:ontable:)])
        {
            [self.delegate DDTableViewDidDeleteRowAtIndexPath:indexPath ontable:self];
        }
    }  
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _editRowEnabled;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _moveRowEnabled;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if(!_dataArray || [_dataArray count] == 0) return;
    
    //拿到source对应的数据数组    
    NSMutableArray *sourceRows = [self rowsDatasForSection:sourceIndexPath.section];
    if(!sourceRows || [sourceRows count] == 0) return;
    if(sourceIndexPath.row >= [sourceRows count]) return;
    
    //找到destination对应的数据数组
    NSMutableArray *destRows = [self rowsDatasForSection:destinationIndexPath.section];
    if(!destRows) return;
    
    
    //移动source对应的数据到destination位置
    id sourceData = [sourceRows objectAtIndex:sourceIndexPath.row];
    [sourceData retain];
    
    //移除这一行数据
    [sourceRows removeObjectAtIndex:sourceIndexPath.row];
    
    //插入到destRows的数组里边
    [destRows insertObject:sourceData atIndex:destinationIndexPath.row];
    [sourceData release];
    
    //返回代理
    if(self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(DDTableViewDidMoveRowFrom:to:ontable:)])
	{
		[self.delegate DDTableViewDidMoveRowFrom:sourceIndexPath to:destinationIndexPath ontable:self];
	}

}




#pragma mark -
#pragma mark UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(DDTableViewDidScroll:)])
	{
		[self.delegate DDTableViewDidScroll:self];
	}
    
    //检查是否需要触发读取,只有自动触发才判断，手动的不理
    if(_loadMoreStyle == LoadMoreStyleAuto)
    {
        [self checkAndTriggerLoadMore];
    }
    
    //如果有logoview，做显示方面的改动
    if(_refreshStyle == RefreshStyleNone)
    {
        if(_headerLogo && _logoHeaderView)
        {
            CGPoint cntOffset = _tableView.contentOffset;
            if(cntOffset.y < 0)
            {
                float showHeight = -cntOffset.y;
                [_logoHeaderView setShowHeight:showHeight];
            }
        }
    }
    
    if(_loadMoreStyle == LoadMoreStyleNone)
    {
        if(_footerLogo && _logoFooterView)
        {
            CGPoint cntOffset = _tableView.contentOffset;
            CGSize  cntSize   = _tableView.contentSize;
            CGRect  rect = _tableView.frame;
            if(cntOffset.y > cntSize.height-rect.size.height)
            {
                float showHeight = cntOffset.y - (cntSize.height-rect.size.height);
                [_logoFooterView setShowHeight:showHeight];
            }
        }
    }

}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(DDTableViewDidEndDecelerating:)])
	{
		[self.delegate DDTableViewDidEndDecelerating:self];
	}
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(DDTableViewDidEndDragging:willDecelerate:)])
	{
		[self.delegate DDTableViewDidEndDragging:self willDecelerate:decelerate];
	}
}






#pragma mark -
#pragma mark other delegate functions
//DDTMoreFooterViewDelegate
- (void)moreFooterViewDidTapTrigger
{
    //加载更多触发                
    [self tableTrigger:triggerLoadMore];
}

//DDTRefreshCoverViewwDelegate
- (void)refreshCoverViewDidTapTrigger
{
    //刷新触发                
    [self tableTrigger:triggerRefresh];
    
}









#pragma mark -
#pragma mark 配套使用方法，供外部使用对内部的列表进行一些其他操作，更多方法随版本升级逐渐扩展...
- (void)selectIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    if(!indexPath) return;
    [_tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)deselectIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated
{
    if(!indexPath) return;
    [_tableView deselectRowAtIndexPath:indexPath animated:animated];
}

- (void)deselectAllInSection:(NSInteger)section animated:(BOOL)animated
{
    //找到section对应的rows
    NSString *secPath = [NSString stringWithFormat:@"%d", (int)section];
    NSMutableDictionary *secDic = [DDFunction valueOfData:_dataArray byPath:secPath];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return;
    
    NSMutableArray *rows = [secDic objectForKey:@"rows"];
    if(!rows || ![rows isKindOfClass:[NSMutableArray class]] || [rows count] == 0) return;
    
    for(int i=0; i<[rows count]; i++)
    {
        NSUInteger ints[2] = {section, i};
        NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
        [_tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [_tableView setEditing:editing animated:animated];
}

- (BOOL)checkIfDatasClear
{
    //检查是否数据已经被清空或者完全无数据，不考虑section的属性
    BOOL cleared = YES;
    
    NSArray *rowsArrs = [DDFunction findValuesForKey:@"rows" inData:_dataArray];
    if(rowsArrs && [rowsArrs count] != 0)
    {
        for(id rowsArr in rowsArrs)
        {
            if([rowsArr isKindOfClass:[NSArray class]])
            {
                if([(NSArray*)rowsArr count] != 0)
                {
                    cleared = NO;
                    break;
                }
            }
        }
        
    }
    
    return cleared;
}
- (id)cellDataOfRow:(NSInteger)row inSection:(NSInteger)section
{
    if(!_dataArray || [_dataArray count] == 0) return nil;
    
    NSString *path = [NSString stringWithFormat:@"%d.rows.%d.data", (int)section, (int)row];
    id data = [DDFunction valueOfData:_dataArray byPath:path];
    
    return data;
}
- (NSString*)cellNameOfRow:(NSInteger)row inSection:(NSInteger)section
{
    if(!_dataArray || [_dataArray count] == 0) return nil;
    
    NSString *path = [NSString stringWithFormat:@"%d.rows.%d.cell", (int)section, (int)row];
    NSString *name = [DDFunction valueOfData:_dataArray byPath:path];
    
    return name;
}
- (NSIndexPath*)indexPathForData:(id)data inSection:(NSInteger)section
{
    //找到section对应的rows
    NSString *secPath = [NSString stringWithFormat:@"%d", (int)section];
    NSMutableDictionary *secDic = [DDFunction valueOfData:_dataArray byPath:secPath];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return nil;
    
    NSMutableArray *rows = [secDic objectForKey:@"rows"];
    if(!rows || ![rows isKindOfClass:[NSMutableArray class]] || [rows count] == 0) return nil;
    
    
    NSIndexPath *findIndexPath = nil;
    for(int i=0; i<[rows count]; i++)
    {
        NSDictionary *rowdic = [rows objectAtIndex:i];
        id rowdata = [rowdic objectForKey:@"data"];
        if(rowdata && [rowdata isEqual:data])
        {
            //找到了和当前这个数据相同的位置
            findIndexPath = DDIndexPath(section, i);
            break;
        }
    }
    
    return findIndexPath;
}


- (void)tableTrigger:(TriggerType)triggerType
{
    //如果正在读取中，就不触发了，等待done的返回重置
    if(_loadingType != loadingNone) return;
    
    //改动触发点的状态
    if(triggerType == triggerLoadMore)
    {
        if(_loadMoreStyle == LoadMoreStyleNone) return;
        
        //设定读取状态
        _loadingType = loadingMore;
        
        //设定等待
        if(_moreFooterView)
        {
            [_moreFooterView startWaiting];
        }
    }
    else if(triggerType == triggerRefresh)
    {
        if(_refreshStyle == RefreshStyleNone) return;
        
        //设定读取状态
        _loadingType = loadingRefresh;
        
        //设定等待
        //如果有点击刷新被覆盖了，那么就启动点击刷新的等待效果
        if(_refreshCoverView && [_refreshCoverView superview])
        {
            [_refreshCoverView startWaiting];
        }
        
        //开启下拉刷新的等待效果
        if(_dragRefreshControll && [_dragRefreshControll superview])
        {
            if(!_dragRefreshControll.refreshing)
            {
                //从外面强制开启刷新效果
                [_dragRefreshControll beginRefreshing];
                
                //把tableview移动到最顶部，看到刷新滚动效果
                CGPoint cntOffset = _tableView.contentOffset;
                cntOffset.y = -_dragRefreshControll.frame.size.height;
                [_tableView setContentOffset:cntOffset animated:YES];
            }
        }
        
    }
    
    //返回给代理
    if(self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(DDTableViewDidTrigger:ontable:)])
    {
        [self.delegate DDTableViewDidTrigger:triggerType ontable:self];
    }
    
}


- (void)showTapRefreshCover
{
    //如果数据读取出现了异常，那么可以使用这个方法来附加一层点击刷新的覆盖层，返回事件和下拉刷新一样，同样会触发下拉刷新一次
    //因为是异常才会使用这个，并且覆盖以后只有点击刷新才能获取新数据，所以这里直接做一次数据清空工作
    [self clearDatas];
    [self refreshTable];
    
    //添加覆盖层
    if(_refreshCoverView && ![_refreshCoverView superview])
    {
        [self addSubview:_refreshCoverView];
    }
}


- (void)doneLoading
{
    //根据触发读取情况的类型，关闭等待状态
    if(_loadingType == loadingMore)
    {
        if(_moreFooterView)
        {
            [_moreFooterView stopWaiting];
        }
    }
    else if(_loadingType == loadingRefresh)
    {
        //关闭并移除点击刷新
        if(_refreshCoverView && [_refreshCoverView superview])
        {
            [_refreshCoverView stopWaiting];
            [_refreshCoverView removeFromSuperview];
        }
        
        //处理下拉刷新的恢复状态
        if(_dragRefreshControll && [_dragRefreshControll superview])
        {
            if(_dragRefreshControll.refreshing)
            {
                //设定刷新时间文字
                NSAttributedString *placeHolder = [DDTableView lastRefreshDateAttributed:_refreshDateParams isPlaceholder:NO];
                if(placeHolder)
                {
                    _dragRefreshControll.attributedTitle = placeHolder;
                }
                
                //关闭刷新效果
                [_dragRefreshControll endRefreshing];
                
                //刷新动作完成以后，把列表变回最顶层，不然效果不对劲
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    [NSThread sleepForTimeInterval:0.5];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        CGPoint cntOffset = _tableView.contentOffset;
                        cntOffset.y = 0;
                        [_tableView setContentOffset:cntOffset animated:YES];
                    });
                });
                
            }
        }
    }
    
    _loadingType = loadingNone;
}





#pragma mark -
#pragma mark 新数据封装方法，推荐使用此方法
//追加组装数据源
- (void)appendData:(id)data useCell:(NSString*)cellClassName toSection:(NSInteger)section
{
    if(!cellClassName || [cellClassName compare:@""] == NSOrderedSame) return;
    if(!data) return;
    
    NSMutableDictionary *secDic = [self dictionaryForSection:section];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return;
    
    NSMutableArray *rows = [secDic objectForKey:@"rows"];
    if(!rows || ![rows isKindOfClass:[NSMutableArray class]]) return;
    
    
    //创建这一行的rowData并添加
    NSMutableDictionary *rowdic = [[[NSMutableDictionary alloc] init] autorelease];
    
    [rowdic setObject:cellClassName forKey:@"cell"];
    [rowdic setObject:data forKey:@"data"];
    
    //把rowdic添加到rows的数组里边
    [rows addObject:rowdic];
    
}

- (void)appendDataArray:(NSArray*)dataArr useCell:(NSString*)cellClassName toSection:(NSInteger)section
{
    //极为简单的方法，仅能用于设定一个相同cell的普通列表，可以一次性追加组装一个数组
    if(!dataArr || [dataArr count] == 0) return;
    if(!cellClassName || [cellClassName compare:@""] == NSOrderedSame) return;
    
    for(id rowData in dataArr)
    {
        [self appendData:rowData useCell:cellClassName toSection:section];
    }
}


//插入数据源
- (void)insertData:(id)data useCell:(NSString*)cellClassName toIndexPath:(NSIndexPath*)indexPath
{
    if(!indexPath) return;
    if(!cellClassName || [cellClassName compare:@""] == NSOrderedSame) return;
    if(!data) return;
    
    
    NSMutableDictionary *secDic = [self dictionaryForSection:indexPath.section];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return;
    
    NSMutableArray *rows = [secDic objectForKey:@"rows"];
    if(!rows || ![rows isKindOfClass:[NSMutableArray class]]) return;
    
    
    //创建这一行的rowData并插入
    NSMutableDictionary *rowdic = [[[NSMutableDictionary alloc] init] autorelease];
    
    [rowdic setObject:cellClassName forKey:@"cell"];
    [rowdic setObject:data forKey:@"data"];
    
    //把rowdic插入到rows的数组里边
    [rows insertObject:rowdic atIndex:indexPath.row];
    
    
    //记录插入的数据源位置
    [_insertArray addObject:indexPath];
}

- (void)insertDataArray:(NSArray*)dataArr useCell:(NSString*)cellClassName belowIndexPath:(NSIndexPath*)indexPath
{
    //极为简单的方法，仅能用于插入相同cell的列表，可以一次性插入一个数组，
    //PS: 必须从indexPath所指定的行下面开始插入，因为一大堆数据插入的话，肯定是要放下面的，所以其他情况不必处理
    if(!dataArr || [dataArr count] == 0) return;
    if(!cellClassName || [cellClassName compare:@""] == NSOrderedSame) return;
    if(!indexPath) return;
    
    NSMutableDictionary *secDic = [self dictionaryForSection:indexPath.section];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return;
    
    NSMutableArray *rows = [secDic objectForKey:@"rows"];
    if(!rows || ![rows isKindOfClass:[NSMutableArray class]]) return;
    
    
    //插入数据
    NSInteger location = indexPath.row+1;
    if([rows count] == 0) //如果当前的section里边没有数据，就从0开始
    {
        location = 0;
    }
    
    //组装插入数据源字典
    //创建这一行的rowData并插入
    NSMutableArray *insertArray = [[[NSMutableArray alloc] init] autorelease];
    for(id rowData in dataArr)
    {
        NSMutableDictionary *rowdic = [[[NSMutableDictionary alloc] init] autorelease];
        [rowdic setObject:cellClassName forKey:@"cell"];
        [rowdic setObject:rowData forKey:@"data"];
        [insertArray addObject:rowdic];
    }
    
    NSInteger count = [insertArray count];
    [rows insertObjects:insertArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, count)]];
    
    //记录插入的数据源位置
    for(int i=0; i<count; i++)
    {
        NSUInteger ints[2] = {indexPath.section, location+i};
        NSIndexPath* newIP = [NSIndexPath indexPathWithIndexes:ints length:2];
        [_insertArray addObject:newIP];
    }
}



//删除数据源
- (void)deleteDataAtIndexPath:(NSIndexPath*)indexPath
{
    if(!indexPath) return;
    if(!_dataArray || [_dataArray count] == 0) return;

    NSString *secPath = [NSString stringWithFormat:@"%d", (int)indexPath.section];
    NSMutableDictionary *secDic = [DDFunction valueOfData:_dataArray byPath:secPath];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return;
    
    NSMutableArray *rows = [secDic objectForKey:@"rows"];
    if(!rows || ![rows isKindOfClass:[NSMutableArray class]]) return;
    if([rows count] == 0) return;
    if(indexPath.row >= [rows count]) return;
    
    
    //移除这一行数据
    [rows removeObjectAtIndex:indexPath.row];
    
    //记录插入的数据源位置
    [_deleteArray addObject:indexPath];
}

- (void)deleteDataArrayByIndexPaths:(NSArray*)indexPathArray
{
    //请注意 indexPathArray 不一定是连续的
    if(!indexPathArray || [indexPathArray count] == 0) return;
    if(!_dataArray || [_dataArray count] == 0) return;
    

    //移除数据源
    //区分section去处理，每个section批量移除数据
    for(int sec=0; sec<[_dataArray count]; sec++)
    {
        NSMutableDictionary *secDic = [_dataArray objectAtIndex:sec];
        NSMutableArray *rows = [secDic objectForKey:@"rows"];
        if(!rows || ![rows isKindOfClass:[NSMutableArray class]] || [rows count] == 0)
        {
            continue;
        }
        
        //有rows数据，找到这个section里边的indexpath对应的数据源，组成一个数组，用于移除
        NSMutableArray *rmvArr = [[[NSMutableArray alloc] init] autorelease];
        
        for(NSIndexPath *ip in indexPathArray)
        {
            if(ip.section == sec)
            {
                NSString *rowPath = [NSString stringWithFormat:@"%d", (int)ip.row];
                NSMutableDictionary *rowDic = [DDFunction valueOfData:rows byPath:rowPath];
                if(rowDic)
                {
                    //找到了需要移除的一个数据
                    [rmvArr addObject:rowDic];
                    
                    //位置信息添加到要移除的队列里边
                    [_deleteArray addObject:ip];
                }
            }
        }
        
        //移除数据
        [rows removeObjectsInArray:rmvArr];
    }

}

- (void)deleteDataArray:(NSArray*)dataArr inSection:(NSInteger)section
{
    if(!dataArr || [dataArr count] == 0) return;
    if(!_dataArray || [_dataArray count] == 0) return;
    
    //找到section对应的rows
    NSString *secPath = [NSString stringWithFormat:@"%d", (int)section];
    NSMutableDictionary *secDic = [DDFunction valueOfData:_dataArray byPath:secPath];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return;
    
    NSMutableArray *rows = [secDic objectForKey:@"rows"];
    if(!rows || ![rows isKindOfClass:[NSMutableArray class]] || [rows count] == 0) return;
    
    
    //找到要删除的数据对应的位置队列
    NSMutableArray *indexArray = [[[NSMutableArray alloc] init] autorelease];
    for(id data in dataArr)
    {        
        for(int i=0; i<[rows count]; i++)
        {
            NSDictionary *rowdic = [rows objectAtIndex:i];
            id rowdata = [rowdic objectForKey:@"data"];
            if(rowdata && [rowdata isEqual:data])
            {
                //找到了和当前这个数据相同的位置
                NSIndexPath *addIP = DDIndexPath(section, i);
                
                //排除重复的
                BOOL canAdd = YES;
                for(NSIndexPath *ip in indexArray)
                {
                    if([ip isEqual:addIP])
                    {
                        //已经在队列里了
                        canAdd = NO;
                        break;
                    }
                }
                
                if(canAdd)
                {
                    [indexArray addObject:DDIndexPath(section, i)];
                }
            }
        }

    }
    
    //删除所有的数据
    [self deleteDataArrayByIndexPaths:indexArray];
}






- (void)setSection:(NSInteger)section headerHeight:(float)hHeight footerHeight:(float)fHeight
{
    NSMutableDictionary *secDic = [self dictionaryForSection:section];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return;
    
    NSMutableDictionary *secParams = [secDic objectForKey:@"section_params"];
    if(!secParams || ![secParams isKindOfClass:[NSMutableDictionary class]]) return;
    
    
    //设定
    NSString *hHstring = [NSString stringWithFormat:@"%.f", hHeight];
    NSString *fHstring = [NSString stringWithFormat:@"%.f", fHeight];
    
    //有就覆盖，没有就新建存进去
    [secParams setObject:hHstring forKey:@"header_height"];
    [secParams setObject:fHstring forKey:@"footer_height"];
    
}
- (void)setSection:(NSInteger)section headerView:(UIView*)hView footerView:(UIView*)fView
{
    NSMutableDictionary *secDic = [self dictionaryForSection:section];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return;
    
    NSMutableDictionary *secParams = [secDic objectForKey:@"section_params"];
    if(!secParams || ![secParams isKindOfClass:[NSMutableDictionary class]]) return;
    
    
    //设定    
    //有就覆盖，没有就移除
    if(hView)
    {
        [secParams setObject:hView forKey:@"header_view"];
    }
    else
    {
        [secParams removeObjectForKey:@"header_view"];
    }
    
    if(fView)
    {
        [secParams setObject:fView forKey:@"footer_view"];
    }
    else
    {
        [secParams removeObjectForKey:@"footer_view"];
    }
        
}



- (void)clearParamsOfSection:(NSInteger)section
{
    //清空某个section的属性设置，但是里边的row数据不变
    if(!_dataArray || [_dataArray count] == 0) return;
    if(section >= [_dataArray count]) return;
    
    NSMutableDictionary *secDic = [self dictionaryForSection:section];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return;
    
    NSMutableDictionary *secParams = [secDic objectForKey:@"section_params"];
    if(!secParams || ![secParams isKindOfClass:[NSMutableDictionary class]]) return;
    
    //清空
    [secParams removeAllObjects];

}
- (void)clearDatasOfSection:(NSInteger)section
{
    //清空某个section里边所有的row数据，但是section的属性不变
    if(!_dataArray || [_dataArray count] == 0) return;
    if(section >= [_dataArray count]) return;
    
    NSMutableDictionary *secDic = [self dictionaryForSection:section];
    if(!secDic || ![secDic isKindOfClass:[NSMutableDictionary class]]) return;
    
    NSMutableArray *rows = [secDic objectForKey:@"rows"];
    if(!rows || ![rows isKindOfClass:[NSMutableArray class]]) return;
    
    //清空
    [rows removeAllObjects];
}

- (void)clearTableDatasAndParams
{
    //清空所有的数据
    if(!_dataArray || [_dataArray count] == 0) return;
    
    [_dataArray removeAllObjects];
}

- (void)clearDatas
{
    //清空所有section的Row的数据，但是section所设定的属性不变
    if(!_dataArray || [_dataArray count] == 0) return;
    
    //清空所有插入和删除队列
    [_insertArray removeAllObjects];
    [_deleteArray removeAllObjects];
    
    for(int i=0; i<[_dataArray count]; i++)
    {
        [self clearDatasOfSection:i];
    }
}




- (void)refreshTable
{
    //关闭loading等待状态及标志
    [self doneLoading];
    
    //使用前面封装好的数据源刷新页面，必须做的工作
    if(!_dataArray || [_dataArray count] == 0) return;
    
    //刷新列表
	[_tableView reloadData];
    
    
    //判断并添加加载更多和刷新部分的view
    if(_loadMoreStyle == LoadMoreStyleNone)
    {
        if(_moreFooterView && [_moreFooterView superview])
        {
            [_moreFooterView removeFromSuperview];
        }
    }
    else if(_loadMoreStyle == LoadMoreStyleAuto || _loadMoreStyle == LoadMoreStyleManual)
    {
        //拉长contentSize用来添加读取更多的view部分
        CGSize nSize = _tableView.contentSize;
        float moreY = nSize.height;
        
        //把table的高度变大一点，露出morefooterView
        nSize.height += more_footer_height;
        _tableView.contentSize = nSize;
        
        //添加morefooter
        if(_moreFooterView)
        {
            CGRect nmframe = _moreFooterView.frame;
            
            //如果此时table列表里边的真实列表高度
            CGSize  cntSize = _tableView.contentSize;
            CGRect  rect    = _tableView.frame;
            if(cntSize.height-more_footer_height < rect.size.height)
            {
                //还不够table一屏显示的，就把moreview改小点，设定为最后一行的cell的高度
                nmframe.size.height = [self lastCellHeight];
            }
            else
            {
                //超过了一屏，该成最大的1000
                nmframe.size.height = 1000;
            }
            
            nmframe.origin.y = moreY;
            _moreFooterView.frame = nmframe;
            
            if(![_moreFooterView superview])
            {
                [_tableView addSubview:_moreFooterView];
            }
        }
    }
    
    
    //添加刷新部分view
    if(_refreshStyle == RefreshStyleNone)
    {
        if(_dragRefreshControll && [_dragRefreshControll superview])
        {
            [_dragRefreshControll removeFromSuperview];
        }
    }
    else if(_refreshStyle == RefreshStyleDrag)
    {
        if(_dragRefreshControll)
        {
            if(![_dragRefreshControll superview])
            {                
                [_tableView addSubview:_dragRefreshControll];
            }
        }
    }
    
    
    //如果即不存在下拉刷新，也不存在上提加载，那么就判断是否需要添加logoview的默认效果
    //看是否需要添加_logoFooterView
    if(_loadMoreStyle == LoadMoreStyleNone)
    {
        if(_footerLogo && _logoFooterView)
        {
            CGRect lfframe = _logoFooterView.frame;
            CGSize  cntSize = _tableView.contentSize;
            CGRect  rect    = _tableView.frame;
            
            //只有此时table列表高度大于区域高度，才可以添加logo
            if(cntSize.height > rect.size.height)
            {
                lfframe.origin.y = cntSize.height;
                _logoFooterView.frame = lfframe;
                
                if(![_logoFooterView superview])
                {
                    [_tableView addSubview:_logoFooterView];
                }
            }
        }
        else
        {
            if(_logoFooterView && [_logoFooterView superview])
            {
                [_logoFooterView removeFromSuperview];
            }
        }
    }
    
    //看是否需要添加_logoHeaderView
    if(_refreshStyle == RefreshStyleNone)
    {
        if(_headerLogo && _logoHeaderView)
        {
            CGRect lhframe = _logoHeaderView.frame;
            lhframe.origin.y = -1000;
            _logoHeaderView.frame = lhframe;
            
            if(![_logoHeaderView superview])
            {
                [_tableView addSubview:_logoHeaderView];
            }
        }
        else
        {
            if(_logoHeaderView && [_logoHeaderView superview])
            {
                [_logoHeaderView removeFromSuperview];
            }
        }
    }
    
}

- (void)refreshTableWithAnimation:(UITableViewRowAnimation)animation
{
    [self doneLoading];
    
    if([_insertArray count] != 0)
    {
        [_tableView beginUpdates];
        [_tableView insertRowsAtIndexPaths:_insertArray withRowAnimation:animation];
        [_tableView endUpdates];
        
        [_insertArray removeAllObjects];
    }
    else if([_deleteArray count] != 0)
    {
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:_deleteArray withRowAnimation:animation];
        [_tableView endUpdates];
        
        [_deleteArray removeAllObjects];
    }
}






#pragma mark -
#pragma mark 一些类方法
+ (NSAttributedString*)lastRefreshDateAttributed:(NSDictionary*)params isPlaceholder:(BOOL)isPlaceholder
{
    if(!params || ![params isKindOfClass:[NSDictionary class]]) return nil;
    
    NSString *useString = nil;
    if(isPlaceholder)
    {
        //placeholder就只需要这个就够了
        useString = [params objectForKey:@"placeholder"];
    }
    else
    {
        //否则照当前时间做一个刷新时间
        NSString *head = [params objectForKey:@"head"];
        if(!head) head = @"";
        
        NSString *tail = [params objectForKey:@"tail"];
        if(!tail) tail = @"";
        
        NSString *format = [params objectForKey:@"format"];
        if(!format) format = @"yyyy-MM-dd HH:mm";
        
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:format];
        NSString *date = [dateFormatter stringFromDate:[NSDate date]];
        
        useString = [NSString stringWithFormat:@"%@%@%@", head, date, tail];
    }
    
    if(!useString || [useString compare:@""] == NSOrderedSame) return nil;
    
    
    //把useString做成带属性的
    NSMutableAttributedString *retString = [[[NSMutableAttributedString alloc] initWithString:useString] autorelease];  
    
    
    //6.0以上才可以支持改颜色和字体
    if([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) 
    {
        NSRange range = NSMakeRange(0, [retString length]);

        //改颜色,改字体
        UIColor *color = (UIColor*)[params objectForKey:@"color"];
        UIFont *font = (UIFont*)[params objectForKey:@"font"];
        if(color || font)
        {
            [retString beginEditing];
            
            if(color && [color isKindOfClass:[UIColor class]])
            {
                [retString addAttribute:NSForegroundColorAttributeName value:color range:range];
                
            }
            
            if(font && [font isKindOfClass:[UIFont class]])
            {
                [retString addAttribute:NSFontAttributeName value:font range:range];
            }
            
            [retString endEditing];
        }
    }
    
    return retString;
}


+ (NSIndexPath*)indexPathWithSection:(NSInteger)section row:(NSInteger)row
{
    NSUInteger ints[2] = {section, row};
	NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
    return indexPath;
}



@end
