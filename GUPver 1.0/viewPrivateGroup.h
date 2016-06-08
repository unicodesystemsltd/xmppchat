//
//  viewPrivateGroup.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface viewPrivateGroup : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>
{
    IBOutlet UITableView *viewPrivateGroupTable;
    IBOutlet UIButton *favorite,*share;
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *descTextField;
    NSString *groupPic,*groupDesc,*categoryName,*groupName,*groupLocation,*GName;
    IBOutlet UIScrollView *scrollView;
    UILabel *categoryLabel;
    
    IBOutlet UIImageView *groupImageView;
    
    CGRect TXFRAME;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
    NSURLConnection *updateDescriptionConn,*updateNameConn,*memberConnection;
    NSMutableData *updateDescriptionResponse,*updateNameResponse,*memberRsponce;
    
    NSURLConnection *editCategoryConn,*uploadGroupPicConn,*editLocationConn,*deleteImageConn,*getGroupJoinRequestCountConn,*leaveGroupConn;//*makeAdminConn,*leaveAsAdminConn;
    NSMutableData *editCategoryResponse,*uploadGroupPicResponse,*editLocationResponse,*deleteImageResponse,*getGroupJoinRequestCountResponse,*leaveGroupResponse;//*makeAdminResponse,*leaveAsAdminResponse;
    
    NSString *categoryID;
    UITapGestureRecognizer *tapRecognizer;
    UIImagePickerController *iPicker;
    NSData *imageData;
    int groupJoinCount;
    int totalMembersCount;
    
    UIImage *chosenImage;
    UIActivityIndicatorView *imageActivityIndicator;
    
    MBProgressHUD *HUD;
}
-(void)updateCategory:(NSString*)newCategory categoryId:(NSString*)catId;
-(void)updateLocationLable:(NSString*)newLocation locationID:(NSInteger)locID;
@property (nonatomic, retain) NSString  *groupType;
@property (nonatomic, retain) NSString  *groupId;
@property (nonatomic, retain) NSString  *viewType;

-(void)uploadDisplayPicToServer;
- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer;
-(IBAction)shareGroupInfo:(id)sender;
-(void)getGroupJoinRequestCount;
-(IBAction)leaveGroup:(id)sender;
-(void)refreshGroupInfo;


@end
