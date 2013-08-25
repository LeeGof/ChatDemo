//
//  ChatViewController.m
//  ChatDemo
//
//  Created by ligf on 13-7-29.
//  Copyright (c) 2013年 yonyou. All rights reserved.
//

#import "ChatViewController.h"
#import <QuartzCore/QuartzCore.h>

#define TOOLBARTAG		200
#define TABLEVIEWTAG	300

#define BEGIN_FLAG @"[/"  // 这两个标签主要用于表情
#define END_FLAG @"]"

@interface ChatViewController ()

@end

@implementation ChatViewController
@synthesize viewFile = _viewFile;
@synthesize chatTableView = _chatTableView;
@synthesize messageTextField = _messageTextField;
@synthesize chatArray = _chatArray;
@synthesize messageString = _messageString;
@synthesize lastTime = _lastTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.chatArray = [[NSMutableArray alloc] init];
    isMoreOperateHidden = YES;
    isResponseKeyboard = YES;
    isKeyboardShow = NO;
    
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 键盘高度变化通知，ios5.0新增的
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:YES];
    
	self.title = @"群聊(2人)";
	[self getDataFromLocal];
	
	[self.chatTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_viewFile release];
	[_messageTextField release];
	[_chatTableView release];
    [_chatArray release];
    [_messageString release];
    [_lastTime release];
    
    [super dealloc];
}

#pragma mark - 自定义方法

- (void)getDataFromLocal
{
    
}

- (IBAction)btnClicked:(id)sender
{
    UIButton *btnSender = (UIButton *)sender;
    switch (btnSender.tag)
    {
        case 1000:  // 图片
        {
            if (isMoreOperateHidden || isKeyboardShow)
            {
                [self showMoreOperateView];
            }
            else
            {
                [self hiddenMoreOperateView];
            }
            break;
        }
        case 1001:  // 发送
        {
            NSString *messageStr = self.messageTextField.text;
            self.messageString = [NSMutableString stringWithString:messageStr];
            
            if (messageStr == nil || [messageStr length] == 0)
            {
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送失败！" message:@"发送的内容不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                [alert release];
                 */
                UIImage *img = [UIImage imageNamed:@"test.png"];
                [self sendImageMassage:img];
            }
            else
            {
                [self sendTextMassage:messageStr];
            }
            self.messageTextField.text = @"";
            self.messageString = [NSMutableString stringWithString:@""];
            [_messageTextField resignFirstResponder];
            _viewFile.hidden = YES;
            break;
        }
        default:
            break;
    }
}

// 发送文本消息
- (void)sendTextMassage:(NSString *)strContent
{
    NSDate *nowTime = [NSDate date];
    
    if ([self.chatArray lastObject] == nil)
    {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
	// 发送后生成泡泡显示出来
	NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:self.lastTime];
	if (timeInterval > 5)
    {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
    UIView *chatView = [self bubbleTextView:[NSString stringWithFormat:@"我:%@", strContent]
								   from:YES];
	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:strContent, @"text",@"txt",@"type", @"self", @"speaker", chatView, @"view", nil]];
    UIView *chatOther = [self bubbleTextView:[NSString stringWithFormat:@"其他:%@", strContent]
                                    from:NO];
    [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:strContent, @"text",@"txt",@"type", @"other", @"speaker", chatOther, @"view", nil]];
    
	
	[self.chatTableView reloadData];
	[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
							  atScrollPosition: UITableViewScrollPositionBottom
									  animated:YES];
}

// 发送图片消息
- (void)sendImageMassage:(UIImage *)image
{
    NSDate *nowTime = [NSDate date];
    
    if ([self.chatArray lastObject] == nil)
    {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
	// 发送后生成泡泡显示出来
	NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:self.lastTime];
	if (timeInterval > 5)
    {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
    UIView *chatView = [self bubbleImageView:image from:YES];
	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"text",@"image",@"type", @"self", @"speaker", chatView, @"view", nil]];
    UIView *chatOther = [self bubbleImageView:image
                                        from:NO];
    [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"text",@"txt",@"type", @"other", @"speaker", chatOther, @"view", nil]];
    
	
	[self.chatTableView reloadData];
	[self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
							  atScrollPosition: UITableViewScrollPositionBottom
									  animated:YES];
}

// 显示更多操作View
- (void)showMoreOperateView
{
    [self autoMovekeyBoard:216.0f];
    
    _viewFile.hidden = NO;
    isMoreOperateHidden = NO;
    UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
    [_viewFile setFrame:CGRectMake(0, tableView.frame.origin.y + tableView.frame.size.height + 44, 320, 216)];
    
    if (isKeyboardShow)
    {
        isResponseKeyboard = NO;
        [_messageTextField resignFirstResponder];
        isResponseKeyboard = YES;
    }
}

// 隐藏更多操作View
- (void)hiddenMoreOperateView
{
    [self autoMovekeyBoard:0];
    
    _viewFile.hidden = YES;
    isMoreOperateHidden = YES;
    [_messageTextField resignFirstResponder];
    isResponseKeyboard = YES;
}

#pragma mark - 生成泡泡View

