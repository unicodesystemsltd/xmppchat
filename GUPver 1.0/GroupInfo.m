//
//  GroupInfo.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "GroupInfo.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "JSON.h"
#import "ViewMembers.h"
#import "ShareGroupInfo.h"
#import "AppDelegate.h"
#import "MarqueeLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "ChatScreen.h"

@interface GroupInfo (){
//    UIActivityIndicatorView *spinner;
    NSInteger cellPath;
}

@end

@implementation GroupInfo
@synthesize groupType,groupId,startLoading,viewType;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title=@"Group Name";
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    
    contactId = [[NSMutableArray alloc]init];
    contactName = [[NSMutableArray alloc]init];
    contactLoc = [[NSMutableArray alloc]init];
    contactIsAdmin = [[NSMutableArray alloc]init];
    contactPic = [[NSMutableArray alloc]init];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@",groupId];
    NSLog(@"$[%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/group_detail_android.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    memberConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [memberConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [memberConnection start];
    memberRsponce = [[NSMutableData alloc] init];
}
- (void)viewDidLoad{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    //[share setImage:[UIImage imageNamed:@"share_orange.png"] forState:UIControlStateNormal];
    share.tintColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0];
    favorite.tintColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0];
    
    NSString *checkIfAlreadyAddAsFav;
    checkIfAlreadyAddAsFav=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",groupId];
    BOOL addedFav=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfAlreadyAddAsFav];
    NSLog(@"bool added %d",addedFav);
    if (addedFav) {
        [favorite setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    }else{
        [favorite setImage:[UIImage imageNamed:@"favicon"] forState:UIControlStateNormal];
    }
    // check if the group is default public local group
    NSString *defaultPublicLocalGroupName= [[DatabaseManager getSharedInstance]getAppUserLocationName];
    defaultPublicLocalGroupName = [defaultPublicLocalGroupName stringByReplacingOccurrencesOfString:@","
                                                                                         withString:@""];
    NSLog(@"default public group name: %@",defaultPublicLocalGroupName);
    NSLog(@"title %@",self.title);
    if ([self.title isEqualToString:[NSString stringWithFormat:@"GUP %@",defaultPublicLocalGroupName]]||[self.title isEqualToString:[NSString stringWithFormat:@"%@ Chat",defaultPublicLocalGroupName]]){
        
        favorite.hidden=true;
        
    }

    
    
    // Do any additional setup after loading the view from its nib.
    NSString *checkIfExists;
    if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"]){
        
        checkIfExists=[NSString stringWithFormat:@"select * from groups_private where group_server_id=%@",groupId];
    }else{
        checkIfExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",groupId];
    }
    BOOL existOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfExists];
    if (existOrNot) {
        if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"]){
            
            favorite.hidden=true;
            noOfSection=2;
            // get private group info from db
            adminList=[[DatabaseManager getSharedInstance]getAdminList:groupId];
            getData = [[NSArray alloc]init];
            getData = [[DatabaseManager getSharedInstance]getPrivateGroupInfo:groupId];
            for (int i=0; i<6; i++) {
                NSLog(@"group data[%d] %@",i,getData[i]);
            }
            //[displayPic setImage:[UIImage imageNamed:getData[0]]];
            // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getData[0]]];
            NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
            NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
            UIImage *groupImage = [UIImage imageWithData:pngData];
            if (groupImage) {
                displayPic.image=groupImage;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                   NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getData[0]]]];
                   displayPic.image=[UIImage imageWithData:imgData];
                   dispatch_async(dispatch_get_main_queue(), ^{
                       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                       NSLog(@"paths=%@",paths);
                       NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getData[0]]];
                       NSLog(@"group pic path=%@",groupPicPath);
                       //Writing the image file
                       [imgData writeToFile:groupPicPath atomically:YES];
                        
                        
                    });
                    
                });
                
            }
            else
            {
                imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
                [imageActivityIndicator setCenter:CGPointMake(42.5,42.5)];
                imageActivityIndicator.color = [UIColor blackColor];
                [displayPic addSubview:imageActivityIndicator];
                [imageActivityIndicator startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getData[0]]]];
                    displayPic.image=[UIImage imageWithData:imgData];
                    [imageActivityIndicator stopAnimating];
                    [imageActivityIndicator removeFromSuperview];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                        NSLog(@"paths=%@",paths);
                        NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getData[0]]];
                        NSLog(@"group pic path=%@",groupPicPath);
                        //Writing the image file
                        [imgData writeToFile:groupPicPath atomically:YES];
                        
                        
                    });
                    
                });
                
            }

            
            
        }
        else
        {            

            noOfSection=2;
            // get public group info from db
            getDataPublic = [[NSArray alloc]init];
            getDataPublic = [[DatabaseManager getSharedInstance]getPublicGroupInfo:groupId];
            if ([getDataPublic count] == 0) {
                NSLog(@"blank");
            }
            else
            {
                for (int i=0; i<7; i++) {
                    NSLog(@"group data public[%d] %@",i,getDataPublic[i]);
                }
                //[displayPic setImage:[UIImage imageNamed:getDataPublic[0]]];
                // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getDataPublic[0]]];
                NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
                NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
                UIImage *groupImage = [UIImage imageWithData:pngData];
                if (groupImage) {
                    displayPic.image=groupImage;
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getDataPublic[0]]]];
                        displayPic.image=[UIImage imageWithData:imgData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                            NSLog(@"paths=%@",paths);
                            NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getDataPublic[0]]];
                            NSLog(@"group pic path=%@",groupPicPath);
                            //Writing the image file
                            [imgData writeToFile:groupPicPath atomically:YES];
                            
                            
                        });
                        
                    });
                    
                }
                else
                {
                    imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
                    [imageActivityIndicator setCenter:CGPointMake(42.5,42.5)];
                    imageActivityIndicator.color = [UIColor blackColor];
                    [displayPic addSubview:imageActivityIndicator];
                    [imageActivityIndicator startAnimating];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getDataPublic[0]]]];
                        displayPic.image=[UIImage imageWithData:imgData];
                        [imageActivityIndicator stopAnimating];
                        [imageActivityIndicator removeFromSuperview];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                            NSLog(@"paths=%@",paths);
                            NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getDataPublic[0]]];
                            NSLog(@"group pic path=%@",groupPicPath);
                            //Writing the image file
                            [imgData writeToFile:groupPicPath atomically:YES];
                            
                            
                        });
                        
                    });
                    
                }
            }
        }
        // fetch members of the group from cache
        
      
        
        
