//
//  EVDropDownView.h
//  EVDropDownView
//
//  Created by iwevon on 16/8/16.
//  Copyright © 2016年 iwevon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EVDropDownView;

@protocol EVDropDownViewDelegate <NSObject>

@optional
- (void)dropDwonListWillAppear:(EVDropDownView *)dropDownView;
- (void)dropDownView:(EVDropDownView *)dropDownView didSelectTitle:(NSString *)title;

@end

@interface EVDropDownView : UIView

#pragma mark - High frequency of use
/**
 *  创建下拉列表视图 (并设置数据)
 *
 *  @param frame           frame
 *  @param dataArray       数据源
 *  @param title           text
 *  @param existence       是否需要输入框   YES:宽度增加50  NO:不需要增加宽度
 *
 *  @return instancetype
 */
+ (instancetype)dropDownViewWithFrame:(CGRect)frame
                            dataArray:(NSArray *)dataArray
                                title:(NSString *)title
                            existence:(BOOL)existence;

/**
 *  设置数据
 *
 *  @param dataArray       数据源
 *  @param title           text
 *  @param existence       是否需要输入框   YES:宽度增加50  NO:不需要增加宽度
 *
 *  @return instancetype
 */
- (void)setDataArray:(NSArray *)dataArray
               title:(NSString *)title
           existence:(BOOL)existence;



/**
 *  隐藏下拉列表
 */
- (void)hiddenDropDwonList;

/** 设置文字宽度 */
- (void)setTitleFontOfSize:(CGFloat)fontSize;

@property (nonatomic, weak) id<EVDropDownViewDelegate> delegate;
/** 按钮宽度 */
@property (nonatomic, assign) CGFloat buttonWidth;
/** 显示文字 */
@property (nonatomic, assign) NSString *title;


#pragma mark - Low frequency of use

/** 按钮 */
@property (nonatomic, strong) UIButton *button;
/** 输入框 */
@property (nonatomic, strong) UITextField *inputField;
/** 输入框输入样式 */
@property(nonatomic, assign) UIKeyboardType keyboardType;

@end
