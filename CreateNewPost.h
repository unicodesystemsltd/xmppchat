//
//  CreateNewPost.h
//  GUP
//
//  Created by Ram Krishna on 13/12/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ELCImagePicker/ELCImagePickerController.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPRoom.h"

@interface CreateNewPost : UIViewController<UIActionSheetDelegate,UITextViewDelegate,MBProgressHUDDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ELCImagePickerControllerDelegate,XMPPRoomDelegate,XMPPStreamDelegate>{
    
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
    MBProgressHUD *HUD;
    UITextView *textView;
    NSMutableArray *imageArray;
    NSURLConnection *createPostConn;
    NSMutableData *createPostResponse;
    UILabel *textCounterLbl;
}

@property(nonatomic,assign) NSString *groupName;
@property(nonatomic,assign) NSString *groupID;

@end