- (UIView *)bubbleImageView:(UIImage *)image from:(BOOL)fromSelf
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(0, 0, 40, 60)];
    imageView.backgroundColor = [UIColor clearColor];
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubble_self":@"bubble_other" ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    
    if(fromSelf)
    {
        [headImageView setImage:[UIImage imageNamed:@"head_self.png"]];
        imageView.frame= CGRectMake(9.0f, 25.0f, imageView.frame.size.width, imageView.frame.size.height);
        bubbleImageView.frame = CGRectMake(0.0f, 14.0f, imageView.frame.size.width + 24.0f, imageView.frame.size.height + 24.0f );
        cellView.frame = CGRectMake(265.0f - bubbleImageView.frame.size.width, 0.0f,bubbleImageView.frame.size.width + 50.0f, bubbleImageView.frame.size.height + 30.0f);
        headImageView.frame = CGRectMake(bubbleImageView.frame.size.width, cellView.frame.size.height - 50.0f, 50.0f, 50.0f);
    }
	else
    {
        [headImageView setImage:[UIImage imageNamed:@"head_other.png"]];
        imageView.frame = CGRectMake(65.0f, 25.0f, imageView.frame.size.width, imageView.frame.size.height);
        bubbleImageView.frame = CGRectMake(50.0f, 14.0f, imageView.frame.size.width + 24.0f, imageView.frame.size.height + 24.0f);
		cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width + 30.0f,bubbleImageView.frame.size.height + 30.0f);
        headImageView.frame = CGRectMake(0.0f, cellView.frame.size.height - 50.0f, 50.0f, 50.0f);
    }
    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:headImageView];
    [cellView addSubview:imageView];
    [bubbleImageView release];
    [imageView release];
    [headImageView release];
	return [cellView autorelease];
}

/*
 生成文本类型的泡泡
 @param text:文本内容
 @param fromSelf:是否自己发送的消息(是:YES;否:NO)
 */
- (UIView *)bubbleTextView:(NSString *)text from:(BOOL)fromSelf
{
    UIView *returnView =  [self assembleMessageAtIndex:text from:fromSelf];
    returnView.backgroundColor = [UIColor clearColor];
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubble_self":@"bubble_other" ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    
    if(fromSelf)
    {
        [headImageView setImage:[UIImage imageNamed:@"head_self.png"]];
        returnView.frame= CGRectMake(9.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleImageView.frame = CGRectMake(0.0f, 14.0f, returnView.frame.size.width + 24.0f, returnView.frame.size.height + 24.0f );
        cellView.frame = CGRectMake(265.0f - bubbleImageView.frame.size.width, 0.0f,bubbleImageView.frame.size.width + 50.0f, bubbleImageView.frame.size.height + 30.0f);
        headImageView.frame = CGRectMake(bubbleImageView.frame.size.width, cellView.frame.size.height - 50.0f, 50.0f, 50.0f);
    }
	else
    {
        [headImageView setImage:[UIImage imageNamed:@"head_other.png"]];
        returnView.frame = CGRectMake(65.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleImageView.frame = CGRectMake(50.0f, 14.0f, returnView.frame.size.width + 24.0f, returnView.frame.size.height + 24.0f);
		cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width + 30.0f,bubbleImageView.frame.size.height + 30.0f);
        headImageView.frame = CGRectMake(0.0f, cellView.frame.size.height - 50.0f, 50.0f, 50.0f);
    }
    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:headImageView];
    [cellView addSubview:returnView];
    [bubbleImageView release];
    [returnView release];
    [headImageView release];
	return [cellView autorelease];
}

#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH 150
- (UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:message];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont *fon = [UIFont systemFontOfSize:13.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data)
    {
        for (int i = 0;i < [data count];i++)
        {
            NSString *str = [data objectAtIndex:i];
            
            for (int j = 0; j < [str length]; j++)
            {
                NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                if (upX >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = 150;
                    Y =upY;
                }
                CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(150, 40)];
                UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                la.font = fon;
                la.text = temp;
                la.backgroundColor = [UIColor clearColor];
                [returnView addSubview:la];
                [la release];
                upX = upX+size.width;
                if (X < 150)
                {
                    X = upX;
                }
            }
        }
    }
    returnView.frame = CGRectMake(15.0f,1.0f, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
//    NSLog(@"%.1f %.1f", X, Y);
    return returnView;
}

#pragma mark - Table View DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chatArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]])
    {
		return 30;
	}
    else
    {
		UIView *chatView = [[self.chatArray objectAtIndex:[indexPath row]] objectForKey:@"view"];
		return chatView.frame.size.height + 10;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
    {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
	}
	
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]])
    {
		NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yy-MM-dd HH:mm"];
		NSMutableString *timeString = [NSMutableString stringWithFormat:@"%@",[formatter stringFromDate:[self.chatArray objectAtIndex:[indexPath row]]]];
		[formatter release];
        
        UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
        lblTime.text = timeString;
        lblTime.backgroundColor = [UIColor clearColor];
        lblTime.textAlignment = NSTextAlignmentCenter;
        lblTime.textColor = [UIColor grayColor];
        lblTime.highlightedTextColor = [UIColor whiteColor];
        lblTime.font = [UIFont systemFontOfSize:13];;
        [cell addSubview:lblTime];
        [lblTime release];
	}
    else
    {
		NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
		UIView *chatView = [chatInfo objectForKey:@"view"];
		[cell.contentView addSubview:chatView];
	}
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.messageTextField resignFirstResponder];
    
    if (![[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]])
    {
        NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
		NSString *strType = [chatInfo objectForKey:@"type"];
        
        if ([strType isEqualToString:@"image"])
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"IMAGE" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil] autorelease];
            [alert show];
        }
    }
}

#pragma mark - TextField Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(textField == self.messageTextField)
	{
        //[self moveViewUp];
	}
}

- (void)autoMovekeyBoard:(float)h
{
    UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
	toolbar.frame = CGRectMake(0.0f, (float)(480.0-h-108.0), 320.0f, 44.0f);
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f,(float)(480.0-h-108.0));
}

#pragma mark - Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification
{
    isKeyboardShow = YES;
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if (isResponseKeyboard)
    {
        [self autoMovekeyBoard:keyboardRect.size.height];
    }    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    isKeyboardShow = NO;
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if (isResponseKeyboard)
    {
        [self autoMovekeyBoard:0];
    }
}

@end
