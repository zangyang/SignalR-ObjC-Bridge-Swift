//
//  ViewController.m
//  SignalR-ObjC-Bridge-Swift
//
//  Created by yangz on 2020/5/27.
//  Copyright © 2020 CoderZY. All rights reserved.
//

#import "ViewController.h"
#import "SignalRObjCBridgeSwift-Swift.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    SignalRSwift *signalrSwift;
    NSMutableArray *dataArray;
}
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet UITextField *msgText;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataArray=[NSMutableArray array];
    
    _chatTableView.delegate=self;
    _chatTableView.dataSource=self;
    
    //打开signalR
    signalrSwift=[[SignalRSwift alloc]init];
    NSString *signalRString =@"http://localhost/signalr";
    NSDictionary *headers = @{@"token" : @"xxxxxxx"};
    NSString *name =@"test";
    __weak __typeof(&*self)weakSelf = self;
    [signalrSwift signalROpenWithUrl:signalRString headers:headers hubName:name blockfunc:^(NSString * _Nonnull message) {
        [weakSelf receivePushMessage:message];
    }];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [signalrSwift signalRClose];
}
- (IBAction)sendButtonClick:(id)sender {
    if(![_msgText.text isEqualToString:@""]){
        [signalrSwift sendMessageWithMessage:_msgText.text];
    }
}
#pragma mark UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text=dataArray[indexPath.row];
    return cell;
}
#pragma mark - Singlr获取数据
- (void)receivePushMessage:(NSString *)pushMessage {
    if(!_sendButton.isEnabled){
        _sendButton.enabled=YES;
        _msgText.enabled=YES;
    }
    _msgText.text=@"";
    [dataArray addObject:pushMessage];
    [_chatTableView reloadData];
}

@end
