//
//  ChatViewController.h
//  ChatDemo
//
//  Created by ligf on 13-7-29.
//  Copyright (c) 2013年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UIView                     *_viewFile;
    UITableView                *_chatTableView;
	UITextField                *_messageTextField;
    NSMutableArray		       *_chatArray;
    NSMutableString            *_messageString;
    NSDate                     *_lastTime;
    
    BOOL                       isMoreOperateHidden;  // 更多操作是否显示
    BOOL                       isResponseKeyboard;  // 是否响应键盘事件
    BOOL                       isKeyboardShow;  // 键盘是否显示
}

@property (nonatomic, retain) IBOutlet UIView *viewFile;
@property (nonatomic, retain) IBOutlet UITableView *chatTableView;
@property (nonatomic, retain) IBOutlet UITextField *messageTextField;
@property (nonatomic, retain) NSMutableArray *chatArray;
@property (nonatomic, retain) NSMutableString        *messageString;
@property (nonatomic, retain) NSDate *lastTime;

- (IBAction)btnClicked:(id)sender;

@end
