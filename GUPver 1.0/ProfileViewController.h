//
//  ProfileViewController.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface ProfileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NSURLConnectionDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    IBOutlet UITableView *profileTable;
    IBOutlet UIImageView *profileImageView;
    UITextField *userNameTextField;
    float animatedDistance;
    UIActivityIndicatorView *activityIndicator;
    IBOutlet UIScrollView *mainScroll;
    CGRect TXFRAME;
    
    int reloadVariable;
    NSInteger locationID;
    // profile data array
    NSArray *getData;
    UIImage *chosenImage;
    NSString *oldUserName;
   
    
    NSURLConnection *uniquenessCheckConn,*updateLocationConn,*uploadProfilePicConn,*deleteImageConn;
    NSMutableData *eventsResponse,*updateLocationResponse,*uploadProfilePicResponse,*deleteImageResponse;
    UITapGestureRecognizer *tapRecognizer;
    
    //camera
    BOOL newMedia;
    UIImagePickerController *iPicker;
    NSData *imageData;
    UIActivityIndicatorView *imageActivityIndicator;
    BOOL socialLogin;
    NSString *selectedLocation;
      NSMutableArray *contactIDs;
    UIImageView *accview;
    UIImage *savedImage;
    
   
}

//@property (nonatomic, retain)  NSString *serverUrlString;
-(void)editProfile;
-(void)initialiseView;
-(void)uniquenessCheckForUserName;
-(void)updateLocationLable:(NSString*)newLocation locationID:(NSInteger)locID;

- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer;
-(void)uploadDisplayPicToServer;
-(void)getProfileData;

@end
