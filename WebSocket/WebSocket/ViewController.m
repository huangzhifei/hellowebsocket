//
//  ViewController.m
//  WebSocket
//
//  Created by eric on 2018/3/19.
//  Copyright © 2018年 huangzhifei. All rights reserved.
//

#import "ViewController.h"
#import <SRWebSocket.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, SRWebSocketDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datasArray;
@property (nonatomic, strong) SRWebSocket *sRWebSocket;
@property (nonatomic, strong) NSTimer *heartTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.sRWebSocket open];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.sRWebSocket close];
}

- (void)setupUI {
    [self.view addSubview:self.tableView];
    
    self.datasArray = [NSMutableArray array];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(rightClicked:)];
}

#pragma mark - setter & getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    return _tableView;
}

- (SRWebSocket *)sRWebSocket {
    if (!_sRWebSocket) {
        NSURLRequest *urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://localhost:3000"]];
        _sRWebSocket = [[SRWebSocket alloc] initWithURLRequest:urlReq];
        _sRWebSocket.delegate = self;
    }
    return _sRWebSocket;
}

#pragma mark - event

- (void)rightClicked:(UIButton *)sender {
    [self.sRWebSocket send:@"hello world"];
    static int scount = 1;
    NSString *msg = [NSString stringWithFormat:@"发送消息： hello world %d", scount++];
    [self.datasArray insertObject:msg atIndex:0];
    [self.tableView reloadData];
}

#pragma mark - private method

- (void)startHeartTimer {
    if (self.heartTimer == nil) {
        self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                           target:self
                                                         selector:@selector(sendHeart)
                                                         userInfo:nil
                                                          repeats:YES];
    }
    [self sendHeart];
}

- (void)invalidateHeartTimer {
    [self.heartTimer invalidate];
    self.heartTimer = nil;
}

// 心跳
- (void)sendHeart {
    [self.sRWebSocket sendPing:[NSData dataWithBytes:@"heart" length:6]];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    static int rcount = 1;
    NSString *msg = [NSString stringWithFormat:@"收到推送消息： %@ %d", message, rcount++];
    [self.datasArray insertObject:msg atIndex:0];
    [self.tableView reloadData];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    [self startHeartTimer];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self invalidateHeartTimer];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self invalidateHeartTimer];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.textLabel.text = self.datasArray[indexPath.row];
    return cell;
}

#pragma mark - dealloc

- (void)dealloc {
    NSLog(@"dealloc: %@", [self class]);
}

@end
