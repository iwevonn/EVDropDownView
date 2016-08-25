//
//  EVDropDownView.m
//  EVDropDownView
//
//  Created by iwevon on 16/8/16.
//  Copyright © 2016年 iwevon. All rights reserved.
//

#import "EVDropDownView.h"

@interface EVDropDwonTableView : UITableView

@end

@implementation EVDropDwonTableView

/**************************************************
 http://www.jianshu.com/p/420f9dc78c04
 question:
 当tableView被 父控件(scrollView或其子类) 所包含时,当tableView滑动到顶部时,
 再次下拉滑动tableView时,scrollView会其联动
 --------------------------------------------------
 answer:
 通过相应者链,获取父控件(scrollView或其子类)对象,修改其'scrollEnabled'属性,解除联动
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    
    //使用相应者链解决
    UIResponder *responder = [self nextResponder];
    UIScrollView *scrollView = nil;
    //responder==nil:说明tableView未被scrollView包含 scrollView!=nil:说明按照条件获取到父控件(scrollView或其子类)对象
    while (responder && scrollView == nil)
    {
        //如果是父控件(scrollView或其子类)就返回,说明tableview被scrollView包含关系
        if ([responder isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)responder;
        } else {
            //根据响应者链去获取下一个相应者对象
            responder = [responder nextResponder];
        }
    }
    
    //scrollView为空时不会发送消息
    if (view) { //当view!=nil时,(view类型为UITableViewCellContentView)需要关闭响应者链中scrollView滑动手势
        scrollView.scrollEnabled = NO;
    } else { //当view==nil时,说明手势操作不是tableView发出的
        scrollView.scrollEnabled = YES;
    }
    
    return view;
}

@end


#define ImageFromName(name) ([[NSBundle mainBundle] pathForResource:name ofType:@"png"])?\
                                [UIImage imageWithData:[NSData dataWithContentsOfFile:\
                                [[NSBundle mainBundle] pathForResource:name ofType:@"png"]]]:\
                                [UIImage imageNamed:name]

NSString * const kDropDwonViewIndentifierCell       = @"indentifierCell";
NSString * const kDropDwonViewOtherString           = @"其它";
CGFloat    const kDropDwonViewDefaultTitleWidth     = 12.0f; //默认文字宽度
CGFloat    const kDropDwonViewMinButtonWidth        = 90.0f; //按钮默认的宽度
CGFloat    const kDropDwonViewMinButtonScale        = 0.4f;  //按钮与父控件的比例
CGFloat    const kDropDwonViewMinButtonTrailing     = 50.0f; //按钮到父控件最小边距
CGFloat    const kDropDwonViewDefaultMargin         = 5.0f;  //按钮与输入框的间距
CGFloat    const kDropDwonViewAnimateWithDuration   = 0.25f; //动画时间



@interface EVDropDownView () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

/** 下拉列表 */
@property (nonatomic, strong) EVDropDwonTableView *tableView;
/** 数据源 */
@property (nonatomic, strong) NSArray *dataArray;
/** 是否存在输入框 */
@property (nonatomic, assign, getter=isExistence) BOOL existence;
/** 初始化标记 */
@property (nonatomic, assign, getter=isMark) BOOL mark;

@end

@implementation EVDropDownView

#pragma mark - Get

- (UIButton *)button {
    if (!_button) {
        _button = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:btn];
            btn.frame = CGRectMake(0, 0, 0, self.frame.size.height);
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(dropDownListWithButton:) forControlEvents:UIControlEventTouchUpInside];
            [btn setBackgroundImage:ImageFromName(@"btn_device_model2.png") forState:UIControlStateNormal];
            [btn setBackgroundImage:ImageFromName(@"btn_device_model2.png") forState:UIControlStateDisabled];
            [btn setTitle:@"请选择" forState:UIControlStateNormal];
            btn;
        });
    }
    return _button;
}

- (EVDropDwonTableView *)tableView {
    if (!_tableView) {
        _tableView = ({
            
            EVDropDwonTableView *tableView = [[EVDropDwonTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            if ([self.superview isKindOfClass:UIView.class]) {
                [self.superview addSubview:tableView];
            }
            tableView.showsVerticalScrollIndicator = NO;
            UIColor *color = [UIColor grayColor];
            [tableView.layer setBorderColor:color.CGColor];
            [tableView.layer setBorderWidth:1];
            tableView.separatorColor = [color colorWithAlphaComponent:0.5];
            [tableView setSeparatorInset:UIEdgeInsetsZero];
            [tableView setLayoutMargins:UIEdgeInsetsZero];
            tableView.rowHeight = self.frame.size.height;
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView;
        });
    }
    return _tableView;
}

- (UITextField *)inputField {
    if (!_inputField) {
        _inputField = ({
            CGFloat textFieldH = self.frame.size.height;
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, 0, textFieldH)];
            [self addSubview:textField];
            textField.textAlignment = NSTextAlignmentCenter;
            UIImage *backgroundImage = ImageFromName(@"Runenvironment_normal");
            [textField setBackground:backgroundImage];
            textField.delegate = self;
            textField;
        });
    }
    return _inputField;
}

