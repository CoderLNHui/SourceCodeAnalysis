//
//  Config.h
//  SDWebImage4.X源码阅读201704
//
//  Created by huangchengdu on 17/4/28.
//  Copyright © 2017年 huangchengdu. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define alert(msg) [[[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];

#define showMessage(MESSAGE,QUVC) UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"弹出框" message:MESSAGE preferredStyle:UIAlertControllerStyleAlert];\
[alertController addAction:[UIAlertAction actionWithTitle:@"确定"style:UIAlertActionStyleDefault handler:nil]];\
[QUVC presentViewController:alertController animated:YES completion:nil];

#endif /* Config_h */
