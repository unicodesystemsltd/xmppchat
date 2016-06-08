//
//  GroupInfo.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface GroupInfo : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{int noOfSection;
    IBOutlet UITableView *groupInfoTable;
    IBOutlet UIButton *favorite,*share;
    IBOutlet UIImageView *displayPic;
    NSArray *getData,*getDataPublic;
    //,*groupPic,*groupDesc,*groupAdmin,*groupCategory,*groupMembers,*createdOn;
    NSURLConnection *groupInfoConn,*memberConnection;
   
    NSMutableData *groupInfoResponse, *memberRsponce;
    NSMutableArray *contactId,*contactName,*contactLoc,*contactIsAdmin,*contactPic;
    
    NSString *categoryName,*admin,*creationDate,*groupDesc,*groupName,*groupPic,*grouptype,*groupid,*location,*memberCount;
    
    UIActivityIndicatorView *activityIndicator;
    UIActivityIndicatorView *imageActivityIndicator;
    UIView *freezer;
    
    NSURLConnection *addFavConn,*leaveGroupConn;
    NSMutableData *addFavResponse,*leaveGroupResponse;
    
    NSString *adminList;
    MBProgressHUD *HUD;
    
    
}
@property(strong,nonatomic)NSString *groupType;
@property (strong, nonatomic) NSString  *groupId;
@property(strong,nonatomic)NSString *startLoading;
@property(strong,nonatomic)NSString *viewType;

-(void)refreshGroupInfo;
-(IBAction)shareGroupInfo:(id)sender;
-(IBAction)addToFavorite:(id)sender;
-(void)startActivityIndicator;


@end