#pragma mark - public
//code instance
+ (instancetype)dropDownViewWithFrame:(CGRect)frame
                            dataArray:(NSArray *)dataArray
                                title:(NSString *)title
                            existence:(BOOL)existence {
    
    EVDropDownView *dropDownView = [[self alloc] initWithFrame:frame];
    [dropDownView setDataArray:dataArray title:title existence:existence];
    
    return dropDownView;
}

//nib or code

- (void)setDataArray:(NSArray *)dataArray
               title:(NSString *)title
           existence:(BOOL)existence {
    
    self.backgroundColor = [UIColor clearColor];
    //setup data
    NSMutableArray *tempArrayM = [NSMutableArray arrayWithArray:dataArray];
    //当有文字和设置的时候 下拉列表增加 kDropDwonViewOtherString 项
    existence ? [tempArrayM addObject:kDropDwonViewOtherString] : nil;
    self.dataArray = tempArrayM;
    self.existence = existence;
    
    //setup UI
    self.clipsToBounds = YES;
    [self setButtonWidth:kDropDwonViewMinButtonWidth];
    [self setTitleFontOfSize:kDropDwonViewDefaultTitleWidth];
    
    if (title.length && [dataArray containsObject:title]) {
        [self setTitle:title];
        self.inputField.text = nil;
    } else if (title.length) {
        [self setTitle:kDropDwonViewOtherString];
        self.inputField.text = title;
        self.mark = YES; //初始化标记为YES
        [self inputFieldWithHiddenOperat:NO];
        self.mark = NO;
    }
}

- (void)setButtonWidth:(CGFloat)buttonWidth {
    if (_buttonWidth == buttonWidth) return;
    _buttonWidth = buttonWidth;
    
    CGFloat btnW = buttonWidth;
    CGRect btnF = self.button.frame;
    btnF.size.width = btnW;
    self.button.frame = btnF;
    
    CGFloat textFieldW = (self.frame.size.width-kDropDwonViewDefaultMargin)*(1-kDropDwonViewMinButtonScale);
    CGRect textFieldF = self.inputField.frame;
    textFieldF.size.width = textFieldW;
    self.inputField.frame = textFieldF;
}

