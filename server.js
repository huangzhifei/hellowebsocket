'use strict';

const express = require('express');
const SocketServer = require('ws').Server;
const path = require('path');
const PORT = process.env.PORT || 3000;
const INDEX = path.join(__dirname, 'index.html');
const server = express().use((req,res) => res.sendFile(INDEX))
                        .listen(PORT, () => console.log(`Listening on ${ PORT }`));

// 定义一个字典，用来存用户和websocket映射
var wsuserdic = {};
const wss = new SocketServer({server});
wss.on('connection', (ws, req) => {
    // 读取连接时的参数
    // 3.0.0版本后，要通过这种方式才能使用 upgradeReq
    ws.upgradeReq = req;
    console.log('1 ' + ws.upgradeReq.url);
    var parts = ws.upgradeReq.url.split("?")[1].split("&")
    var length = parts.length;
    for (var index = 0; index < length; index ++) {
        //编译参数
        var strarr = parts[index].split("=");
        //读取用户id，和websocket对应起来
        if (strarr[0] === 'userId') {
            wsuserdic[strarr[1]] = ws;
            console.log(strarr[1] + '已经连接');
            break;
        }
    }

    ws.on('message', (message) =>{
        var sendMsg = message.split("^")[1];
        if (message.split("^")[0] === "") {
            for (var userId in wsuserdic) {
                var tows = wsuserdic[userId];
                tows.send(sendMsg);
            }
            console.log("向所有人发送消息 " + sendMsg);
            return;
        }

        var towsarr = message.split("^")[0].split("#");
        towsarr.map((userId, i) => {
            for (var userdic in wsuserdic) {
                if (userdic === userId) {
                    var tows = wsuserdic[userId];
                    tows.send(sendMsg);
                    break;
                }
            }
            console.log("向某些人发送消息 " + sendMsg);
        });
    });
});