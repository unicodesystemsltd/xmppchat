//
//  ExploreViewController.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/13/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ExploreViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,NSURLConnectionDelegate,MBProgressHUDDelegate>
{
    NSMutableArray *categoryThumbnails,*categoryNames,*categoryGroupNo,*categoryIds,*filterOptionsList;
    NSMutableArray *textLabel,*detailTextLabel,*imageView,*tableType,*typeArray,*resultIdArray,*userEmailId,*userStatus;
    NSMutableArray *tempTextLabel,*tempDetailTextLabel,*tempImageView,*tempTableType,*tempTypeArray,*tempResultIdArray,*tempUserEmailId,*tempUserStatus;
    int searchVariable;
    IBOutlet UITableView *ExploreTableView;
    UILabel *categoryGroups;
    IBOutlet UISearchBar *search;
    //IBOutlet UILabel *exploreGroupLabel;
    NSURLConnection *fetchLocationConn,*searchConn,*addContactConn;
    NSMutableData *fetchLocationResponse,*searchResponse,*addContactResponse;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
    
    NSString *selectedContactId,*selectedContactEmail,*selectedContactName,*selectedContactPic,*selectedContactStatus,*selectedContactLocation;
    
    NSURLConnection *initiateGroupJoinConn,*addGroupConn,*addFavGroupConn,*groupCountConn;
    NSMutableData *initiateGroupJoinResponse,*addGroupResponse,*addFavGroupResponse,*groupCountResponse;
    
    NSString *selectedGroupId,*selectedGroupName,*selectedGroupPic,*selectedGroupType;
    NSString *appUserId;
    
    
    NSMutableArray *categoryImageData;
    UIImageView *categoryImageView;
    UILabel *categoryNameLabel;
    
    MBProgressHUD *HUD;
    IBOutlet UILabel *groupByCategoryLabel;
    
    UIBarButtonItem *filterButton;
    
   // NSString *status;
    UIViewController *testviewcontroller;
    UITableViewController *filterTable;
    UINavigationController *navController;
    UIPopoverController *pop;
    
    //NSMutableArray *someFilterVariable;
    int userFilter,privateFilter,publicFilter;

}

//-(void)cancel:(id)sender;
-(void)listCategories;
-(void)setActivityIndicator;
-(void)fetchGroupCount;
-(IBAction)setFilterTable:(id)sender;
-(void)donefiltering:(id)sender;
-(void)cancelPop:(id)sender;
-(void)clearArrays:(NSString*)variable;

@end