- (void)setTitle:(NSString *)title {
    if (_title == title) return;

    _title = title;
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (void)setTitleFontOfSize:(CGFloat)fontSize {
    self.button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    if (_inputField) {
        self.inputField.font = [UIFont systemFontOfSize:fontSize];
    }
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    _keyboardType = keyboardType;
    self.inputField.keyboardType = keyboardType;
}

- (void)hiddenDropDwonList {
    //1.取消输入框第一响应
    if ([self.inputField isFirstResponder]) {
        [self.inputField resignFirstResponder];
    }
    //2.隐藏下拉列表
    if (self.button.isSelected) {
        [self dropDownListWithButton:self.button];
    }
    //3.转换文字
    if (self.inputField.text.length) {
        [self setTitle:self.inputField.text];
        self.inputField.text = nil;
    }
    //4.隐藏输入框
    [self inputFieldWithHiddenOperat:YES];
    
    //输入框中内容回调
    if ([self.delegate respondsToSelector:@selector(dropDownView:didSelectTitle:)]) {
        [self.delegate dropDownView:self didSelectTitle:self.button.currentTitle];
    }
}


#pragma mark - change UI

- (void)dropDownListWithButton:(UIButton *)button {
    
    CGFloat tableViewX = CGRectGetMinX(self.frame);
    CGFloat tableViewY = CGRectGetMaxY(self.frame)+1;
    CGFloat tableViewW = CGRectGetWidth(button.frame);
    CGFloat tableViewH = 0;
    
    CGRect tempFrame = CGRectMake(tableViewX, tableViewY, tableViewW, tableViewH);
    self.tableView.frame = tempFrame;
    
    if (button.isSelected) {
        
        [button setBackgroundImage:ImageFromName(@"btn_device_model2.png") forState:UIControlStateNormal];
        [button setBackgroundImage:ImageFromName(@"btn_device_model2.png") forState:UIControlStateDisabled];
        tempFrame.size.height = 0;
    } else {
        
        [button setBackgroundImage:ImageFromName(@"btn_device_model.png") forState:UIControlStateNormal];
        [button setBackgroundImage:ImageFromName(@"btn_device_model.png") forState:UIControlStateDisabled];
        CGFloat tableViewH = self.dataArray.count * (self.tableView.rowHeight?:self.frame.size.height);
        CGFloat maxH = self.tableView.superview.frame.size.height - self.tableView.frame.origin.y;
        tempFrame.size.height  = (tableViewH > maxH) ? maxH : tableViewH;
        
        //展开下拉列表
        if ([self.delegate respondsToSelector:@selector(dropDwonListWillAppear:)]) {
            [self.delegate dropDwonListWillAppear:self];
        }
    }

    button.enabled = NO;
    [UIView animateWithDuration:kDropDwonViewAnimateWithDuration animations:^{
        self.tableView.frame = tempFrame;
    } completion:^(BOOL finished){
        button.enabled = YES;
        button.selected = !button.isSelected;
    }];
}

/**
 *  自动/手动 管理输入框显示
 *
 *  @param state YES:manage  NO:not manage
 */
- (void)inputFieldWithHiddenOperat:(BOOL)state {
    
    CGRect tempTextFieldFrame = self.inputField.frame;
    CGRect tempButtonFrame = self.button.frame;
    CGFloat width = self.frame.size.width;
    
    BOOL isResult = tempTextFieldFrame.origin.x == width;
    if (state && isResult) {
        //oneself manage
        return;
    }
    
    //设置button和inputField的frame
    if (isResult) {
        tempTextFieldFrame.origin.x = width - tempTextFieldFrame.size.width;
        tempButtonFrame.size.width = (width-kDropDwonViewDefaultMargin)*kDropDwonViewMinButtonScale;
    } else {
        tempTextFieldFrame.origin.x = width;
        tempButtonFrame.size.width = (self.buttonWidth==kDropDwonViewMinButtonWidth)?width-kDropDwonViewMinButtonTrailing:self.buttonWidth;
    }
    
    
    if (self.isMark) {
        self.mark = NO;
        self.inputField.frame = tempTextFieldFrame;
        self.button.frame = tempButtonFrame;
    }
    else {
        self.inputField.enabled = NO;
        self.button.enabled = NO;
        [UIView animateWithDuration:kDropDwonViewAnimateWithDuration delay:0 usingSpringWithDamping:kDropDwonViewAnimateWithDuration*2 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.inputField.frame = tempTextFieldFrame;
            self.button.frame = tempButtonFrame;
        } completion:^(BOOL finished){
            self.inputField.enabled = YES;
            self.button.enabled = YES;
            if (isResult) {
                [self.inputField becomeFirstResponder];
            }
        }];
    }
}


#pragma mark - Delegate
#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDropDwonViewIndentifierCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDropDwonViewIndentifierCell];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:self.button.titleLabel.font.pointSize-1];
        cell.textLabel.numberOfLines = 0;
    }
    NSString *tite = self.dataArray[indexPath.row];
    cell.textLabel.textColor = [tite isEqualToString:kDropDwonViewOtherString] ? [UIColor redColor] : [UIColor blackColor];
    cell.textLabel.text = tite;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *title = cell.textLabel.text;
    [self.button sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self setTitle:title];
    //input manage
    //点击cell,隐藏下拉列表
    if (self.existence && (indexPath.row == self.dataArray.count-1)) {
        
        [self inputFieldWithHiddenOperat:NO];
        self.inputField.text = [title isEqualToString:kDropDwonViewOtherString]?nil:title;
        
    } else {
        
        [self inputFieldWithHiddenOperat:YES];
        self.inputField.text = nil;
    }
    
    //当选中添加的cell,不需要回传
    if ([kDropDwonViewOtherString isEqualToString:title]) return;
    if ([self.delegate respondsToSelector:@selector(dropDownView:didSelectTitle:)]) {
        [self.delegate dropDownView:self didSelectTitle:title];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (!self.button.isSelected) {
        if (textField.text.length) {
            [self setTitle:textField.text];
            self.inputField.text = nil;
        }
        //输入框中内容填写完毕的时候回调
        if ([self.delegate respondsToSelector:@selector(dropDownView:didSelectTitle:)]) {
            [self.delegate dropDownView:self didSelectTitle:self.button.currentTitle];
        }
        
        [self inputFieldWithHiddenOperat:NO];
    }
    return YES;
}


#pragma mark - resignFirstResponder

- (BOOL)resignFirstResponder {
    
    [self hiddenDropDwonList];
    return YES;
}

#pragma mark - dealloc

- (void)dealloc {
    if (_tableView) {
        self.tableView.dataSource =  nil;
        self.tableView.delegate = nil;
        [self.tableView removeFromSuperview];
    }
    if (_inputField) {
        self.inputField.delegate = nil;
    }
}
@end
