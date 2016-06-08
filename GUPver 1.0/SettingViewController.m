//
//  SettingViewController.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "SettingViewController.h"

#import "SettingsAlert.h"
#import "SettingsBlocked.h"
#import "ChatWallpaper.h"
#import "AboutUs.h"
#import "Login.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "WebView.h"
#import "SettingsDelete.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = NSLocalizedString(@"Settings", @"Settings");
        self.navigationItem.title = @"Settings";
       
        UIImage *selectedImage = [UIImage imageNamed:@"settings_blue"];
        UIImage *unselectedImage = [UIImage imageNamed:@"settings"];
        [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
         self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}
-(void)setActivityIndicator
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:UITextAttributeTextColor]];
    [self initialiseView];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    blockedUsersCount = [[DatabaseManager getSharedInstance]fetchBlockedUsersCount];
    NSLog(@"blocked users count:%d",blockedUsersCount);
    [settingsTable reloadData];
    
}


-(void)initialiseView
{
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    [settingsTable setDelegate:self];
    [settingsTable setDataSource:self];
}


#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return  4;
    if (section == 1)
        return  3;
    if (section == 2)
        return 1;
    else
        return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if(indexPath.section == 1)
    {
        switch(indexPath.row) {
            case 0: // Initialize cell 1
            {
                cell.textLabel.text = @"About";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

            }
                
                break;
            case 1: // Initialize cell 2
            {
                cell.textLabel.text = @"Help";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

            }
                break;
            case 2: // Initialize cell 3
            {
                cell.textLabel.text = @"Contact Us";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                
            }
                break;
        }

    }
    else if(indexPath.section == 0)
    {
        switch(indexPath.row) {
            case 0: // Initialize cell 1
            {
                cell.textLabel.text = @"Alerts";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
                
                break;
            case 1: // Initialize cell 2
            {
                cell.textLabel.text = @"Blocked Users";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                NSLog(@"count of blocked users in cell for row: %d",blockedUsersCount);
                UILabel *blockedUserNoLabel;
                if (!(blockedUsersCount==0))
                {
                    if (blockedUserNoLabel==nil)
                    {
                        blockedUserNoLabel=[[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width-74, cell.frame.origin.y+8,24,24)];
                    }
                [blockedUserNoLabel removeFromSuperview];
                blockedUserNoLabel.text=[NSString stringWithFormat:@"%d",blockedUsersCount];
                blockedUserNoLabel.backgroundColor=[UIColor lightGrayColor];
                blockedUserNoLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:10.f];
                blockedUserNoLabel.textAlignment = NSTextAlignmentCenter;
                [blockedUserNoLabel.layer setBorderColor:[[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor]];
                //[joinRequestLabel setBorderWidth:1.0];
                blockedUserNoLabel.layer.cornerRadius = 8;
                blockedUserNoLabel.clipsToBounds = YES;
                [cell addSubview:blockedUserNoLabel];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                }
                else
                {
                    [blockedUserNoLabel removeFromSuperview];
                   
                }
            
            }
                break;
            case 2: // Initialize cell 3
            {
                cell.textLabel.text = @"Chat Wallpaper";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                
            }
                break;
            case 3: // Initialize cell 4
            {
                cell.textLabel.text = @"Clear Chat History";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                
            }
                
                break;
            case 4: // Initialize cell 5
            {
                
                cell.textLabel.text = @"Recover Messages";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                
            }
                break;

                
        }
    }
    
       else if (indexPath.section == 2)
    {
        switch(indexPath.row) {
            case 0: // Initialize cell 1
            {
                cell.textLabel.text = @"Logout";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
            }
                
                break;
                
        }
    }
       else if (indexPath.section == 3)
       {
           switch(indexPath.row) {
            case 0: // Initialize cell 2
               {
                  
                   cell.textLabel.text = @"Delete Account";
                   cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                   
               }
                   
                   break;
                   
           }
       }


    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    switch (indexPath.section) {
        case 0:
            switch(indexPath.row) {
                case 0: // clicked Alerts
                {
                    SettingsAlert *addGroupPage = [[SettingsAlert alloc]init];
                    [self.navigationController pushViewController:addGroupPage animated:YES];
                }
                    break;
                case 1: // clicked Blocked User
                {
                    if (!(blockedUsersCount == 0)) {
                    SettingsBlocked *blockedPage = [[SettingsBlocked alloc]init];
                    [self.navigationController pushViewController:blockedPage animated:YES];
                    }
                    else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"There are no Blocked Users."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    }
                   
                }
                    break;
                case 2: // clicked Wallpaper
                {
                    ChatWallpaper *wallpaperPage = [[ChatWallpaper alloc]init];
                    [self.navigationController pushViewController:wallpaperPage animated:YES];
                }
                    break;
                case 3: // clicked Recover Messages
                {
                    //Clear chat history
                    NSString *option=@"Clear Chat History";
                    NSString *cancelTitle = @"Cancel";
                    UIActionSheet *settingsActionSheet= [[UIActionSheet alloc]
                                                         initWithTitle:@"Are you sure you want to clear all Chat History?"
                                                         delegate:self
                                                         cancelButtonTitle:cancelTitle
                                                         destructiveButtonTitle:option
                                                         otherButtonTitles:nil];
                    [settingsActionSheet showFromTabBar:self.tabBarController.tabBar];
                  
                }
                    break;
                case 4: // clicked Clear Chat History
                {
                   
                    //Recover Messages
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:@"Coming Soon"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    
                    [alert show];
                }
                    break;
            }

            break;
        case 1:
        {
        switch(indexPath.row) {
                case 0: // clicked about us
                {
                    AboutUs *aboutUsPage = [[AboutUs alloc]init];
                    [self.navigationController pushViewController:aboutUsPage animated:YES];
                }
                    break;
                case 1: // clicked help
                {
                    WebView *webview = [[WebView alloc]init];
                    webview.fromView=@"help";
                    [self.navigationController pushViewController:webview animated:YES];
                }
                    break;
                case 2: // clicked Contact us
                {
                    
                    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                    if ([MFMailComposeViewController canSendMail])
                    {
                         NSString *emailTitle = @"Contact Us";
                        NSArray *toRecipents = [NSArray arrayWithObject:@"support@gupapp.com"];
                        mc.mailComposeDelegate = self;
                        [mc setSubject:emailTitle];
                        [mc setToRecipients:toRecipents];
                        
                        // Present mail view controller on screen
                        [self presentViewController:mc animated:YES completion:NULL];
                    }

                 }
                     break;
            }
            
            break;

        }
            break;
        case 2:
        {
            switch(indexPath.row) {
                case 0: // clicked logout
                {
                   // AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                  
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    NSLog(@"d i %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]);
                    NSString *postData = [NSString stringWithFormat:@"user_id=%@&deviceToken=%@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"Jid"] userID],[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]];
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/logout.php",gupappUrl]]];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                    LOGOUT = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                    [LOGOUT scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [LOGOUT start];
                    LOGOUTRESPONSE = [[NSMutableData alloc] init];
                    [self setActivityIndicator];
                  /*  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from master_table "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from blocked_user "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_group "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_message "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_personal "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from contacts "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_category "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_join_request "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_members "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_private "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_public "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from notify_settings "];*/
                    //AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                //    [appDelegateObj setLoginView];

                   

                }
                    break;
            }
            
            break;
        }
        case 3:
        {
            switch(indexPath.row) {
                case 0: // clicked delete account
                {
                    SettingsDelete *deleteAccount = [[SettingsDelete alloc]init];
                    [self.navigationController pushViewController:deleteAccount animated:YES];
                }
                    break;
        }
            
            break;
       
        default:
            break;
    }
}

}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == LOGOUT) {
        [LOGOUTRESPONSE setLength:0];
    }
   }
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did recieve data");
    if (connection == LOGOUT) {
        [LOGOUTRESPONSE appendData:data];
    }
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [HUD hide:YES];
    
}
- (void)       connection:(NSURLConnection *)connection
          didSendBodyData:(NSInteger)bytesWritten
        totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@" finished loading");
    if (connection == LOGOUT)
    { NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:LOGOUTRESPONSE encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSLog(@"====EVENTS==3 result %@",res);
        NSDictionary *responce= res[@"response"];
        NSLog(@"vishals responce %@",responce);
        
     BOOL   status= [responce[@"status"] boolValue];
        
        if (status)
        {AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [[self appDelegate] goOffline ];
            [[self appDelegate]disconnect];
            [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
             [appDelegateObj setLoginView];
        }
         [HUD hide:YES];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"button title:%i,%@",buttonIndex ,buttonTitle);
    if ([buttonTitle isEqualToString:@"Clear Chat History"])
    {
        // delete
        NSArray *fileList=[[NSArray alloc]init];
        fileList=[[DatabaseManager getSharedInstance]fetchFileNamesToBeDeleted];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        for (int i=0;i<fileList.count;i++) {
            NSLog(@"file list:%@",fileList[i]);
            NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",fileList[i]]];
            NSError *error = nil;
            if(![fileManager removeItemAtPath: imgPathRetrieve error:&error])
                NSLog(@"Delete failed:%@", error);
            else
                NSLog(@"image removed: %@", imgPathRetrieve);
        }
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"delete from chat_personal"]];
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"delete from chat_group"]];
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"delete from chat_message"]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
