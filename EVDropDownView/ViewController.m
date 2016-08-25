//
//  ViewController.m
//  EVDropDownView
//
//  Created by iwevon on 16/8/16.
//  Copyright © 2016年 iwevon. All rights reserved.
//

#import "ViewController.h"
#import "EVDropDownView.h"

@interface ViewController () <EVDropDownViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet EVDropDownView *dropDownView1;
@property (weak, nonatomic) IBOutlet EVDropDownView *dropDownView2;

@property (weak, nonatomic) EVDropDownView *dropDownView3;

@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation ViewController


#pragma mark - Lazy load

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@"1kV",
                        @"2kV",
                        @"3kV",
                        @"4kV",
                        @"5kV",
                        @"6kV"];
    }
    return _titleArray;
}

- (EVDropDownView *)dropDownView3 {
    if (!_dropDownView3) {
        EVDropDownView *dropDownView = [EVDropDownView dropDownViewWithFrame:CGRectMake(20, 100, 150, 40) dataArray:self.titleArray title:@"3kV" existence:YES];
        [self.view addSubview:dropDownView];  //** width 默认要多加50，给输入框留下空间
        dropDownView.delegate = self;
        self.dropDownView1.keyboardType = UIKeyboardTypeNumberPad;
        _dropDownView3 = dropDownView;
    }
    return _dropDownView3;
}


#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //XIB
    [self.dropDownView1 setDataArray:self.titleArray title:@"5kV" existence:NO];
    [self.dropDownView1 setButtonWidth:70.0f];
    self.dropDownView1.delegate = self;
    
    [self.dropDownView2 setDataArray:self.titleArray title:@"8kV" existence:YES];
    self.dropDownView2.delegate = self;
    self.dropDownView2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    //Code
    [self dropDownView3];
}


#pragma mark - EVDropDownViewDelegate

- (void)dropDwonListWillAppear:(EVDropDownView *)dropDownView {
    
    if (dropDownView == self.dropDownView1) {
        [self.dropDownView2 resignFirstResponder];
        [self.dropDownView3 resignFirstResponder];
    } else if (dropDownView == self.dropDownView2) {
        [self.dropDownView1 resignFirstResponder];
        [self.dropDownView3 resignFirstResponder];
    } else if (dropDownView == self.dropDownView3) {
        [self.dropDownView1 resignFirstResponder];
        [self.dropDownView2 resignFirstResponder];
    }
}

- (void)dropDownView:(EVDropDownView *)dropDownView didSelectTitle:(NSString *)title {
    NSLog(@"%@", title);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