//        NSMutableArray *getMembers = [[NSMutableArray alloc]init];
//        
//        getMembers = [[DatabaseManager getSharedInstance]getGroupMembersList:groupId];
//        
//        NSLog(@"get members:%@",getMembers);
//        
//        
//        
//        if([getMembers count]>0){
//            
//            for(int i=0;i<[getMembers count];i++)
//                
//            {
//                
//                
//                
//                NSMutableArray *members = [getMembers objectAtIndex:i];
//                
//                [contactId addObject:[members objectAtIndex:0]];
//                
//                [contactIsAdmin addObject:[members objectAtIndex:1]];
//                
//                [contactName addObject:[members objectAtIndex:2]];
//                
//                [contactLoc addObject:[members objectAtIndex:3]];
//                
//                [contactPic addObject:[members objectAtIndex:4]];
//                
//            }
//            
//            NSLog(@"group member id:%@",contactId);
//            
//            
        
//       }

    }
    else{
        groupInfoTable.hidden=TRUE;
        share.hidden=TRUE;
        favorite.hidden=TRUE;
        [self startActivityIndicator];
        [self refreshGroupInfo];
        if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"])
        {
            
            favorite.hidden=true;
            noOfSection=2;
        }
        else
        {
            
            noOfSection=2;
            
        }

        
    }
    
    
    
  

    
    
}


-(void)startActivityIndicator
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSLog(@"start connection");
    
   

}

