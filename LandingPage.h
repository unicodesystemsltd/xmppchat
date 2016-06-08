//
//  LandingPage.h
//  GUP
//
//  Created by Milind Prabhu on 7/31/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LandingPage : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{
    IBOutlet UITableView *GroupsListTable;
    IBOutlet UIButton *skip,*done;
    NSURLConnection *listGroupsConn;
    NSMutableData *listGroupsResponse;
    NSURLConnection *initiateGroupJoinConn,*addGroupConn,*addFavGroupConn;
    NSMutableData *initiateGroupJoinResponse,*addGroupResponse,*addFavGroupResponse;
    
    NSString *selectedGroupId,*selectedGroupName,*selectedGroupPic,*selectedGroupType;
    
    NSMutableArray *groupIds,*groupNames,*adminNames,*groupDisplayThumbnails,*groupTypes,*groupLocations,*popularityFactor;
    
    MBProgressHUD *HUD;
    

}


@property(nonatomic,strong) NSString *registrationID;
-(void)listGroupsAssociatedToCategory;
-(IBAction)skip:(id)sender;
-(IBAction)done:(id)sender;
@end