#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return noOfSection;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return  1;
    else if (section == 1)
    {
        if([groupType isEqualToString:@"public#global"])
            return  3;
        else
            return  4;
    }
    else
        return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    if(indexPath.section == 0)
    {
        if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"]) {
            //cell.textLabel.text = [groupDesc objectAtIndex:indexPath.row];
            [cell.textLabel setNumberOfLines:3];
            [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
            if ([getData[1] isEqualToString:@""]) {
                cell.textLabel.text = @"No Description";
            }
            else
            {
              cell.textLabel.text = getData[1];
            }
            cell.textLabel.textColor = [UIColor darkGrayColor];
            
        }
        else
        {
            if ([getDataPublic[1] isEqualToString:@""]) {
                cell.textLabel.text = @"No Description";
            }
            else
            {
                cell.textLabel.text = getDataPublic[1];
            }

            
            cell.textLabel.textColor = [UIColor darkGrayColor];
            //cell.textLabel.text = @"Detailed description will come here.This is a place to reconnect with fellow Stanford young alums, meet new friends, and stay connected.";
            
        }
        
        cell.textLabel.numberOfLines = 3;
        //cell.textLabel.lineBreakMode = ;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14.f];
    }
    else if(indexPath.section == 1)
    {if([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"])
    {
        switch(indexPath.row) {
            case 0: // Initialize cell 1
            {
                MarqueeLabel *adminListLabel;
                if ([getData count] == 0)
                {
                    cell.textLabel.text = @"";
                    adminListLabel.text =@"";
                }
                
                else
                {
                    //cell.textLabel.text = [NSString stringWithFormat:@"Admin                %@",getData[2]];
                //cell.textLabel.text = [NSString stringWithFormat:@"Admin                %@",adminList];
                cell.textLabel.text=@"Admin";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                cell.textLabel.textColor = [UIColor darkGrayColor];
                adminListLabel=[[MarqueeLabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x+140.0f, cell.frame.origin.y+8.0f,160.0f,24.0f)];
                adminListLabel.text = [NSString stringWithFormat:@"%@",adminList];
                adminListLabel.userInteractionEnabled=TRUE;
                adminListLabel.tapToScroll=TRUE;
                adminListLabel.textAlignment = NSTextAlignmentLeft;
                adminListLabel.textColor =[UIColor darkGrayColor];
                adminListLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell addSubview:adminListLabel];
                }
               
            }
                
                break;
            case 1: // Initialize cell 2
            {
                if ([getData count] == 0)
                    cell.textLabel.text = @"";
                else
                    cell.textLabel.text = [NSString stringWithFormat:@"Category            %@",getData[3]];
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                cell.textLabel.textColor = [UIColor darkGrayColor];
                
            }
                break;
            case 2: // Initialize cell 3
            {
                if ([getData count] == 0)
                    cell.textLabel.text = @"";
                else
                    cell.textLabel.text = [NSString stringWithFormat:@"Total Members   %@",getData[4]];
                cellPath = indexPath.row;
                //cell.textLabel.class = MarqueeLabel;
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                cell.textLabel.textColor = [UIColor darkGrayColor];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                
                
            }
                break;
            case 3: // Initialize cell 3
            {
                if ([getData count] == 0)
                    cell.textLabel.text = @"";
                else
                    cell.textLabel.text = [NSString stringWithFormat:@"Created On        %@",getData[5]];
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                cell.textLabel.textColor = [UIColor darkGrayColor];
                
                
            }
                break;
                
        }

            }
        else
        {
            switch(indexPath.row) {
                case 0: // Initialize cell 1
                {
                    if ([getDataPublic count] == 0)
                        cell.textLabel.text = @"";
                    else
                        cell.textLabel.text = [NSString stringWithFormat:@"Category            %@",getDataPublic[2]];
                    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                }
                    
                    break;
                case 1: // Initialize cell 2
                {
                    if ([getDataPublic count] == 0)
                        cell.textLabel.text = @"";
                    else
                        cell.textLabel.text = [NSString stringWithFormat:@"Total Members   %@",getDataPublic[3]];
                    cellPath = indexPath.row;
                    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    
                }
                    break;
                case 2: // Initialize cell 3
                {
                    if ([getDataPublic count] == 0)
                        cell.textLabel.text = @"";
                    else
                        cell.textLabel.text = [NSString stringWithFormat:@"Created On       %@",getDataPublic[5]];
                    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                    
                    
                }
                    break;
                case 3: // Initialize cell 3
                {
                  if([groupType isEqualToString:@"public#local"])
                  {
                    if ([getDataPublic count] == 0)
                        cell.textLabel.text = @"";
                    else
                        cell.textLabel.text = [NSString stringWithFormat:@"Location            %@",getDataPublic[4]];
                  }
                    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                    cell.textLabel.textColor = [UIColor darkGrayColor];
            
                }
                    break;
                    
            }

           
        }
    }
    /*else if(indexPath.section == 2)
    {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.textLabel.text = @"Members";
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }*/
       return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 60;
    else
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
      if (indexPath.section == 1) {
          if([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"])
          {
          if (indexPath.row == 2) {
              ViewMembers *membersPage = [[ViewMembers alloc]init];
              membersPage.groupId = groupId;
              membersPage.startLoading = startLoading;
              membersPage.groupType=groupType;
              membersPage.groupName=self.title;
              membersPage.viewType=viewType;
              //detailPage.notificationId = [notificationIds objectAtIndex:indexPath.row];
              [self.navigationController pushViewController:membersPage animated:YES];
          }
          }else
          {
              if (indexPath.row == 1) {
                  ViewMembers *membersPage = [[ViewMembers alloc]init];
                  membersPage.groupId = groupId;
                  membersPage.startLoading = startLoading;
                  membersPage.groupType=groupType;
                  membersPage.groupName=self.title;
                  membersPage.viewType=viewType;
                  //detailPage.notificationId = [notificationIds objectAtIndex:indexPath.row];
                  [self.navigationController pushViewController:membersPage animated:YES];
              }
          }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshGroupInfo
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *postData = [NSString stringWithFormat:@"group_id=%@",groupId];
    NSLog(@"$[%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/group_detail.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    groupInfoConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [groupInfoConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [groupInfoConn start];
    groupInfoResponse = [[NSMutableData alloc] init];

}
//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == groupInfoConn) {
        
        [groupInfoResponse setLength:0];
        
    }
    if (connection == addFavConn) {
        
        [addFavResponse setLength:0];
        
    }
    if (connection == leaveGroupConn) {
        
        [leaveGroupResponse setLength:0];
        
    }
    if (connection == memberConnection) {
        
        [memberRsponce setLength:0];
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == groupInfoConn) {
        
        [groupInfoResponse appendData:data];
        
    }
    if (connection == addFavConn) {
        
        [addFavResponse appendData:data];
        
    }
    if (connection == leaveGroupConn) {
        
        [leaveGroupResponse appendData:data];
        
    }
    if (connection == memberConnection) {
        
        [memberRsponce appendData:data];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
        
    [HUD hide:YES];
    if (connection == groupInfoConn) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == groupInfoConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:groupInfoResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        NSLog(@"end connection");
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        
        NSDictionary *results = res[@"response"];
        NSLog(@"results: %@", results);
        NSDictionary *groups=results[@"Group_Details"];
        NSString *status=results[@"status"];
        NSLog(@"status: %@",status);
        NSLog(@"groups: %@", groups);
        NSDictionary *members=groups[@"member_details"];
        NSLog(@"members: %@",members);
        //[imageView removeAllObjects];
        if ([status isEqualToString:@"1"])
        {
            favorite.hidden=true;
            share.hidden=true;
            groupInfoTable.hidden =true;
            displayPic.hidden = true;
            [HUD hide:YES];
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                   
                                                             message:@"Group does not exist."
                                   
                                                            delegate:nil
                                   
                                                   cancelButtonTitle:@"OK"
                                   
                                                   otherButtonTitles:nil];
            [alert show];
            
        }
        
        //NSLog(@"====EVENTS==3 %@",res);
        else{
        
        
            admin = groups[@"admin"];
            categoryName = groups[@"category_name"];
            creationDate = groups[@"creation_date"];
            groupDesc = groups[@"group_description"];
            groupName = groups[@"group_name"];
            groupPic = groups[@"group_pic"];
            grouptype = groups[@"group_type"];
            groupid = groups[@"id"];
            location = groups[@"location_name"];
            memberCount = groups[@"member_count"];
            
            
            NSLog(@"groupId: %@",groupid);
            NSLog(@"group name: %@",groupName);
            NSLog(@"group desc: %@",groupDesc);
            NSLog(@"group pic: %@",groupPic);
            NSLog(@"category name: %@",categoryName);
            NSLog(@"admin: %@",admin);
            NSLog(@"location: %@",location);
            NSLog(@"groupType: %@",grouptype);
            NSLog(@"created date: %@",creationDate);
            NSLog(@"member count: %@",memberCount);
            [getDataPublic[0] addObject: groupPic];
            [getDataPublic[1] addObject: groupDesc];
            [getDataPublic[2] addObject: categoryName];
            [getDataPublic[3] addObject: memberCount];
            [getDataPublic[4] addObject: location];
            [getDataPublic[5] addObject: creationDate];
            [getDataPublic[6] addObject: grouptype];
            adminList=@"";
            if (members) {
                
           
            for (NSDictionary *result in members)
             {
             NSString *contact_id= result[@"user_id"];
             NSString *contact_name = result[@"display_name"];
             NSString *contact_location = result[@"location_name"];
             NSString *contact_is_admin = result[@"is_admin"];
            if ([result[@"is_admin"]integerValue] == 1) {
               
                if ([adminList isEqualToString:@""]) {
                    adminList = [NSString stringWithFormat:@"%@",result[@"display_name"]];
                }
                else
                {
                    adminList = [NSString stringWithFormat:@"%@,%@",adminList,result[@"display_name"]];
                }
                NSLog(@"admin list %@",adminList);
            }
                 
             NSString *contact_pic = result[@"profile_pic"];
             NSLog(@"member id: %@",contact_id);
             NSLog(@"name: %@",contact_name);
             NSLog(@"location: %@",contact_location);
             NSLog(@"isadmin: %@",contact_is_admin);
             NSLog(@"contact pic: %@",contact_pic);
                 if(contact_id != nil) {
                     [contactId addObject:contact_id];
                 }
                 else
                 {
                     [contactId addObject:@""];
                 }

                 
             [contactName addObject:contact_name];
             [contactLoc addObject:contact_location];
             [contactIsAdmin addObject:contact_is_admin];
             [contactPic addObject:contact_pic];
             
             }
            }
            groupInfoTable.hidden=FALSE;
            share.hidden=FALSE;
        
        if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"])
        {
            
            favorite.hidden=true;
            noOfSection=2;
            // get private group info from db
            groupName=[groupName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            groupDesc=[groupDesc stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            
            NSString *query=[NSString stringWithFormat:@"insert into groups_private (group_server_id,created_on,created_by,group_name,group_pic,category_name,location_name,group_type,total_members,group_description) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",groupid,creationDate,admin,[groupName normalizeDatabaseElement],groupPic,categoryName,location,grouptype,memberCount,[groupDesc normalizeDatabaseElement]];
            NSLog(@"query %@",query);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            
            getData = [[NSArray alloc]init];
            getData = [[DatabaseManager getSharedInstance]getPrivateGroupInfo:groupId];
            
           /* for (int i=0; i<6; i++) {
                NSLog(@"group data[%d] %@",i,getData[i]);
            }*/
            NSString *deleteQuery = [NSString stringWithFormat:@"delete from groups_private where group_server_id=%@",groupId];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteQuery];
            
            [HUD hide:YES];
            [groupInfoTable reloadData];
            imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
            [imageActivityIndicator setCenter:CGPointMake(42.5,42.5)];
            imageActivityIndicator.color = [UIColor blackColor];
            [displayPic addSubview:imageActivityIndicator];
            [imageActivityIndicator startAnimating];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getData[0]]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [displayPic setImage:[UIImage imageWithData:imgData]];
                    [imageActivityIndicator stopAnimating];
                    [imageActivityIndicator removeFromSuperview];
                    
                });
                
            });

        }
        else
        {
           
            favorite.hidden=FALSE;
            noOfSection=2;
            groupName=[groupName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            groupDesc=[groupDesc stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *query=[NSString stringWithFormat:@"insert into groups_public (group_server_id,location_name,category_name,added_date,group_name,group_type,group_pic,group_description,total_members) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@')",groupid,location,categoryName,creationDate,[groupName normalizeDatabaseElement],grouptype,groupPic,[groupDesc normalizeDatabaseElement],memberCount];
            NSLog(@"query %@",query);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            // get public group info from db
            getDataPublic = [[NSArray alloc]init];
            getDataPublic = [[DatabaseManager getSharedInstance]getPublicGroupInfo:groupId];
            if ([getDataPublic count] == 0) {
                NSLog(@"blank");
            }
            else
            {
                for (int i=0; i<6; i++) {
                    NSLog(@"group data public[%d] %@",i,getDataPublic[i]);
                }
            NSString *deleteQuery = [NSString stringWithFormat:@"delete from groups_public where group_server_id=%@",groupId];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteQuery];
                
                [HUD hide:YES];
                [groupInfoTable reloadData];
                imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
                [imageActivityIndicator setCenter:CGPointMake(42.5,42.5)];
                imageActivityIndicator.color = [UIColor blackColor];
                [displayPic addSubview:imageActivityIndicator];
                [imageActivityIndicator startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getDataPublic[0]]]];
                    
                dispatch_async(dispatch_get_main_queue(), ^{

                    [displayPic setImage:[UIImage imageWithData:imgData]];
                    [imageActivityIndicator stopAnimating];
                    [imageActivityIndicator removeFromSuperview];

                        
                    });
                    
                });
            }
        }
    }
        groupInfoConn=nil;
        
        [groupInfoConn cancel];
        
    }
    /*if (connection == addFavConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:addFavResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];

        
        NSDictionary *results = res[@"response"];
        NSLog(@"results: %@", results);
        int status = [res[@"status"]integerValue];
        NSString *error=res[@"error"];
        if (status==0) {
            
             NSLog(@"contact id array: %@",contactId);
             NSLog(@"contact name array: %@",contactName);
             NSLog(@"contact loc array: %@",contactLoc);
             NSLog(@"contact is admin array: %@",contactIsAdmin);
             NSLog(@"contact display pic: %@",contactPic);
             
             NSLog(@"cat name:%@",categoryName);
             groupName=[groupName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
             groupDesc=[groupDesc stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            long groupMemCount=[getDataPublic[3]integerValue]+1;
            
            NSString *query=[NSString stringWithFormat:@"insert into groups_public (group_server_id,location_name,category_name,added_date,is_favourite,group_name,group_type,group_pic,group_description,total_members) values ('%@','%@','%@','%@','%i','%@','%@','%@','%@','%ld')",groupId,getDataPublic[4],getDataPublic[2],getDataPublic[5],1,[self.title normalizeDatabaseElement],getDataPublic[6],getDataPublic[0],[getDataPublic[1] normalizeDatabaseElement],groupMemCount];
            
            NSLog(@"query %@",query);
            
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            
            
            
            for (int k=0; k<[contactId count]; k++) {
                
                NSString *query1=[NSString stringWithFormat:@"insert into group_members (group_id,contact_id,is_admin,contact_name,contact_location,contact_image) values ('%@','%@','%@','%@','%@','%@')",groupId,contactId[k],contactIsAdmin[k],[contactName[k] normalizeDatabaseElement],contactLoc[k],contactPic[k]];
                
                NSLog(@"query %@",query1);
                
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query1];
                
            }
            
            NSString *memberInsertQuery=[NSString stringWithFormat:@"insert into group_members (group_id,contact_id,is_admin,contact_name,contact_location,contact_image) values ('%@','%@','%d','%@','%@','%@')",groupId,[[DatabaseManager getSharedInstance]getAppUserID],0,[[[DatabaseManager getSharedInstance]getAppUserName] normalizeDatabaseElement],[[DatabaseManager getSharedInstance]getAppUserLocationName],[[DatabaseManager getSharedInstance]getAppUserImage]];
            
            NSLog(@"query %@",memberInsertQuery);
            
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:memberInsertQuery];
            //download image and save in the cache
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getDataPublic[0]]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //cell.imageView.image = [UIImage imageWithData:imgData];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSLog(@"paths=%@",paths);
                    NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getDataPublic[0]]];
                    NSLog(@"group pic path=%@",groupPicPath);
                    //Writing the image file
                    [imgData writeToFile:groupPicPath atomically:YES];
                    
                    
                });
                
            });

            [HUD hide:YES];
             
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Group has been added to favorites."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             
             [alert show];

        }
        else
        {
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
            
        }
        
        addFavConn=nil;
        
        [addFavConn cancel];
    }*/
    
    if (connection == addFavConn) {
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:addFavResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        NSLog(@"end connection");
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        NSLog(@"results: %@", results);
        NSDictionary *groups=results[@"Group_Details"];
        NSString *status=results[@"status"];
        NSLog(@"status: %@",status);
        NSLog(@"groups: %@", groups);
        NSDictionary *members=groups[@"member_details"];
        NSLog(@"members: %@",members);
        NSDictionary *deletedMembers = groups[@"deleted_members"];
        NSLog(@"deleted members%@",deletedMembers);
        NSString *error=results[@"error"];
        
        //[imageView removeAllObjects];
        if (![status isEqualToString:@"1"])
        {
            
            NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",groups[@"id"]];
            BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
            if (publicGroupExistOrNot) {
                NSString *updatePublicGroup=[NSString stringWithFormat:@"update  groups_public set group_server_id = '%@', location_name = '%@', category_name = '%@', added_date ='%@',is_favourite ='1', group_name ='%@', group_type='%@', group_pic='%@', group_description='%@', total_members='%@' where group_server_id = '%@' ",groups[@"id"],groups[@"location_name"],groups[@"category_name"],groups[@"creation_date"],[groups[@"group_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"group_type"],groups[@"group_pic"],[groups[@"group_description"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"member_count"],groups[@"id"]];
                NSLog(@"query %@",updatePublicGroup);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updatePublicGroup];
            }
            else
            {
                
                NSString *insertPublicGroup=[NSString stringWithFormat:@"insert into groups_public (group_server_id, location_name, category_name, added_date,is_favourite, group_name,group_type, group_pic,group_description,total_members) values ('%@','%@','%@','%@','%d','%@','%@','%@','%@','%@')",groups[@"id"],groups[@"location_name"],groups[@"category_name"],groups[@"creation_date"],1,[groups[@"group_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"group_type"],groups[@"group_pic"],[groups[@"group_description"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"member_count"]];
                NSLog(@"query %@",insertPublicGroup);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertPublicGroup];
            }
            
            if ([members count]==0 )
            {
                NSLog(@"no members");
            }
            else
            {
                for (NSDictionary *member in members)
                {
                    NSString *checkIfMemberExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@ and deleted=0",groups[@"id"],member[@"user_id"]];
                    BOOL memberExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberExists];
                    if (memberExistOrNot) {
                        NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set group_id = '%@', contact_id = '%@', is_admin = '%@', contact_name ='%@', contact_location ='%@', contact_image='%@' where group_id = '%@' and contact_id='%@' ",groups[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"],groups[@"id"],member[@"user_id"]];
                        NSLog(@"query %@",updateMembers);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                    }
                    else
                    {
                        
//                        NSString *insertMembers=[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, is_admin, contact_name, contact_location,contact_image) values ('%@','%@','%@','%@','%@','%@')",groups[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"]];
//                        NSLog(@"query %@",insertMembers);
//                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertMembers];
                    }
                    //download image and save in the cache
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,member[@"profile_pic"]]]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //cell.imageView.image = [UIImage imageWithData:imgData];
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                            NSLog(@"paths=%@",paths);
                            NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",member[@"profile_pic"]]];
                            NSLog(@"member pic path=%@",memberPicPath);
                            //Writing the image file
                            [imgData writeToFile:memberPicPath atomically:YES];
                            
                            
                        });
                        
                    });
                    
                    
                }
            }
            if ([deletedMembers count]==0 )
            {
                NSLog(@"no members");
            }
            else
            {
                for (NSDictionary *deletedMember in deletedMembers)
                {
                    NSLog(@"deleted user id%@ \n",deletedMember);
                    NSString *checkIfMemberToDeleteExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@",groups[@"id"],deletedMember];
                    BOOL memberToDeleteExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberToDeleteExists];
                    if (memberToDeleteExistOrNot) {
                        // NSString *deleteMemberQuery=[NSString stringWithFormat:@"delete from group_members where group_id=%@ and contact_id=%@ ",groups[@"id"],deletedMember];
                        //NSLog(@"query %@",deleteMemberQuery);
                        // [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteMemberQuery];
                        NSString *updateMemberQuery=[NSString stringWithFormat:@"update group_members set deleted=1 where group_id=%@ and contact_id=%@ ",groups[@"id"],deletedMember];
                        NSLog(@"query %@",updateMemberQuery);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMemberQuery];
                    }
                    
                }
            }
            
            //download image and save in the cache
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,groups[@"group_pic"]]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //cell.imageView.image = [UIImage imageWithData:imgData];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSLog(@"paths=%@",paths);
                    NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",groups[@"group_pic"]]];
                    NSLog(@"member pic path=%@",memberPicPath);
                    //Writing the image file
                    [imgData writeToFile:memberPicPath atomically:YES];
                    
                    
                });
                
            });
            
            [HUD hide:YES];
            NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@",groups[@"id"]]];
            NSMutableArray    *membersID=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempmembersID count];i++)
            {//if(![[tempmembersID objectAtIndex:i]isEqual:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]])
                [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
            }
            
            NSLog(@"membersID %@",membersID);
            
            //4552
            for (int j=0; j<[membersID count]; j++)
            {NSLog(@"%@ %@",membersID,membersID[j]);
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                [attributeDic setValue:[[membersID objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *body=[NSString stringWithFormat:@"Your request to join %@ has been accepted",groups[@"group_name"] ];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                [elementDic setValue:@"0" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"isgroup"];
                NSLog(@"gid %@",groups[@"id"]);
                [elementDic setValue:groups[@"id"] forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
            
            
            
            ChatScreen *chatScreen = [[ChatScreen alloc]init];
            
            chatScreen.chatType = @"group";
            chatScreen.chatTitle=groups[@"group_name"];
            [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[groups[@"id"] integerValue],(NSString*)jabberUrl]];
            
            chatScreen.groupType=groups[@"group_type"] ;
            [chatScreen retreiveHistory:nil];
             [self appDelegate].currentUser=@"";
            //[self.navigationController pushViewController:chatScreen animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
        else
        {
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            
        }
        
        addFavConn=nil;
        
        [addFavConn cancel];
    }

    
    if (connection == leaveGroupConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:leaveGroupResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        
        NSDictionary *result = res[@"response"];
        NSLog(@"result: %@", result);
        NSString *leaveStatus = result[@"status"];
        NSLog(@"status: %@", leaveStatus);
        NSString *error=result[@"Error"];
        NSLog(@"error: %@", error);
        [HUD hide:YES];
        if ([leaveStatus isEqualToString:@"0"])
        {
            NSString *deleteQuery=[NSString stringWithFormat:@"delete from groups_public where group_server_id='%@'",groupId];
            NSLog(@"query %@",deleteQuery);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteQuery];
            NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@ and contact_id!=%@",groupId,[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]]];
            NSMutableArray    *membersID=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempmembersID count];i++)
            {//if(![[tempmembersID objectAtIndex:i]isEqual:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]])
                [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
            }
            
            NSLog(@"membersID %@",membersID);
            
            //4552
            for (int j=0; j<[membersID count]; j++){
                NSLog(@"%@ %@",membersID,membersID[j]);
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                [attributeDic setValue:[[membersID objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *body=[NSString stringWithFormat:@"Your request to join %@ has been accepted",self.title ];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                [elementDic setValue:@"0" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"isgroup"];
                NSLog(@"gid %@",groupId);
                [elementDic setValue:groupId forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
            

            NSString *deleteMembers=[NSString stringWithFormat:@"delete from group_members where group_id='%@'",groupId];
            
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteMembers];
            
            //clear chat for the group
            
            [[self appDelegate] clearChatHistoryForGroup:groupId];
         //  [self.navigationController popToRootViewControllerAnimated:YES];
            [self.navigationController popViewControllerAnimated:YES];
            
           
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        leaveGroupConn=nil;
        
        [leaveGroupConn cancel];
    }
    
    if (connection == memberConnection) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:memberRsponce encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        
        NSDictionary *result = res[@"response"];
        NSLog(@"result: %@", result);
        NSString *leaveStatus = result[@"status"];
        NSLog(@"status: %@", leaveStatus);
        NSString *error=result[@"Error"];
        NSLog(@"error: %@", error);
        if ([leaveStatus isEqualToString:@"0"]) {
            NSDictionary *groupdDetail = result[@"Group_Details"];
            NSString *membercount = groupdDetail[@"member_count"];
            NSLog(@"%@",membercount);
            UITableViewCell *cell = (UITableViewCell*)[groupInfoTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellPath inSection:1]];
            cell.textLabel.text = [NSString stringWithFormat:@"Total Members   %@",membercount];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        leaveGroupConn=nil;
//        [spinner startAnimating];
//        [spinner removeFromSuperview];
        [leaveGroupConn cancel];
    }


}
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(IBAction)shareGroupInfo:(id)sender
{
    ShareGroupInfo *shareGroupInfoPage = [[ShareGroupInfo alloc]init];
    shareGroupInfoPage.groupId = groupId;
    shareGroupInfoPage.groupName = self.title;
    shareGroupInfoPage.hideUnhideSkipDoneButton = @"hide";
    [self.navigationController pushViewController:shareGroupInfoPage animated:YES];
}

-(IBAction)addToFavorite:(id)sender
{
    NSString *appUserId = [[DatabaseManager getSharedInstance]getAppUserID];
    [self startActivityIndicator];
    if ([favorite currentImage] == [UIImage imageNamed:@"star"]) {
        //[favorite setImage:[UIImage imageNamed:@"favicon"] forState:UIControlStateNormal];
        NSLog(@"You have clicked submit leave%@%@",groupId,appUserId);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",groupId,appUserId];
        NSLog(@"$[%@]",postData);
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/leave_group.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        leaveGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [leaveGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [leaveGroupConn start];
        leaveGroupResponse = [[NSMutableData alloc] init];
        
    }
    else {
        [favorite setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
        
       /* NSLog(@"You have clicked submit add%@%@",groupId,appUserId);

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@&flag=0",groupId,appUserId];
        NSLog(@"$[%@]",postData);
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/private_grp_request.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        addFavConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [addFavConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [addFavConn start];
        addFavResponse = [[NSMutableData alloc] init];*/
        //check whter group is already added
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
           NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@&flag=0",groupId,appUserId];
            NSLog(@"postdata%@",postData);
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_fav.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            addFavConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [addFavConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [addFavConn start];
            addFavResponse = [[NSMutableData alloc] init];

    }
}

@end
