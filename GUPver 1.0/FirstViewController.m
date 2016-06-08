//
//  FirstViewController.m
//  GUPver 1.0
//
//  Created by genora on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "FirstViewController.h"
#import "XMPPJID.h"
#import "ChatScreen.h"
#import "AppDelegate.h"
#import "CreateGroup.h"
#import "FPPopoverController.h"
#import "DatabaseManager.h"
#import "ViewContactProfile.h"
#import "GroupInfo.h"
#import "viewPrivateGroup.h"
#import "globleData.h"
#import "NSString+Utils.h"
#import "SBJSON.h"
#import "Haneke.h"
#import "CreateNewPost.h"
#import "PostListing.h"
#import "AFNetworking.h"


@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize type,messageToBeForwarded,msgType,appUserId,sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Home", @"Home");
        self.navigationItem.title = @"GUP";
        //self.tabBarItem.image = [UIImage imageNamed:@"home"];
        UIImage *selectedImage = [UIImage imageNamed:@"home_blue"];
        UIImage *unselectedImage = [UIImage imageNamed:@"home"];
        [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
    }
    return self;
}
- (void)buddyStatusUpdated{
    
    [self fetchGroups];
    [self refreshChatList];
    [self refreshGroupList];
    
}
- (AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}
- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}
- (XMPPRoster *)xmppRoster {
    return [[self appDelegate] xmppRoster];
}
-(void)freezerAnimate{
    if (HUD==nil ){
        [self setActivityIndicator];
    }
    [HUD setHidden:NO];
}
-(void)freezerRemove{
    if(HUD!=nil){
        [HUD setHidden:YES];
    }
}
-(void)initiateChat{
    
    NSArray *excutedOutput=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select id,logged_in_user_id,email,password, language,verified,display_name,display_pic,status,chat_wall_paper,social_login,social_login_type,social_login_id,location_id,location,profile_update,registered from master_table"];
    //NSLog(@"output=%@",excutedOutput);
    /*for (NSValue  *t in [(NSDictionary*) [excutedOutput objectAtIndex:0] allValues]) {
     //NSLog(@"object %@",t);
     if ([t isEqual:[NSNull null] ])
     {
     //NSLog(@"i caught null value");
     }
     }*/
    if ([excutedOutput count]==1){
        //[[self appDelegate] setXmpp];
        NSDictionary *rowElements=[excutedOutput objectAtIndex:0];
        [self appDelegate].MyUserName=[rowElements objectForKey:@"DISPLAY_NAME"];
        NSLog(@"USER NAME %@",[self appDelegate].MyUserName);
        
        [self appDelegate].myUserID=[rowElements objectForKey:@"LOGGED_IN_USER_ID"];
        NSString *username=[NSString stringWithFormat:@"user_%@",[rowElements objectForKey:@"LOGGED_IN_USER_ID"]];
        NSString *jid=[username stringByAppendingString:[NSString stringWithFormat:@"@%@",jabberUrl]];
        NSString *password=[NSString stringWithFormat:@"password_%@_user",[rowElements objectForKey:@"LOGGED_IN_USER_ID"]];
        NSString *userStatus=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"STATUS" ForRowIndex:0 givenOutput:excutedOutput];
        
        if ([userStatus isEqual:@"offline"]) {
            self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0];
            
            [[self appDelegate] goOffline ];
            
            
            
        }else if([userStatus isEqual:@"away"]){
            self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:240.0/255.0 blue:0.0/255.0 alpha:1.0];
            
            [[self appDelegate]goAway];
        }else if([userStatus isEqual:@"online"]){
            self.navigationItem.leftBarButtonItem.tintColor =[UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0] ;
            
            [[self appDelegate] goOnline];
        }
        
        NSString *unifier=[[rowElements objectForKey:@"SOCIAL_LOGIN"] isEqualToString:@"1"]?@"":[rowElements objectForKey:@"EMAIL"];
        //NSLog(@"username %@ PASSWORD %@ UNIFIER %@",username,password,unifier);
        defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:jid forKey:@"Jid"];
        [defaults setObject:password forKey:@"Password"];
        NSString *chatWallpaper;
        if ([[rowElements objectForKey:@"CHAT_WALL_PAPER"] isEqual:[NSNull null] ])
        {chatWallpaper=@"wallpaper.jpg";
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"UPDATE master_table SET chat_wall_paper='%@' WHERE id=1 ",chatWallpaper ]];
            
        }else{
            chatWallpaper=[rowElements objectForKey:@"CHAT_WALL_PAPER"];
        }
        
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"UPDATE master_table SET registered=1 WHERE id=1 "];
        [defaults synchronize];
        if ([[rowElements objectForKey:@"REGISTERED"] isEqual:[NSNull null]]||[[rowElements objectForKey:@"REGISTERED"] isEqual:@"0"]){
            BOOL reply= [[self appDelegate]registrationWithUserName:username password:password name:[rowElements objectForKey:@"DISPLAY_NAME"] emailid:unifier];
            if (reply)
            NSLog(@"registratration process starts");
            else
            
            NSLog(@"you cannot interrupt registratration ");
        }else{
            [[self appDelegate] connect];
        }
        
    }
    ////NSLog(@"%@ ,pass %@  for %@ %@",[defaults objectForKey:@"Jid"], [defaults objectForKey:@"Password"],jid,password);
    
}

-(void)handleUnsendFriendReuest{
    NSArray *userIDsData=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select user_id,user_name from contacts where blocked=0"];
    NSMutableArray *userIds=[[NSMutableArray alloc]init];
    NSMutableArray *userName=[[NSMutableArray alloc]init];
    for (int i=0; i<[userIDsData count]; i++){
        [userIds addObject:[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_ID" ForRowIndex:i givenOutput:userIDsData]];
        [userName addObject:[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_NAME" ForRowIndex:i givenOutput:userIDsData]];
        //[[[DatabaseManager  getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_ID" ForRowIndex:i givenOutput:userIDsData]]];
        //   [userName addObject:[[[DatabaseManager  getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"user_name" ForRowIndex:i givenOutput:userIDsData]]];
        
    }
    //NSLog(@"useerr_id %@ /n user_name %@ ",userIds,userName);
    for (int i=0; i<[userIds count]; i++){
        
        //NSLog(@"iq id %@ databade %@",[self appDelegate ].ArrayUsersIDs,[userIds objectAtIndex:i]);
        if (! [[self appDelegate ].ArrayUsersIDs containsObject:[userIds objectAtIndex:i]])
        {NSString *userId=[userIds objectAtIndex:i];
            NSString *user_name=[userName objectAtIndex:i];
            [[self appDelegate] addFriendWithJid:[[NSString stringWithFormat:@"user_%@@",userId] stringByAppendingString:(NSString*)jabberUrl ] nickName:user_name];
        }
    }
    
    //NSLog(@"array element %@\n ids %@",userIds,[self appDelegate].ArrayUsersIDs);
    
}
- (void)viewDidLoad{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genetareNotification:) name:@"newCommentNotification" object:nil];
   //
    [super viewDidLoad];
    [self plistSpooler];
    [self initialiseView];
    if (![type isEqual:@"forward"]){
        [self appDelegate]._chatDelegate=self;
        [self initiateChat];
    }
    receiversUserId=[[NSMutableArray alloc]init];
    receiversGroupId=[[NSMutableArray alloc]init];
    contactNames = [[NSMutableArray alloc]init];
    contactPics = [[NSMutableArray alloc]init];
    contactStatus = [[NSMutableArray alloc]init];
    contactIds = [[NSMutableArray alloc]init];
    lastMsgReceivedTime = [[NSMutableArray alloc]init];
    unreadMsg = [[NSMutableArray alloc]init];
    lastMessageType = [[NSMutableArray alloc]init];
    lastMsg = [[NSMutableArray alloc]init];
    muteNotify = [[NSMutableArray alloc]init];
    tempMuteNotify = [[NSMutableArray alloc]init];
    
    tempContactNames = [[NSMutableArray alloc]init];
    tempContactPics = [[NSMutableArray alloc]init];
    tempContactStatus = [[NSMutableArray alloc]init];
    tempLastMsgReceivedTime = [[NSMutableArray alloc]init];
    tempUnreadMsg = [[NSMutableArray alloc]init];
    tempContactIds = [[NSMutableArray alloc]init];
    tempLastMessageType = [[NSMutableArray alloc]init];
    tempLastMsg = [[NSMutableArray alloc]init];
    
    groupIds = [[NSMutableArray alloc]init];
    groupNames = [[NSMutableArray alloc]init];
    groupTypes = [[NSMutableArray alloc]init];
    groupMute = [[NSMutableArray alloc]init];
    groupRead = [[NSMutableArray alloc]init];
    groupFlag = [[NSMutableArray alloc]init];
    groupPics = [[NSMutableArray alloc]init];
    
    tempGroupIds = [[NSMutableArray alloc]init];
    tempGroupNames = [[NSMutableArray alloc]init];
    tempGroupTypes = [[NSMutableArray alloc]init];
    tempGroupMute = [[NSMutableArray alloc]init];
    tempGroupRead = [[NSMutableArray alloc]init];
    tempGroupPics = [[NSMutableArray alloc]init];
    tempGroupFlag = [[NSMutableArray alloc]init];
    
    statusOptions = [NSArray arrayWithObjects:@"Available", @"Busy", @"Invisible", nil];
    statusOptionsThumbnails = [NSArray arrayWithObjects:@"online", @"away", @"invisible", nil];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:UITextAttributeTextColor]];
    
    appUserId = [[DatabaseManager getSharedInstance]getAppUserID];
    BOOL ifExists=[[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"select * from groups_private"]];
    
    BOOL ifPublicExists=[[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"select * from groups_public"]];
    if (!ifExists && !ifPublicExists) {
        
         [self setActivityIndicator];
         [self freezerAnimate];
    }else{
        [self freezerAnimate];
        [NSTimer scheduledTimerWithTimeInterval:3.0
                                         target:self
                                       selector:@selector(stopLoader)
                                       userInfo:nil
                                        repeats:NO];
    }
    [self fetchContacts];
    [self setupSegmentController];
    for(UIView *subView in [search subviews]) {
        if([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)subView setReturnKeyType: UIReturnKeyDone];
        } else {
            for(UIView *subSubView in [subView subviews]) {
                if([subSubView conformsToProtocol:@protocol(UITextInputTraits)]) {
                    [(UITextField *)subSubView setReturnKeyType: UIReturnKeyDone];
                }
            }
        }
        
    }
}


-(void)generateNotifications:(NSString*)notification{
    // Schedule the notification
    localNotification= [[UILocalNotification alloc] init];
    [localNotification setShouldGroupAccessibilityChildren:YES];
    [localNotification setIsAccessibilityElement:YES];
    
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = notification;
    
    localNotification.alertAction = @"Show me the item";
    NSMutableDictionary *dedew=[[NSMutableDictionary alloc]init];
    [dedew setValue:@"hi" forKey:@"deepesh"];
    
    [localNotification setUserInfo:dedew];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"vibration"] boolValue]){
        NSLog(@"1?>>>> vibration");
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"sound"] boolValue]){
        NSLog(@"1?>>>> sound");
        localNotification.soundName=UILocalNotificationDefaultSoundName;
    }
    int badgenumber;
    badgenumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    if(!badgenumber)
        badgenumber = 0;
    localNotification.applicationIconBadgeNumber = badgenumber + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}



-(void)stopLoader{
    
    [HUD hide:YES];
}



-(IBAction)dissmisal:(UIButton*)sender1{
    
    [self.parentViewController.parentViewController.view setUserInteractionEnabled:YES];
    [sender1.superview removeFromSuperview];
}
-(void)plistSpooler{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AppData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: path]){
        
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        if (![[data objectForKey:@"HomeScreen"] boolValue]) {
            
            [data setObject:[NSNumber numberWithInt:true] forKey:@"HomeScreen"];
            CGSize deviceSize=[UIScreen mainScreen].bounds.size;
            UIImageView *Back=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            UIImage *backimage=[UIImage imageNamed:@"screens"];
            [Back setImage:[backimage stretchableImageWithLeftCapWidth:backimage.size.width topCapHeight:backimage.size.width/2]];
            [Back setUserInteractionEnabled:YES];
            UIButton *dismiss=[[UIButton alloc]initWithFrame:CGRectMake(deviceSize.width-110, 32, 100, 30)];
            [dismiss setTitle:@"Done" forState:UIControlStateNormal];
            [dismiss setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:178.0/255.0 blue:55.0/255.0 alpha:1 ]];
            [dismiss setUserInteractionEnabled:YES];
            [dismiss addTarget:self action:@selector(dissmisal:) forControlEvents:UIControlEventTouchUpInside];
            [Back addSubview:dismiss];
            [self.parentViewController.parentViewController.view addSubview:Back];
            [self.parentViewController.parentViewController.view bringSubviewToFront:Back ];
            
        }
        [data writeToFile: path atomically:YES];
        
    }else{
        
        data = [[NSMutableDictionary alloc] init];
        [data setObject:[NSNumber numberWithInt:true] forKey:@"IsSuccesfullRun"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"HomeScreen"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"CreateGroup"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"Location"];
        [data writeToFile: path atomically:YES];
        
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    if(recieveContactMsg==nil) {
        
        recieveContactMsg=[[UIImageView alloc]initWithFrame:CGRectMake(segControl.frame.origin.x-12,segControl.frame.origin.y-12, 24,24)];
        [recieveContactMsg setImage:[UIImage imageNamed:@"message"]];
        [self.view addSubview:recieveContactMsg];
        recieveGroupMsg=[[UIImageView alloc]initWithFrame:CGRectMake(segControl.frame.origin.x+225-12,segControl.frame.origin.y-12, 24,24)];
        [recieveGroupMsg setImage:[UIImage imageNamed:@"message"]];
        [self.view addSubview:recieveGroupMsg];
        [recieveContactMsg setHidden:1];
        [recieveGroupMsg setHidden:1];
        
    }
    if([self appDelegate].hasInet&&[[self xmppStream] isDisconnected]){
        
        [[self appDelegate]  connect];
        
    }
    
    [self fetchGroups];
    [groupsTable reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    search.showsCancelButton = NO;
    [search resignFirstResponder];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        
        [segControl setTintColor:[UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0]];
        search.barTintColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0];
        
    }else{
        
        [segControl setTintColor:[UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0]];
        search.tintColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0];
        
        
    }
    
    if (![type isEqual:@"forward"] && type){
        [self refreshChatList];
        [self refreshGroupList];
        [self appDelegate].currentUser=@"";
    }
}

-(void)initialiseView{
    
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    if ([type isEqual:@"forward"]){
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];//[UIColor
        [cancelButton addTarget:self action:@selector(CancelForward) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UIButton *forwardButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 70.0f, 30.0f)];
        [forwardButton setTitle:@"Forward" forState:UIControlStateNormal];//[UIColor
        [forwardButton addTarget:self action:@selector(forwardMessage) forControlEvents:UIControlEventTouchUpInside];
        [forwardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        forward = [[UIBarButtonItem alloc] initWithCustomView:forwardButton];
        
    }else{
        
        statusButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 40.0f, 30.0f)];
        [statusButton setImage:[UIImage imageNamed:@"online"] forState:UIControlStateNormal];//[UIColor greenColor]];
        [statusButton addTarget:self action:@selector(setStatus:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:statusButton];
        UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
        [backButton setTitle:@"Create" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(addGroup) forControlEvents:UIControlEventTouchUpInside];
        addButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        search.placeholder = @"Filter My Groups";
        
    }
    
}
-(void)CancelForward
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)forwardThisMessageToReceiver:(NSString*)recievers_id isItGroup:(NSString*)isgroup group_id:(NSString *)GID group_counter:(NSString *)GC time:(NSString*)timeInMiliseconds
{
    
    
    
    //    NSMutableDictionary *arrayTobePassed=[[NSMutableDictionary alloc]init];
    //    [arrayTobePassed setValue:[messageToBeForwarded stringByReplacingOccurrencesOfString:@"'" withString:@"''"] forKey:@"message"];
    //    [arrayTobePassed setValue:msgType forKey:@"message_type"];
    //    [arrayTobePassed setValue:@"" forKey:@"message_Id"];
    //    [arrayTobePassed setValue:@"" forKey:@"referenceID"];
    //    [arrayTobePassed setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid" ] forKey:@"senders_id"];
    //    [arrayTobePassed setValue:recievers_id forKey:@"recievers_id"];
    //    [arrayTobePassed setValue:isgroup forKey:@"isGroup"];
    //    [arrayTobePassed setValue:GID forKey:@"groupID"];
    //    [arrayTobePassed setValue:GC forKey:@"groupCounter"];
    //    [arrayTobePassed setValue:timeInMiliseconds  forKey:@"time_stamp" ];
    //    [arrayTobePassed setValue:@"0" forKey:@"isResending"];
    //
    //    [[self appDelegate] sendMessageWithMessageData:arrayTobePassed];
    
}



-(void)forwardMessage
{
    
    NSArray *master_table1=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select display_name,logged_in_user_id,chat_wall_paper from master_table"];
    for(int i=0;i<[receiversUserId count];i++)
    {
        
        NSString *chatWithUser=[NSString stringWithFormat:@"%@",[receiversUserId objectAtIndex:i]];
        
        /*  NSLog(@"msg %@",messageToBeForwarded);
         //send to server
         XMPPMessage *msg = [XMPPMessage message];
         [msg addAttributeWithName:@"type" stringValue:msgType];
         [msg addAttributeWithName:@"to" stringValue:chatWithUser];
         [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] ];
         //  NSData *data = [msgToSend dataUsingEncoding:NSNonLossyASCIIStringEncoding];
         
         //  NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         NSString *goodValue=[messageToBeForwarded UTFEncoded];
         NSLog(@"converted %@",goodValue);
         // NSString *dd =  [[NSString alloc] initWithData:[goodValue dataUsingEncoding:NSASCIIStringEncoding] encoding:NSNonLossyASCIIStringEncoding];
         
         NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:goodValue];
         
         goodValue =[goodValue UTFDecoded];
         NSLog(@"decoded %@",goodValue);
         [msg addChild:body];
         [[self xmppStream] sendElement:msg];
         
         */
        NSString *timeInMiliseconds = [[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
        NSString *msgToBesend=messageToBeForwarded;
        msgToBesend =[msgToBesend stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *goodValue=[msgToBesend UTFEncoded];
        NSString *groupID=@"";
        BOOL isThisGroupChat=false;
        NSString *recieversID=[NSString stringWithFormat:@"user_%@@%@",chatWithUser,jabberUrl];
        
        [[self appDelegate] storeMessageInDatabaseForBody:goodValue forMessageType:msgType messageTo:recieversID groupId:groupID isGroup:isThisGroupChat forTimeInterval:timeInMiliseconds senderName:[[master_table1 objectAtIndex:0] objectForKey:@"DISPLAY_NAME"] postid:nil isRead:nil];
        NSString *messageid=[[self appDelegate] CheckIfMessageExist:[goodValue stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
        //  NSString *recieversID=[chatWithUser userID];
        //  if([chatType isEqual:@"group"])
        //     recieversID=groupID;
        //  else
        //      recieversID=[jid userID];
        NSString *referanceID=  [[self appDelegate] getLinkedIdOfMessageID:messageid forTimestamp:timeInMiliseconds senderID:[self appDelegate].myUserID recieversID:chatWithUser chattype:@"personal"];
        [[self appDelegate] sendAcknoledgmentPacketId:referanceID isGroupAcknoledgment:isThisGroupChat];
        [self forwardThisMessageToReceiver:chatWithUser isItGroup:@"0" group_id:@"" group_counter:@""time:timeInMiliseconds];
        //   [sender sendMessageWithReceiversJid:chatWithUser message:messageToBeForwarded type:msgType groupId:@""];
        
    }
    for (int i=0; i<[receiversGroupId count]; i++)
    {
        NSString *chatWithUser=[NSString stringWithFormat:@"%@",[receiversGroupId objectAtIndex:i]];
        
        NSString *timeInMiliseconds=    [[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
        NSString *msgToBesend=messageToBeForwarded;
        msgToBesend =[msgToBesend stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *goodValue=[msgToBesend UTFEncoded];
        NSString *groupID=chatWithUser;
        BOOL isThisGroupChat=true;
        NSString *recieversID=[NSString stringWithFormat:@"user_%@@%@",chatWithUser,jabberUrl];
        [[self appDelegate] storeMessageInDatabaseForBody:goodValue forMessageType:msgType messageTo:recieversID groupId:groupID isGroup:isThisGroupChat forTimeInterval:timeInMiliseconds senderName:[[master_table1 objectAtIndex:0] objectForKey:@"DISPLAY_NAME"] postid:nil isRead:nil];
        NSString *messageid=[[self appDelegate] CheckIfMessageExist:[goodValue stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
        //  NSString *recieversID=[chatWithUser userID];
        //  if([chatType isEqual:@"group"])
        //     recieversID=groupID;
        //  else
        //      recieversID=[jid userID];
        NSString *referanceID=  [[self appDelegate] getLinkedIdOfMessageID:messageid forTimestamp:timeInMiliseconds senderID:[self appDelegate].myUserID recieversID:chatWithUser chattype:@"group"];
        [[self appDelegate] sendAcknoledgmentPacketId:referanceID isGroupAcknoledgment:isThisGroupChat];
        
//        NSArray *members=[self getMembersListGroupId:[[receiversGroupId objectAtIndex:i] integerValue]];
        NSArray *master_table=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select display_name,logged_in_user_id,chat_wall_paper from master_table"];
        NSDictionary *userDictonary = [master_table lastObject];
        for (NSString *groupid in receiversGroupId){
            
             NSArray *groupUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select chat_group.id,user_id,time_stamp,message_id,message_type,message_text,message_filename from chat_group INNER  JOIN chat_message where user_id=%@ AND group_id = %@ AND messageStatus=0 AND  message_id=chat_message.id order by chat_group.time_stamp ASC",[self appDelegate].myUserID,groupid]];
            XMPPMessage *msg = [XMPPMessage message];
            [msg addAttributeWithName:@"type" stringValue:@"groupchat"];
            [msg addAttributeWithName:@"groupCounter" stringValue:[self appDelegate].groupCounter];
            [msg addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"group_%@@%@",groupid,groupJabberUrl]];
            [msg addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"user_%@@%@",[self appDelegate].myUserID,jabberUrl]];
            [msg addAttributeWithName:@"isResend" boolValue:FALSE];
//            msgToBesend=[self RadhaCompatiableEncodingForstring:msgToBesend];
            NSString *goodValue1=[msgToBesend UTFEncoded];
            NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
            NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[goodValue1 stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]];
            
            NSXMLElement *reference = [NSXMLElement elementWithName:@"referenceID" stringValue:[[groupUnsendMessages objectAtIndex:0] objectForKey:@"CHAT_GROUP.ID"]];
            NSXMLElement *from_user_id = [NSXMLElement elementWithName:@"from_user_id" stringValue:[userDictonary objectForKey:@"LOGGED_IN_USER_ID"]];
            NSXMLElement *from_user_name = [NSXMLElement elementWithName:@"from_user_name" stringValue:[userDictonary objectForKey:@"DISPLAY_NAME"]];
            NSXMLElement *message_type = [NSXMLElement elementWithName:@"message_type" stringValue:msgType];
            NSXMLElement *timeStamp=[NSXMLElement elementWithName:@"TimeStamp" stringValue:[NSString stringWithFormat:@"%@",timeInMiliseconds]];
            NSXMLElement *groupIDs = [NSXMLElement elementWithName:@"groupID" stringValue:groupID ];
            NSXMLElement *isgroup= [NSXMLElement elementWithName:@"isgroup" stringValue:[NSString stringWithFormat:@"%i",true]];
            
            [gup addChild:body];
            [gup addChild:reference];
            [gup addChild:from_user_id];
            [gup addChild:from_user_name];
            [gup addChild:timeStamp];
            [gup addChild:message_type];
            [gup addChild:isgroup];
            [gup addChild:groupIDs];
            [msg addChild:gup];
            
            NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:[self getStringFromBody:gup andBody:[goodValue1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]]];
            [msg addChild:body1];
            if ([self appDelegate].hasInet&&[[self xmppStream] isDisconnected])
                [[self appDelegate] connect ];
            [[self xmppStream] sendElement:msg];
            
//            XMPPMessage *msg = [XMPPMessage message];
//            [msg addAttributeWithName:@"type" stringValue:@"groupchat"];
//            [msg addAttributeWithName:@"groupCounter" stringValue:[self appDelegate].groupCounter];
//            [msg addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"group_%@@%@",groupid,groupJabberUrl]];
//            [msg addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"user_%@@%@",[self appDelegate].myUserID,jabberUrl]];
//            [msg addAttributeWithName:@"isResend" boolValue:FALSE];
//            msgToBesend=[self RadhaCompatiableEncodingForstring:messageToBeForwarded];
//            NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
//            NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue :[msgToBesend stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
//            timeInMiliseconds = [[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] ;
//            NSXMLElement *from_user_id = [NSXMLElement elementWithName:@"from_user_id" stringValue:[userDictonary objectForKey:@"LOGGED_IN_USER_ID"]];
//            NSXMLElement *from_user_name = [NSXMLElement elementWithName:@"from_user_name" stringValue:[userDictonary objectForKey:@"DISPLAY_NAME"]];
//            NSXMLElement *message_type = [NSXMLElement elementWithName:@"message_type" stringValue:msgType ];
//            NSXMLElement *timeStamp=[NSXMLElement elementWithName:@"TimeStamp" stringValue:[NSString stringWithFormat:@"%@",timeInMiliseconds]];
//            NSXMLElement *groupIDs = [NSXMLElement elementWithName:@"groupID" stringValue:groupID ];
//            NSXMLElement *isgroup= [NSXMLElement elementWithName:@"isgroup" stringValue:[NSString stringWithFormat:@"%i",true]];
//            
//            [gup addChild:body];
//            [gup addChild:from_user_id];
//            [gup addChild:from_user_name];
//            [gup addChild:timeStamp];
//            [gup addChild:message_type];
//            [gup addChild:isgroup];
//            [gup addChild:groupIDs];
//            [msg addChild:gup];
//            NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:[self getStringFromBody:gup andBody:msgToBesend]];
//            [msg addChild:body1];
//            if ([self appDelegate].hasInet&&[[self xmppStream] isDisconnected])
//            [[self appDelegate] connect ];
//            [[self xmppStream] sendElement:msg];
//            NSString *chatWithUser=[NSString stringWithFormat:@"%@",[members objectAtIndex:j]];
//            [self forwardThisMessageToReceiver:chatWithUser isItGroup:@"1"  group_id:[receiversGroupId objectAtIndex:i] group_counter:[NSString stringWithFormat:@"%i",j] time:timeInMiliseconds] ;
//            [sender sendMessageWithReceiversJid:chatWithUser message:messageToBeForwarded type:msgType groupId:[[receiversGroupId objectAtIndex:i] userID]];
        }
    }
    //[sender newMessageReceived];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString*)RadhaCompatiableEncodingForstring:(NSString*)str{
    return [str stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
}

-(NSString*)getStringFromBody:(NSXMLElement*)gupElement andBody:(NSString*)body{
    
    NSString *returnString=[[NSString alloc]init];
    for (int i=0; i<[gupElement.children count]; i++){
        DDXMLNode *targetElement=[gupElement childAtIndex:i];
        returnString=[returnString stringByAppendingString:[NSString stringWithFormat:@"(%@)",targetElement.name]];
        if([targetElement.name isEqual:@"body"])
        returnString= [returnString stringByAppendingString:[NSString stringWithFormat:@"%@",body]];
        else
        returnString= [returnString stringByAppendingString:[NSString stringWithFormat:@"%@",targetElement.stringValue]];
        returnString= [returnString stringByAppendingString:[NSString stringWithFormat:@"(/%@)",targetElement.name]];
        
    }
    return[NSString stringWithFormat:@"(gup)%@(/gup)", returnString];
}

-(NSArray*)getMembersListGroupId:(int)GID{
    NSMutableArray *temparray;
    NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%i and deleted!=1",GID]];
    temparray=[[NSMutableArray alloc]init];
    for (int i=0; i<[tempmembersID count];i++){
        [temparray addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
    }
    return temparray;
}

-(IBAction)setStatus:(id)sender{
    
    
    
    
    [popover1 dismissPopoverAnimated:YES];
    //the view controller you want to present as popover
    UIViewController *controller = [[UIViewController alloc] init];
    statusTable = [[UITableView alloc]initWithFrame:CGRectMake(15, 52, 120, 120) style:UITableViewStyleGrouped];
    statusTable.backgroundColor=[UIColor clearColor];
    statusTable.delegate = self;
    statusTable.dataSource = self;
    controller.view=statusTable;
    controller.title = nil;
    //our popover
    popover1=[[UIPopoverController alloc] initWithContentViewController:controller];
    [popover1 setPopoverContentSize:CGSizeMake(self.view.frame.size.width-10, 150)];
    //[popover1 presentPopoverFromBarButtonItem:statusButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    CGRect rect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0);
    [popover1 presentPopoverFromRect:rect inView:self.view permittedArrowDirections:NO animated:NO];

}

-(void)addGroup{

    CreateGroup *addGroupPage = [[CreateGroup alloc]init];
//     CreateNewPost *addGroupPage = [[CreateNewPost alloc] init];
    [self.navigationController pushViewController:addGroupPage animated:YES];
}

-(void)setupSegmentController{
    //add viewcontrollers to the segment control
    [segControl addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    //[segControl setImage:[UIImage imageNamed:@"public"] forSegmentAtIndex:0];
    //[segControl setImage:[UIImage imageNamed:@"private"] forSegmentAtIndex:1];
    segControl.segmentedControlStyle = UISegmentedControlStyleBar;
    if ([[[self appDelegate].ver objectAtIndex:0] intValue] >= 7){
        [segControl setTitle:@"My Groups           " forSegmentAtIndex:0];
        [segControl setTitle:@"My Contacts         " forSegmentAtIndex:1];
    }else{
        [segControl setTitle:@"My Groups" forSegmentAtIndex:0];
        [segControl setTitle:@"My Contacts" forSegmentAtIndex:1];
    }
    [segControl setSelectedSegmentIndex:0];
    [self didChangeSegmentControl:segControl];
}



#pragma mark -
#pragma mark Segment control

- (void)didChangeSegmentControl:(UISegmentedControl *)control {
    
    NSString * segmentTitle = [control titleForSegmentAtIndex:control.selectedSegmentIndex];
    self.navigationItem.backBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:segmentTitle style:UIBarButtonItemStylePlain target:nil action:nil];
    [recieveContactMsg setHidden:TRUE];
    [recieveGroupMsg setHidden:TRUE];
    if (segControl.selectedSegmentIndex == 1){
        if ([type isEqual:@"forward"]){
            self.navigationItem.rightBarButtonItem = forward;
        }else{
            self.navigationItem.rightBarButtonItem = nil;
            search.placeholder = @"Filter My Contacts";
        }
        [self refreshChatList];
    }else{
        if ([type isEqual:@"forward"]){
            self.navigationItem.rightBarButtonItem = forward;
        }else{
            self.navigationItem.rightBarButtonItem = addButton;
            search.placeholder = @"Filter My Groups";
        }
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
        [self refreshGroupList];
    }
    
}


#pragma mark Table View Data Source Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
    
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView == groupsTable)
    return 1.0;
    else
    return 25.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView == groupsTable){
        if (segControl.selectedSegmentIndex == 0) {
            return [tempGroupIds count];
        }else{
            if([tempContactIds containsObject:[self appDelegate].myUserID]){
                NSInteger indexx = [tempContactIds indexOfObject:[self appDelegate].myUserID];
                [tempContactIds removeObjectAtIndex:indexx];
                [tempContactNames removeObjectAtIndex:indexx];
                [tempContactPics removeObjectAtIndex:indexx];
                [tempContactStatus removeObjectAtIndex:indexx];
                [tempLastMsgReceivedTime removeObjectAtIndex:indexx];
                [tempUnreadMsg removeObjectAtIndex:indexx];
                [tempLastMessageType removeObjectAtIndex:indexx];
                [tempLastMsg removeObjectAtIndex:indexx];
            }
            return [tempContactIds count];
        }
    }else{
        return 3;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(tableView == groupsTable)
    return @"";
    else
    return @"Status";
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == groupsTable) {
        static NSString *simpleTableIdentifier = @"SimpleTableItem";
        HomeTableCell *cell= (HomeTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        if (segControl.selectedSegmentIndex == 0) {
            if ([receiversGroupId count]!=0&&[receiversGroupId containsObject:[tempGroupIds objectAtIndex:indexPath.row]]){
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }else{
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            cell.nameLabel.text = [tempGroupNames objectAtIndex:indexPath.row];
            // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY FOR GROUPS
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",tempGroupPics[indexPath.row]]];
            //NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
            
            [cell.profileImageView hnk_setImageFromFile:imgPathRetrieve placeholder:[UIImage imageNamed:@"defaultGroup"] success:^(UIImage *image) {
                
                cell.profileImageView.image = image;
               
            } failure:^(NSError *error) {
                 cell.profileImageView.image=[UIImage imageNamed:@"defaultGroup"];
            }];
//            NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
//            UIImage *groupPic = [UIImage imageWithData:pngData];
//            if (groupPic) {
//                cell.profileImageView.image=groupPic;
//            }else{
//                cell.profileImageView.image=[UIImage imageNamed:@"defaultGroup"];
//            }
            if ([[tempGroupTypes objectAtIndex:indexPath.row] isEqualToString:@"private#local"]) {
                cell.status.image = [UIImage imageNamed:@"private_local"];
            }else if([[tempGroupTypes objectAtIndex:indexPath.row] isEqualToString:@"private#global"]){
                cell.status.image = [UIImage imageNamed:@"private_global"];
                
            }else if([[tempGroupTypes objectAtIndex:indexPath.row] isEqualToString:@"public#local"]){
                cell.status.image = [UIImage imageNamed:@"pin15"];
                
            }else if([[tempGroupTypes objectAtIndex:indexPath.row] isEqualToString:@"public#global"]){
                cell.status.image = [UIImage imageNamed:@"globe15"];
            }
            
            //            if ([[tempGroupRead objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
            int unreadCount=[[DatabaseManager getSharedInstance]countNoOfUnreadMsgs:[tempGroupIds objectAtIndex:indexPath.row] contactOrGroup:@"group"];
            if (unreadCount!=0){
                /*
                 *
                 unreade message counter munendra
                 *
                 */
                
//                cell.badgeLabel.text=[NSString stringWithFormat:@"%d",unreadCount];
//                cell.badgeLabel.layer.cornerRadius=7;
//                cell.badgeLabel.backgroundColor= [UIColor redColor];
                
            }
            //            }
            if ([[tempGroupMute objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
                cell.muteImageView.image =[UIImage imageNamed:@"mute"];
            }
            if ([[tempGroupFlag objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
                cell.detailLabel.text = @"Pending Approval!!!";
            }
            UILongPressGestureRecognizer *groupLpgr = [[UILongPressGestureRecognizer alloc]
                                                       initWithTarget:self action:@selector(handleLongPressForGroup:)];
            groupLpgr.minimumPressDuration = 0.5; //seconds
            [cell addGestureRecognizer:groupLpgr];
            
        }else if (segControl.selectedSegmentIndex == 1){
            if([receiversUserId count]!=0&&[receiversUserId containsObject:[tempContactIds objectAtIndex:indexPath.row]]){
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }else{
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            
            cell.nameLabel.text = [tempContactNames objectAtIndex:indexPath.row];
            // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",tempContactPics[indexPath.row]]];
            //NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
            NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
            UIImage *profilePic = [UIImage imageWithData:pngData];
            if (profilePic) {
                cell.profileImageView.image=profilePic;
            }else{
                cell.profileImageView.image=[UIImage imageNamed:@"defaultProfile"];
            }
            
            
            cell.timeLabel.text = [tempLastMsgReceivedTime objectAtIndex:indexPath.row];
            cell.status.image =[UIImage imageNamed:[tempContactStatus objectAtIndex:indexPath.row]];
            /*if ([[tempLastMessageType objectAtIndex:indexPath.row] isEqualToString:@"text"])
             {
             cell.msgLabel.text = [tempLastMsg objectAtIndex:indexPath.row];
             }
             else if ([[tempLastMessageType objectAtIndex:indexPath.row] isEqualToString:@"image"])
             {
             cell.msgLabel.text = @"Image";
             }
             else
             {
             cell.msgLabel.text = @"Audio";
             }*/
            
            if ([[tempUnreadMsg objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
                int unreadCount=[[DatabaseManager getSharedInstance]countNoOfUnreadMsgs:[tempContactIds objectAtIndex:indexPath.row] contactOrGroup:@"contact"];
                //NSLog(@"unread count %d",unreadCount);
                if (unreadCount!=0){
                    
                    /*
                     unreade counter munendra
                     */
//                    cell.badgeLabel.text=[NSString stringWithFormat:@"%d",unreadCount];
//                    cell.badgeLabel.layer.cornerRadius=7;
//                    cell.badgeLabel.backgroundColor= [UIColor redColor];
                    
                }
                
                //   cell.badgeLabel.text=[NSString stringWithFormat:@"%d",unreadCount];
                //    cell.badgeLabel.backgroundColor= [UIColor redColor];
                
            }
            if ([[tempMuteNotify objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
                cell.muteImageView.image =[UIImage imageNamed:@"mute"];
            }
            
            UILongPressGestureRecognizer *groupLpgr = [[UILongPressGestureRecognizer alloc]
                                                       initWithTarget:self action:@selector(handleLongPress:)];
            groupLpgr.minimumPressDuration = 0.5; //seconds
            
            //UITableViewCell *longPressedGroupCell=[tableView cellForRowAtIndexPath:indexPath];
            //int selectedCell = indexPath.row;
            [cell addGestureRecognizer:groupLpgr];
            
        }
        
        
        return cell;
    } else {
        static NSString *Identifier2 = @"CellType2";
        // cell type 2
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier2];
        }
        cell.backgroundColor=[UIColor clearColor];
        cell.imageView.image = [UIImage imageNamed:[statusOptionsThumbnails objectAtIndex:indexPath.row]];
        cell.textLabel.text = [statusOptions objectAtIndex:indexPath.row];
        //cell.backgroundColor=[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
        
        // set cell properties
        
        return cell;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == groupsTable)
    return 61;
    else
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == groupsTable) {
        [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                            style:UIBarButtonItemStyleBordered
                                            target:nil
                                            action:nil]];
        //NSLog(@"selected news at %d",indexPath.row);
        if (segControl.selectedSegmentIndex == 0) {
            /*  UILongPressGestureRecognizer *groupLpgr = [[UILongPressGestureRecognizer alloc]
             initWithTarget:self action:@selector(handleLongPressForGroup:)];
             groupLpgr.minimumPressDuration = 0.5; //seconds
             
             UITableViewCell *longPressedGroupCell=[tableView cellForRowAtIndexPath:indexPath];
             //int selectedCell = indexPath.row;
             [longPressedGroupCell addGestureRecognizer:groupLpgr];
             */
            if ([type isEqualToString:@"forward"]){
                if ([receiversGroupId containsObject:[tempGroupIds objectAtIndex:indexPath.row]]){
                    [receiversGroupId removeObject:[tempGroupIds objectAtIndex:indexPath.row]];
                }else{
                    [receiversGroupId addObject:[tempGroupIds objectAtIndex:indexPath.row]];
                }
                [groupsTable reloadData];
                
            }else{
                if ([[tempGroupFlag objectAtIndex:indexPath.row] isEqualToString:@"2"]) {
//                    ChatScreen *detailPage = [[ChatScreen alloc]init];
//                    detailPage.chatType = @"group";
//                    detailPage.toJid = [NSString stringWithFormat:@"group_%@@%@",[tempGroupIds objectAtIndex:indexPath.row],groupJabberUrl];
//                    //   [[[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
//                    detailPage.chatTitle=[tempGroupNames objectAtIndex:indexPath.row];
//                    [detailPage initWithUser:[NSString stringWithFormat:@"user_%d@%@",[[tempGroupIds objectAtIndex:indexPath.row] integerValue],(NSString*)jabberUrl]];
//                    // if (indexPath.row==0||indexPath.row==1||indexPath.row==3||indexPath.row==6) {
//                    detailPage.groupType=[tempGroupTypes objectAtIndex:indexPath.row];
                    ///  }
                    //  else
                    // {detailPage.groupType=@"public";
                    // }
                    PostListing *detailPage = [[PostListing alloc]init];
                    
//                    detailPage.toJid = [NSString stringWithFormat:@"group_%@@%@",[tempGroupIds objectAtIndex:indexPath.row],groupJabberUrl];
                    
                    //   [[[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
                    
                    detailPage.chatTitle=[tempGroupNames objectAtIndex:indexPath.row];
                    detailPage.groupId = [tempGroupIds objectAtIndex:indexPath.row];
                    detailPage.groupName = [tempGroupNames objectAtIndex:indexPath.row];
                    
                    //[detailPage initWithUser:[NSString stringWithFormat:@"user_%d@%@",[[tempGroupIds objectAtIndex:indexPath.row] integerValue],(NSString*)jabberUrl]];
                    
                    if (indexPath.row==0||indexPath.row==1||indexPath.row==3||indexPath.row==6) {
                        
                        detailPage.groupType=[tempGroupTypes objectAtIndex:indexPath.row];
                    
                    }else{
                       
                        detailPage.groupType=@"public";
                        
                    }

                    [self appDelegate].isUSER=0;
                    [self.navigationController pushViewController:detailPage animated:YES];
                }
            }
        }else if (segControl.selectedSegmentIndex == 1){
            
            if ([type isEqualToString:@"forward"]){
                if ([receiversUserId containsObject:[tempContactIds objectAtIndex:indexPath.row]]){
                    [receiversUserId removeObject:[tempContactIds objectAtIndex:indexPath.row]];
                }else{
                    [receiversUserId addObject:[tempContactIds objectAtIndex:indexPath.row]];
                }
                [groupsTable reloadData];
                
            }else{
                ChatScreen *detailPage = [[ChatScreen alloc]init];
                detailPage.chatType = @"personal";
                [self appDelegate].isUSER=1;
                detailPage.chatTitle=[tempContactNames objectAtIndex:indexPath.row];
                //NSLog(@"name %@",[tempContactNames objectAtIndex:indexPath.row]);
                [detailPage initWithUser:[[NSString stringWithFormat:@"user_%@@",[tempContactIds objectAtIndex:indexPath.row]] stringByAppendingString:(NSString*)jabberUrl ] ];
                [self.navigationController pushViewController:detailPage animated:YES];
            }
        }
        
    }else{
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
        NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
        [iqStanza addAttributeWithName: @"type" stringValue: @"get"];
        [iqStanza addChild: queryElement];
        [[self xmppStream] sendElement: iqStanza];
        [self performSelector:@selector(handleUnsendFriendReuest) withObject:Nil afterDelay:3];
        //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *selectedcell=[tableView cellForRowAtIndexPath:indexPath];
        selectedcell.accessoryType = UITableViewCellAccessoryCheckmark;
        status=[statusOptions objectAtIndex:indexPath.row];
        if(indexPath.row == 0){
            [statusButton setImage:[UIImage imageNamed:@"online"] forState:UIControlStateNormal];
            // self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"update master_table set status='online' where id=1"];
            [[self appDelegate] goOnline ];
        }else if(indexPath.row == 1){
            [statusButton setImage:[UIImage imageNamed:@"away"] forState:UIControlStateNormal];
            //self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:240.0/255.0 blue:0.0/255.0 alpha:1.0];
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"update master_table set status='away' where id=1"];
            [[self appDelegate]goAway];
        }else{
            [statusButton setImage:[UIImage imageNamed:@"offline"] forState:UIControlStateNormal];
            //   self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0];
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"update master_table set status='offline' where id=1"];
            [[self appDelegate] goOffline];
        }
        [popover1 dismissPopoverAnimated:YES];
    }
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}


- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}
// Handle Long Press in the cell
-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture{
    
    CGPoint location = [gesture locationInView:groupsTable];
    selectedIndexPath = [groupsTable indexPathForRowAtPoint: location];
    NSString *selectedIndividual = [tempContactNames objectAtIndex:selectedIndexPath.row];
    selectedContactId = [tempContactIds objectAtIndex:selectedIndexPath.row];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        DatabaseManager *getUserDetails;   //Get Profile Data From DATABASEMANAGER
        getUserDetails = [[DatabaseManager alloc] init];
        NSArray *getUserData = [[NSMutableArray alloc]init];
        getUserData = [getUserDetails getContactMuteAndBlockStatus:selectedContactId];
        NSString *other3=@"Delete User";
        other0 = @"View Profile";
        other2 = @"Block User";
        NSString *other4=@"Clear Chat History";
        NSString *other5=@"Report User";
        cancelTitle = @"Cancel";
        
        if ([getUserData[1] isEqualToString:@"1"]){
            other1 = @"Unmute Chat";
        }else{
            other1 = @"Mute Chat";
        }
        
        contactActionSheet = [[UIActionSheet alloc]
                              initWithTitle:@""
                              delegate:self
                              cancelButtonTitle:cancelTitle
                              destructiveButtonTitle:Nil
                              otherButtonTitles:other0, other1, other2, other3,other4,other5, nil];
        [contactActionSheet showFromTabBar:self.tabBarController.tabBar];
        
    }
}

// handle long press for group

-(void)handleLongPressForGroup:(UILongPressGestureRecognizer *)gesture{
    CGPoint location = [gesture locationInView:groupsTable];
    indexPath1 = [groupsTable indexPathForRowAtPoint: location];
    selectedGroup= [tempGroupIds objectAtIndex:indexPath1.row];
    selectedGroupType=[tempGroupTypes objectAtIndex:indexPath1.row];
    selectedGroupName=[tempGroupNames objectAtIndex:indexPath1.row];
    NSString *selectedGroupFlag = [tempGroupFlag objectAtIndex:indexPath1.row];
    if ([selectedGroupFlag isEqualToString:@"2"]) {
        if(gesture.state == UIGestureRecognizerStateBegan) {
            NSString *groupOption1;
            NSString *groupOption2 = @"Report Group";
            NSString *groupOption3 = @"Leave Group";
            NSString *groupOption4=@"Clear Chat History";
            NSString *groupOption5=@"View Group Info";
            cancelTitle = @"Cancel";
            
            if ([[tempGroupMute objectAtIndex:indexPath1.row] isEqualToString:@"1"]){
                groupOption1= @"Unmute Chat";
            }else{
                groupOption1= @"Mute Chat";
            }
            
            // check if the group is default public local group
            NSString *defaultPublicLocalGroupName= [[DatabaseManager getSharedInstance]getAppUserLocationName];
            defaultPublicLocalGroupName = [defaultPublicLocalGroupName stringByReplacingOccurrencesOfString:@","
                                                                                                 withString:@""];
            NSLog(@"default public group name: %@",defaultPublicLocalGroupName);
            if ([[tempGroupNames objectAtIndex:indexPath1.row] isEqualToString:[NSString stringWithFormat:@"GUP %@",defaultPublicLocalGroupName]]||[[tempGroupNames objectAtIndex:indexPath1.row] isEqualToString:[NSString stringWithFormat:@"%@ Chat",defaultPublicLocalGroupName]]) {
                groupActionSheet = [[UIActionSheet alloc]
                                    initWithTitle:@""
                                    delegate:self
                                    cancelButtonTitle:cancelTitle
                                    destructiveButtonTitle:Nil
                                    otherButtonTitles:groupOption5,groupOption1, groupOption2, groupOption4, nil];
                [groupActionSheet showFromTabBar:self.tabBarController.tabBar];
                
            }
            
            else{
                
                groupActionSheet = [[UIActionSheet alloc]
                                    initWithTitle:@""
                                    delegate:self
                                    cancelButtonTitle:cancelTitle
                                    destructiveButtonTitle:Nil
                                    otherButtonTitles:groupOption5,groupOption1, groupOption2, groupOption3,/*groupOption4,*/ nil];
                [groupActionSheet showFromTabBar:self.tabBarController.tabBar];
            }
            
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [actionSheet dismissWithClickedButtonIndex:0 animated:NO];
    if (actionSheet == groupActionSheet) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:@"Mute Chat"]) {
            
            NSString *query;
            if ([[tempGroupTypes objectAtIndex:indexPath1.row] isEqualToString:@"private#local"]||[[tempGroupTypes objectAtIndex:indexPath1.row] isEqualToString:@"private#global"])
            {
                query=[NSString stringWithFormat:@"UPDATE groups_private SET mute_notification=%d WHERE group_server_id=%@ ",1,selectedGroup];
            }
            else
            {
                query=[NSString stringWithFormat:@"UPDATE groups_public SET mute_notification=%d WHERE group_server_id=%@ ",1,selectedGroup];
            }
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            [self refreshGroupList];
            [groupsTable reloadData];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@&flag=%i",selectedGroup,[self appDelegate].myUserID,1];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/mute_group.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            muteConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [muteConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [muteConnection start];
            muteData = [[NSMutableData alloc] init];
            
        }
        if ([buttonTitle isEqualToString:@"Unmute Chat"]) {
            NSString *query;
            if ([[tempGroupTypes objectAtIndex:indexPath1.row] isEqualToString:@"private#local"]||[[tempGroupTypes objectAtIndex:indexPath1.row] isEqualToString:@"private#global"])
            {
                query=[NSString stringWithFormat:@"UPDATE groups_private SET mute_notification=%d WHERE group_server_id=%@ ",0,selectedGroup];
            }
            else
            {
                query=[NSString stringWithFormat:@"UPDATE groups_public SET mute_notification=%d WHERE group_server_id=%@ ",0,selectedGroup];
            }
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            [self refreshGroupList];
            [groupsTable reloadData];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@&flag=%i",selectedGroup,[self appDelegate].myUserID,0];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/mute_group.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            unmuteConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [unmuteConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [unmuteConnection start];
            unmuteData = [[NSMutableData alloc] init];
            
        }
        if ([buttonTitle isEqualToString:@"View Group Info"]) {
            int is_admin=[[DatabaseManager getSharedInstance]isAdminOrNot:selectedGroup contactId:appUserId];
            
            if (is_admin == 1) {
                
                viewPrivateGroup *viewGroupAsAdmin = [[viewPrivateGroup alloc]init];
                viewGroupAsAdmin.title = selectedGroupName;
                viewGroupAsAdmin.groupId = selectedGroup;
                viewGroupAsAdmin.groupType =selectedGroupType;
                [self.navigationController pushViewController:viewGroupAsAdmin animated:NO];
                
            }else{
                
                GroupInfo *viewGroupPage = [[GroupInfo alloc]init];
                viewGroupPage.title = selectedGroupName;
                viewGroupPage.groupId = selectedGroup;
                viewGroupPage.groupType = selectedGroupType;
                [self.navigationController pushViewController:viewGroupPage animated:NO];
                
            }
            
        }
        if ([buttonTitle isEqualToString:@"Leave Group"]) {
            if ([[tempGroupTypes objectAtIndex:indexPath1.row] isEqualToString:@"private#local"]|| [[tempGroupTypes objectAtIndex:indexPath1.row] isEqualToString:@"private#global"]){
                int adminCount=[[DatabaseManager getSharedInstance]countGroupAdmins:selectedGroup];
                if (adminCount == 1) {
                    int userId =[[[DatabaseManager getSharedInstance]getAppUserID] integerValue];
                    int adminId=[[DatabaseManager getSharedInstance]groupAdminId:selectedGroup];
                    if (adminId == userId) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Cannot Leave. There must be atleast one admin to manage the group."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                    }else{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to leave this group?"   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                        alert.tag=2;
                        [alert show];
                    }
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to leave this group?"   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                    alert.tag=2;
                    [alert show];
                }
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to leave this group?"   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                alert.tag=2;
                [alert show];
                
            }
            
            
            
        }
        if ([buttonTitle isEqualToString:@"Report Group"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to report this group?"   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.tag=3;
            [alert show];
            
            
        }
        if ([buttonTitle isEqualToString:@"Clear Chat History"]) {
            
            NSArray *messageIds=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select message_id,id  from  chat_group where group_id=%@",selectedGroup]] ;
            
            for (int i=0; i<[messageIds count]; i++) {
                NSInteger  msgId=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_ID" ForRowIndex:i givenOutput:messageIds]integerValue ];
                NSArray *outputGroup=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select COUNT(id)  from  chat_group where message_id=%i and group_id!=%@",msgId,selectedGroup]] ;
                NSInteger  noOfMessagesUsedInChat_group=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"COUNT(ID)" ForRowIndex:0 givenOutput:outputGroup] integerValue];
                NSArray *outputPersonal=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select COUNT(id)  from  chat_personal where message_id=%i ",msgId]];
                NSInteger  noOfMessagesUsedInChat_personal=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"COUNT(ID)" ForRowIndex:0 givenOutput:outputPersonal] integerValue];
                NSInteger noOfMessagesUsed=noOfMessagesUsedInChat_group+noOfMessagesUsedInChat_personal;
                if (noOfMessagesUsed ==0)
                {
                    NSArray *fileNames=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select message_filename from chat_message where id=%i",msgId]] ;
                    NSString  *fileName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_FILENAME" ForRowIndex:0 givenOutput:fileNames];
                    if (fileName != (id)[NSNull null]) {
                        [self removeFileNamed:fileName];
                    }
                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_message where id=%i",msgId]];
                    
                }
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_group where id=%@",[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"ID" ForRowIndex:i givenOutput:messageIds ]]];
                
            }
            
        }
        
        if ([buttonTitle isEqualToString:@"Cancel"]) {
        }
        
    }else if(actionSheet == contactActionSheet){
        
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:@"View Profile"]) {
            ViewContactProfile *viewContact = [[ViewContactProfile alloc]init];
            viewContact.userId=selectedContactId;
            [self.navigationController pushViewController:viewContact animated:YES];
            
        }
        if ([buttonTitle isEqualToString:@"Mute Chat"]) {
            
            
            NSString *query=[NSString stringWithFormat:@"UPDATE contacts SET mute_notification=%d WHERE user_id=%@ ",1,selectedContactId];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            HomeTableCell *selectedCell= (HomeTableCell *)[groupsTable cellForRowAtIndexPath:selectedIndexPath];
            selectedCell.muteImageView.image = [UIImage imageNamed:@"mute"];
            
        }
        if ([buttonTitle isEqualToString:@"Block User"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to block this user?"   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.tag=1;
            [alert show];
            
        }
        if ([buttonTitle isEqualToString:@"Unmute Chat"]) {
            NSString *query=[NSString stringWithFormat:@"UPDATE contacts SET mute_notification=%d WHERE user_id=%@ ",0,selectedContactId];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            HomeTableCell *selectedCell= (HomeTableCell *)[groupsTable cellForRowAtIndexPath:selectedIndexPath];
            selectedCell.muteImageView.image = [UIImage imageNamed:@""];
            
        }
        if ([buttonTitle isEqualToString:@"Delete User"]) {
            
            NSString *query=[NSString stringWithFormat:@"UPDATE contacts SET deleted=%d WHERE user_id=%@ ",1,selectedContactId];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            [self refreshChatList];
            
        }
        if ([buttonTitle isEqualToString:@"Clear Chat History"]) {
            
            NSArray *messageIds=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select message_id,id  from  chat_personal where user_id=%@ or receivers_id=%@",selectedContactId,selectedContactId]] ;
            
            for (int i=0; i<[messageIds count]; i++) {
                NSInteger  msgId=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_ID" ForRowIndex:i givenOutput:messageIds]integerValue ];
                NSArray *outputPersonal=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select COUNT(id)  from  chat_personal where message_id=%i and( user_id!=%@ or receivers_id!=%@ )",msgId,selectedContactId,selectedContactId]] ;
                NSArray *outputGroup=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select COUNT(id)  from  chat_group where message_id=%i ",msgId]];
                NSInteger  noOfMessagesUsedInChat_Group=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"COUNT(ID)" ForRowIndex:0 givenOutput:outputGroup] integerValue];
                NSInteger  noOfMessagesUsedInChat_personal=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"COUNT(ID)" ForRowIndex:0 givenOutput:outputPersonal] integerValue];
                NSInteger noOfMessagesUsed=noOfMessagesUsedInChat_Group+noOfMessagesUsedInChat_personal;
                if (noOfMessagesUsed ==1)
                {
                    NSArray *fileNames=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select message_filename from chat_message where id=%i",msgId]] ;
                    NSString  *fileName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_FILENAME" ForRowIndex:0 givenOutput:fileNames];
                    if (fileName != (id)[NSNull null]) {
                        [self removeFileNamed:fileName];
                    }
                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_message where id=%i",msgId]];
                    
                }
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_personal where id=%@",[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"ID" ForRowIndex:i givenOutput:messageIds ]]];
                
                
            }
            
            
        }
        
        if ([buttonTitle isEqualToString:@"Report User"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Report this User as inappropriate ?"   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.tag=33;
            [alert show];
            
            
        }
        
        
        if ([buttonTitle isEqualToString:@"Cancel"]) {
        }
        
    }
    
}
- (void)removeFileNamed:(NSString*)filename{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *filePathRetrieve =[[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",filename]];
    
    NSError *error = nil;
    if(![fileManager removeItemAtPath: filePathRetrieve error:&error]) {
    } else {
    }
    
}



//uialertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==66){
        if (buttonIndex==1){
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/resend_verify.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            NSMutableData *body = [NSMutableData data];
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%i",[globleData userID]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPBody:body];
            resendEmail = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [resendEmail scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [resendEmail start];
            resendEmailresponce = [[NSMutableData alloc] init];
            
        }
    }
    
    if (alertView.tag==1) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"user_id=%@&blocked_user_id=%@&block_status=%i",appUserId,selectedContactId,1];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/block_unblock_user.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            notifyBlockedUsersConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [notifyBlockedUsersConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [notifyBlockedUsersConn start];
            notifyBlockedUsersResponse = [[NSMutableData alloc] init];
        }
        
    }
    if (alertView.tag==2) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",selectedGroup,appUserId];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/leave_group.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            leaveGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [leaveGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [leaveGroupConn start];
            leaveGroupResponse = [[NSMutableData alloc] init];
        }
        
    }
    if (alertView.tag==3) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"user_id=%@&spammed_group_id=%@",appUserId,selectedGroup];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/spam_group.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            reportGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [reportGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [reportGroupConn start];
            reportGroupResponse = [[NSMutableData alloc] init];
        }
        
    }
    
    if (alertView.tag==77){
        
        [[self appDelegate] disconnect];
        [notifyBlockedUsersConn cancel];
        [reportGroupConn cancel];
        [leaveGroupConn cancel];
        [fetchContactsConn cancel];
        [fetchGroupsConn cancel];
        [[self appDelegate]pushLoginScreen];
    }
    if (alertView.tag==55){
        NSLog(@"login page alert 55 %@",alertView);
        if (buttonIndex==1){
            [[self appDelegate] goOffline ];
            [[self appDelegate]disconnect];
            [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
            [self setActivityIndicator];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/resend_verify.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            NSMutableData *body = [NSMutableData data];
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            
            //  parameter username
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]  dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPBody:body];
            resendEmail = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [resendEmail scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [resendEmail start];
            resendEmailresponce = [[NSMutableData alloc] init];
            
            NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"user_id=%@&deviceToken=%@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"Jid"] userID],[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]];
            [request1 setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/logout.php",gupappUrl]]];
            [request1 setHTTPMethod:@"POST"];
            [request1 setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request1 setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            LOGOUT = [[NSURLConnection alloc] initWithRequest:request1 delegate:self startImmediately:NO];
            [LOGOUT scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [LOGOUT start];
            LOGOUTRESPONSE = [[NSMutableData alloc] init];
            
        }
        if (buttonIndex==0) {
            
            [[self appDelegate] goOffline ];
            [[self appDelegate]disconnect];
            
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
            
            [[self appDelegate] setLoginView];
        }
    }
    if (alertView.tag==33) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData;
            postData = [NSString stringWithFormat:@"user_id=%@&spammed_user_id=%@",appUserId,selectedContactId];
            //NSLog(@"post data %@",postData);
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/spam_user.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            reportSpamConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [reportSpamConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [reportSpamConn start];
            reportSpamResponse = [[NSMutableData alloc] init];
        }
    }
}

-(void)setActivityIndicator{
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}



- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    searchBar.showsCancelButton=TRUE;
    
}


-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //NSLog(@"User searched for %@", searchText);
    
    
    if (segControl.selectedSegmentIndex == 1){
        
        if([searchBar.text length]==0){
            
            isFiltered = FALSE;
            [tempContactNames removeAllObjects];
            [tempContactPics removeAllObjects];
            [tempContactStatus removeAllObjects];
            [tempLastMsgReceivedTime removeAllObjects];
            [tempUnreadMsg removeAllObjects];
            [tempContactIds removeAllObjects];
            [tempLastMessageType removeAllObjects];
            [tempLastMsg removeAllObjects];
            
            [tempContactNames addObjectsFromArray:contactNames];
            [tempContactPics addObjectsFromArray:contactPics];
            [tempContactStatus addObjectsFromArray:contactStatus];
            [tempLastMsgReceivedTime addObjectsFromArray:lastMsgReceivedTime];
            [tempUnreadMsg addObjectsFromArray:unreadMsg];
            [tempContactIds addObjectsFromArray:contactIds];
            [tempLastMessageType addObjectsFromArray:lastMessageType];
            [tempLastMsg addObjectsFromArray:lastMsg];
            
        }else{
            
            isFiltered = TRUE;
            [tempContactNames removeAllObjects];
            [tempContactPics removeAllObjects];
            [tempContactStatus removeAllObjects];
            [tempLastMsgReceivedTime removeAllObjects];
            [tempUnreadMsg removeAllObjects];
            [tempContactIds removeAllObjects];
            [tempLastMessageType removeAllObjects];
            [tempLastMsg removeAllObjects];
            
            
            int i =0;
            for (NSString *string in contactNames) {
                NSRange r=[string rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if(r.location!=NSNotFound){
                    //[displayItems addObject:string];
                    [tempContactNames addObject:[contactNames objectAtIndex:i]];
                    [tempContactPics addObject:[contactPics objectAtIndex:i]];
                    [tempContactStatus addObject:[contactStatus objectAtIndex:i]];
                    [tempLastMsgReceivedTime addObject:[lastMsgReceivedTime objectAtIndex:i]];
                    [tempUnreadMsg addObject:[unreadMsg objectAtIndex:i]];
                    [tempContactIds addObject:[contactIds objectAtIndex:i]];
                    [tempLastMessageType addObject:[lastMessageType objectAtIndex:i]];
                    [tempLastMsg addObject:[lastMsg objectAtIndex:i]];
                    ////NSLog(@"search unread msg array: %@",tempUnreadMsg[i]);
                }
                i++;
            }
        }
        for (int j=0; j<tempUnreadMsg.count; j++) {
        }
        if (tempContactNames.count == 0){
            
            
        }
        
        [groupsTable reloadData];
    }else if (segControl.selectedSegmentIndex == 0){
        //NSLog(@"segment control");
        if([searchBar.text length]==0){
            
            isFiltered = FALSE;
            [tempGroupNames removeAllObjects];
            [tempGroupIds removeAllObjects];
            [tempGroupTypes removeAllObjects];
            [tempGroupMute removeAllObjects];
            [tempGroupRead removeAllObjects];
            [tempGroupFlag removeAllObjects];
            [tempGroupPics removeAllObjects];
            
            [tempGroupNames addObjectsFromArray:groupNames];
            [tempGroupIds addObjectsFromArray:groupIds];
            [tempGroupTypes addObjectsFromArray:groupTypes];
            [tempGroupMute addObjectsFromArray:groupMute];
            [tempGroupRead addObjectsFromArray:groupRead];
            [tempGroupFlag addObjectsFromArray:groupFlag];
            [tempGroupPics addObjectsFromArray:groupPics];
        }else{
            
            isFiltered = TRUE;
            [tempGroupNames removeAllObjects];
            [tempGroupIds removeAllObjects];
            [tempGroupTypes removeAllObjects];
            [tempGroupMute removeAllObjects];
            [tempGroupRead removeAllObjects];
            [tempGroupFlag removeAllObjects];
            [tempGroupPics removeAllObjects];
            
            int i =0;
            for (NSString *string in groupNames) {
                NSRange r=[string rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if(r.location!=NSNotFound){
                    
                    [tempGroupIds addObject:[groupIds objectAtIndex:i]];
                    [tempGroupNames addObject:[groupNames objectAtIndex:i]];
                    [tempGroupTypes addObject:[groupTypes objectAtIndex:i]];
                    [tempGroupMute addObject:[groupMute objectAtIndex:i]];
                    [tempGroupRead addObject:[groupRead objectAtIndex:i]];
                    [tempGroupFlag addObject:[groupFlag objectAtIndex:i]];
                    [tempGroupPics addObject:[groupPics objectAtIndex:i]];
                }
                i++;
            }
        }
        
        if (tempGroupIds.count == 0){
            
        }
        
        [groupsTable reloadData];
        
        
    }
    
    
}



- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    //NSLog(@"User canceled search");
    searchBar.showsCancelButton=FALSE;
    [searchBar resignFirstResponder];
}

-(void)refreshChatList{
    
    DatabaseManager *getContacts;
    getContacts= [[DatabaseManager alloc] init];
    getData = [[NSMutableArray alloc]init];
    getData =[getContacts getUsersData];
    [contactNames removeAllObjects];
    [contactPics removeAllObjects];
    [contactStatus removeAllObjects];
    [contactIds removeAllObjects];
    [lastMsgReceivedTime removeAllObjects];
    [lastMessageType removeAllObjects];
    [lastMsg removeAllObjects];
    [unreadMsg removeAllObjects];
    [muteNotify removeAllObjects];
    
    if([getData count]>0){
        for(int i=0;i<[getData count];i++){
            
            NSMutableArray *contacts = [getData objectAtIndex:i];
            [contactNames addObject:[contacts objectAtIndex:0]];
            [contactPics addObject:[contacts objectAtIndex:1]];
            [contactStatus addObject:[contacts objectAtIndex:2]];
            [contactIds addObject:[contacts objectAtIndex:3]];
            [lastMsgReceivedTime addObject:[contacts objectAtIndex:4]];
            [lastMessageType addObject:[contacts objectAtIndex:5]];
            [lastMsg addObject:[contacts objectAtIndex:6]];
            [unreadMsg addObject:[contacts objectAtIndex:7]];
            [muteNotify addObject:[contacts objectAtIndex:8]];
        }
        
    }
    
    [tempContactNames removeAllObjects];
    [tempContactPics removeAllObjects];
    [tempContactStatus removeAllObjects];
    [tempLastMsgReceivedTime removeAllObjects];
    [tempUnreadMsg removeAllObjects];
    [tempContactIds removeAllObjects];
    [tempLastMessageType removeAllObjects];
    [tempLastMsg removeAllObjects];
    [tempMuteNotify removeAllObjects];
    
    [tempContactNames addObjectsFromArray:contactNames];
    [tempContactPics addObjectsFromArray:contactPics];
    [tempContactStatus addObjectsFromArray:contactStatus];
    [tempLastMsgReceivedTime addObjectsFromArray:lastMsgReceivedTime];
    [tempUnreadMsg addObjectsFromArray:unreadMsg];
    [tempContactIds addObjectsFromArray:contactIds];
    [tempLastMessageType addObjectsFromArray:lastMessageType];
    [tempLastMsg addObjectsFromArray:lastMsg];
    [tempMuteNotify addObjectsFromArray:muteNotify];
    [groupsTable reloadData];
    
}


-(void)refreshGroupList{
    NSString *deleteQuery=[NSString stringWithFormat:@"delete from group_invitations where group_id in (select group_server_id from groups_private)"];
    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteQuery];
    NSMutableArray *getGroups = [[NSMutableArray alloc]init];
    getGroups = [[DatabaseManager getSharedInstance]getGroupsData];
    
    [groupIds removeAllObjects];
    [groupNames removeAllObjects];
    [groupTypes removeAllObjects];
    [groupMute removeAllObjects];
    [groupRead removeAllObjects];
    [groupFlag removeAllObjects];
    [groupPics removeAllObjects];
    
    if([getGroups count]>0){
        for(int i=0;i<[getGroups count];i++){
            
            NSMutableArray *groups = [getGroups objectAtIndex:i];
            [groupIds addObject:[groups objectAtIndex:0]];
            [groupPics addObject:[groups objectAtIndex:1]];
            [groupNames addObject:[groups objectAtIndex:2]];
            [groupTypes addObject:[groups objectAtIndex:3]];
            [groupMute addObject:[groups objectAtIndex:4]];
            [groupRead addObject:[groups objectAtIndex:5]];
            [groupFlag addObject:[groups objectAtIndex:6]];
            
        }
        
    }
    
    for (int i=0; i<groupIds.count; i++) {
        
    }
    [tempGroupIds removeAllObjects];
    [tempGroupNames removeAllObjects];
    [tempGroupTypes removeAllObjects];
    [tempGroupMute removeAllObjects];
    [tempGroupRead removeAllObjects];
    [tempGroupFlag removeAllObjects];
    [tempGroupPics removeAllObjects];
    
    [tempGroupIds addObjectsFromArray:groupIds];
    [tempGroupNames addObjectsFromArray:groupNames];
    [tempGroupTypes addObjectsFromArray:groupTypes];
    [tempGroupMute addObjectsFromArray:groupMute];
    [tempGroupRead addObjectsFromArray:groupRead];
    [tempGroupFlag addObjectsFromArray:groupFlag];
    [tempGroupPics addObjectsFromArray:groupPics];
    [groupsTable reloadData];
    //    if (segControl.selectedSegmentIndex == 0) {
    //        [recieveGroupMsg setHidden:FALSE];
    //        [recieveContactMsg setHidden:TRUE];
    //    }
    
    
}
-(void)newContactMessageRe{
    
    if (segControl.selectedSegmentIndex == 0) {
        [recieveGroupMsg setHidden:false];
        [recieveContactMsg setHidden:TRUE];
    }else{
        [self buddyStatusUpdated];
    }
}

-(void)newGroupMessageRe{
    
    if (segControl.selectedSegmentIndex == 1) {
        [recieveGroupMsg setHidden:TRUE];
        [recieveContactMsg setHidden:false];
    }else{
        //[self buddyStatusUpdated];
        
        [self refreshChatList];
        [self refreshGroupList];
    }
}
//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == notifyBlockedUsersConn) {
        
        [notifyBlockedUsersResponse setLength:0];
        
    }
    if (connection == reportGroupConn) {
        
        [reportGroupResponse setLength:0];
        
    }
    
    if (connection == leaveGroupConn) {
        
        [leaveGroupResponse setLength:0];
        
    }
    if (connection == fetchContactsConn) {
        
        [fetchContactsResponse setLength:0];
        
    }
    if (connection == fetchGroupsConn) {
        
        [fetchGroupsResponse setLength:0];
        
    }
    if (connection == reportSpamConn) {
        
        [reportSpamResponse setLength:0];
    }
    if (connection == LOGOUT) {
        [LOGOUTRESPONSE setLength:0];
    }
    if (connection==resendEmail) {
        [resendEmailresponce setLength:0];
    }
    if (connection==muteConnection) {
        [muteData setLength:0];
    }
    if (connection==unmuteConnection) {
        [unmuteData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    //NSLog(@"did recieve data");
    if (connection==resendEmail){
        [resendEmailresponce appendData:data];
    }
    if (connection == notifyBlockedUsersConn) {
        
        [notifyBlockedUsersResponse appendData:data];
        
    }
    if (connection == reportGroupConn) {
        
        [reportGroupResponse appendData:data];
        
    }
    if (connection == leaveGroupConn) {
        
        [leaveGroupResponse appendData:data];
        
    }
    if (connection == fetchContactsConn) {
        
        [fetchContactsResponse appendData:data];
        
    }
    if (connection == fetchGroupsConn) {
        
        [fetchGroupsResponse appendData:data];
        
    }
    if (connection == reportSpamConn) {
        
        
        [reportSpamResponse appendData:data];
    }
    //NSLog(@"did recieve data");
    if (connection == LOGOUT) {
        [LOGOUTRESPONSE appendData:data];
    }
    if (connection == muteConnection) {
        [muteData appendData:data];
    }
    if (connection == unmuteConnection) {
        [unmuteData appendData:data];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"%@",[error localizedDescription]);
    [HUD hide:YES];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //
    //    [alert show];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (connection==resendEmail){
        NSString *str = [[NSMutableString alloc] initWithData:resendEmailresponce encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
//        NSDictionary *responce= res[@"response"];
    }
    if (connection == LOGOUT){
        NSString *str = [[NSMutableString alloc] initWithData:LOGOUTRESPONSE encoding:NSASCIIStringEncoding];
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *responce= res[@"response"];
        
        BOOL   statusLogout= [responce[@"status"] boolValue];
        if (statusLogout){
            AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegateObj setLoginView];
        }
        [HUD hide:YES];
    }
    if (connection == notifyBlockedUsersConn) {
        
        NSString *str = [[NSMutableString alloc] initWithData:notifyBlockedUsersResponse encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *result = res[@"response"];
        NSString *blockStatus = result[@"status"];
        NSString *error=result[@"error"];
        [HUD hide:YES];
        if ([blockStatus isEqualToString:@"1"]){
            
            NSString *updateQuery=[NSString stringWithFormat:@"UPDATE contacts SET blocked=%d WHERE user_id=%@ ",1,selectedContactId];
            [[self appDelegate] removeFriendWithJid:[selectedContactId JID]];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateQuery];
            // [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            [self refreshChatList];
            NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
            [attributeDic setValue:@"chat" forKey:@"type"];
            [attributeDic setValue:[selectedContactId JID]forKey:@"to"];
            [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
            [attributeDic setValue:@"0" forKey:@"isResend"];
            NSString *body=[NSString stringWithFormat:@"you are blocked"];
            NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
            [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID] forKey:@"from_user_id"];
            [elementDic setValue:@"0" forKey:@"is_notify"];
            [elementDic setValue:@"text" forKey:@"message_type"];
            [elementDic setValue:@"1" forKey:@"contactDelete"];
            [elementDic setValue:@"0" forKey:@"contactUpdate"];
            [elementDic setValue:@"0" forKey:@"isgroup"];
            // [elementDic setValue:[NSString stringWithFormat:@"%@",selectedContactId ] forKey:@"contactID"];
            [elementDic setValue:body forKey:@"body"];
            
            [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];            //[groupsTable reloadData];
            // [[self xmppRoster]removeUser:[XMPPJID jidWithString:[selectedContactId JID]]];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
    if (connection == reportGroupConn) {
        
        NSString *str = [[NSMutableString alloc] initWithData:reportGroupResponse encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *result = res[@"response"];
        NSString *reportStatus = result[@"status"];
        NSString *error=result[@"error"];
        [HUD hide:YES];
        if ([reportStatus isEqualToString:@"0"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
    if(connection==reportSpamConn){
        NSString *str = [[NSMutableString alloc] initWithData:reportSpamResponse encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *responce= res[@"response"];
        NSString *reportStatus = responce[@"status"];
        NSString *error=responce[@"error"];
        [HUD hide:YES];
        if ([reportStatus isEqualToString:@"1"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }
    
    if(connection == leaveGroupConn) {
        
        NSString *str = [[NSMutableString alloc] initWithData:leaveGroupResponse encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *result = res[@"response"];
        NSString *leaveStatus = result[@"status"];
        NSString *error=result[@"Error"];
        [HUD hide:YES];
        if ([leaveStatus isEqualToString:@"0"]){
            NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@ and deleted!=1",selectedGroup]];
            NSMutableArray  *membersID=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempmembersID count];i++){
                
                [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
            }
            NSString *deleteQuery=[NSString stringWithFormat:@"delete from groups_private where group_server_id='%@'",selectedGroup];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteQuery];
            NSString *deletePublicQuery=[NSString stringWithFormat:@"delete from groups_public where group_server_id='%@'",selectedGroup];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deletePublicQuery];
            NSString *deleteGroupMembers=[NSString stringWithFormat:@"delete from group_members where group_id='%@'",selectedGroup];
           [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteGroupMembers];
            [membersID removeObject:[self appDelegate].myUserID];
            
            for (int j=0; j<[membersID count]; j++){
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                [attributeDic setValue:[[membersID objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                
                NSString *body=[NSString stringWithFormat:@" "];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"gupNotification"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                [elementDic setValue:@"0" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"isgroup"];
                [elementDic setValue:selectedGroup forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
                
            }
            
            XMPPPresence *presence = [XMPPPresence presence];
            [presence addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"group_%@@%@/user_%@",selectedGroup,groupJabberUrl,[self appDelegate].myUserID]];
            [presence addAttributeWithName:@"from" stringValue:[self appDelegate].myjid];
            [presence addAttributeWithName:@"type" stringValue:@"unavailable"];
            [[self appDelegate].xmppStream sendElement:presence];
            
            [self refreshGroupList];
            [[self appDelegate]clearChatHistoryForGroup:selectedGroup];
            [groupsTable reloadData];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
    
    if (connection == fetchContactsConn) {
        
        NSString *str = [[NSMutableString alloc] initWithData:fetchContactsResponse encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *response=res[@"response"];
        NSDictionary *contacts = response[@"users"];
        //[HUD hide:YES];
        NSLog(@"all contacts: %@", res);
        if ([contacts count]==0 ){
            
        }else{
            for (NSDictionary *result in contacts) {
                
                
                //                NSString *insertString = [NSString stringWithFormat:@"('%@','%@','%@','%@','%@','%@')",result[@"user_id"],result[@"email"],result[@"blocked"],[result[@"user_name"] normalizeDatabaseElement],result[@"profile_pic"],result[@"location_name"]];
                //                if ([finalString isEqualToString:@""]) {
                //                    finalString = [finalString stringByAppendingString:insertString];
                //                }else
                //                {
                //                    finalString = [finalString stringByAppendingString:[NSString stringWithFormat:@",%@",insertString]];
                //                }
                //
                //                NSLog(@"print the insert string: %@",finalString);
                
                NSString *checkIfExists=[NSString stringWithFormat:@"select * from contacts where user_id=%@",result[@"user_id"]];
                BOOL existOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfExists];
                if (existOrNot) {
                    NSString *updateContact=[NSString stringWithFormat:@"update  contacts set user_id = '%@', user_email = '%@', blocked = '%@', user_name ='%@', user_pic ='%@', user_location='%@' where user_id = '%@' ",result[@"user_id"],result[@"email"],result[@"blocked"],[result[@"user_name"] normalizeDatabaseElement],result[@"profile_pic"],result[@"location_name"],result[@"user_id"]];
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateContact];
                }else{
                    NSString *insertContact=[NSString stringWithFormat:@"insert into contacts (user_id, user_email, blocked, user_name, user_pic,user_location) values ('%@','%@','%@','%@','%@','%@')",result[@"user_id"],result[@"email"],result[@"blocked"],[result[@"user_name"] normalizeDatabaseElement],result[@"profile_pic"],result[@"location_name"]];
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertContact];
                }
                
                //download image and save in the cache
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,result[@"profile_pic"]]]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //cell.imageView.image = [UIImage imageWithData:imgData];
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                        NSString *contactPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",result[@"profile_pic"]]];
                        //Writing the image file
                        [imgData writeToFile:contactPicPath atomically:YES];
                    });
                });
            }
        }
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update master_table set contact_timestamp='%@'",response[@"timestamp"]]];
        
        [self refreshChatList];
        fetchContactsConn=nil;
        [fetchContactsConn cancel];
        if(fetchGroupsConn==nil){
            [self freezerRemove];
        }
    }
    if(connection == muteConnection){
        NSString *str = [[NSMutableString alloc] initWithData:muteData encoding:NSASCIIStringEncoding];
        NSLog(@"fetch groups Response:%@",str);
        //
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSString *status1 = [[res objectForKey:@"response"] objectForKey:@"status"];
        if([status1 intValue] == 1){
            NSLog(@"all groups: %@", res);
            NSLog(@"%.2f",(float)fetchGroupsResponse.length/1024.0f/1024.0f);
            [HUD hide:YES];
            
        }else{
            
        }
    }
    if(connection == unmuteConnection){
        NSString *str = [[NSMutableString alloc] initWithData:unmuteData encoding:NSASCIIStringEncoding];
        NSLog(@"fetch groups Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSString *status1 = [[res objectForKey:@"response"] objectForKey:@"status"];
        if([status1 intValue] == 1){
            NSLog(@"all groups: %@", res);
            NSLog(@"%.2f",(float)fetchGroupsResponse.length/1024.0f/1024.0f);
            [HUD hide:YES];
            
        }else{
            
        }
    }
    
    if (connection == fetchGroupsConn) {
        
        NSString *str = [[NSMutableString alloc] initWithData:fetchGroupsResponse encoding:NSASCIIStringEncoding];
        NSLog(@"fetch groups Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *group_list=res[@"group_list"];
        NSDictionary *groups = group_list[@"list"];
        NSDictionary *deletedGroups = group_list[@"deleted_group"];
        NSDictionary *pendingGroups = group_list[@"pending_groups"];
//        NSLog(@"all groups: %@", res);
//        NSLog(@"%.2f",(float)fetchGroupsResponse.length/1024.0f/1024.0f);
        [HUD hide:YES];
        if ([groups count]==0)
        {
            //NSLog(@"no groups to download");
        }else{
            
            for (NSDictionary *result in groups){
                
                //NSLog(@"group_id%@ \n name%@ \n type%@ \n bottom display%@ \n grouppic%@ \n group desc%@ \n createdOn%@ \n categoryIds%@ \n category name%@ \n groupmember%@ \n group join request%@\n ",result[@"id"],result[@"name"],result[@"type"],result[@"bottom_display"],result[@"group_pic"],result[@"group_description"],result[@"created_on"],result[@"category_id"],result[@"category_name"],result[@"group_member"],result[@"group_join_request"]);
//                NSLog(@"print group time stamp %@",result[@"g_timestamp"]);
                
                if ([result[@"g_timestamp"] doubleValue] > [groupTimeStampValue doubleValue]) {
                    
                    //download image and save in the cache
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,result[@"group_pic"]]]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //cell.imageView.image = [UIImage imageWithData:imgData];
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                            //NSLog(@"paths=%@",paths);
                            NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",result[@"group_pic"]]];
                            //NSLog(@"group pic path=%@",groupPicPath);
                            //Writing the image file
                            [imgData writeToFile:groupPicPath atomically:YES];
                            
                            
                        });
                        
                    });
                    
                }
                
                if ([result[@"type"] isEqualToString:@"private#local"]||[result[@"type"] isEqualToString:@"private#global"]) {
                    NSString *checkIfPrivateGroupExists=[NSString stringWithFormat:@"select * from groups_private where group_server_id=%@",result[@"id"]];
                    BOOL privateGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPrivateGroupExists];
                    if (privateGroupExistOrNot) {
                        
                        if ([result[@"g_timestamp"] doubleValue]> [groupTimeStampValue doubleValue]) {
                            NSString *updateGroup=[NSString stringWithFormat:@"update groups_private set group_server_id = '%@', created_on = '%@', created_by = '%@', group_name ='%@', group_pic ='%@', category_id='%@', category_name='%@', group_type='%@', total_members='%@', group_description='%@', group_join_request_count='%@',admin_id = '%@',group_member = '%@' where group_server_id = '%@' ",result[@"id"],result[@"created_on"], result[@"bottom_display"],[result[@"name"] normalizeDatabaseElement],result[@"group_pic"],result[@"category_id"],result[@"category_name"],result[@"type"],result[@"group_member"],[result[@"group_description"] normalizeDatabaseElement],result[@"group_join_request"],result[@"created_by"],result[@"member_details"],result[@"id"]];
                            //NSLog(@"query %@",updateGroup);
                            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateGroup];
                            
                        }else{
                            
                            [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat: @"update groups_private  set total_members='%@' ,group_join_request_count='%@' where group_server_id = '%@' ",result[@"group_member"],result[@"group_join_request"],result[@"id"] ]];
                        }
                    }else{
                        NSString *insertGroup=[NSString stringWithFormat:@"insert into groups_private (group_server_id, created_on, created_by, group_name, group_pic,category_id, category_name,group_type,total_members,group_description,group_join_request_count,admin_id,group_member) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",result[@"id"],result[@"created_on"], result[@"bottom_display"],[result[@"name"] normalizeDatabaseElement],result[@"group_pic"],result[@"category_id"],result[@"category_name"],result[@"type"],result[@"group_member"],[result[@"group_description"] normalizeDatabaseElement],result[@"group_join_request"],result[@"created_by"],result[@"member_details"]];
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertGroup];
                        //NSLog(@"query %@",insertGroup);
                        
                    }
                    
                    
                }else{
                    NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",result[@"id"]];
                    BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
                    if (publicGroupExistOrNot) {
                        if ([result[@"g_timestamp"] doubleValue]> [groupTimeStampValue doubleValue]) {
                            NSString *updatePublicGroup=[NSString stringWithFormat:@"update  groups_public set group_server_id = '%@', location_name = '%@', category_name = '%@', added_date ='%@', group_name ='%@', group_type='%@', group_pic='%@', group_description='%@', total_members='%@',admin_id='%@',group_member='%@' where group_server_id ='%@'",result[@"id"],result[@"bottom_display"],result[@"category_name"],result[@"created_on"],[result[@"name"] normalizeDatabaseElement],result[@"type"],result[@"group_pic"],[result[@"group_description"] normalizeDatabaseElement],result[@"group_member"],result[@"created_by"],result[@"member_details"],result[@"id"]];
                            //NSLog(@"query %@",updatePublicGroup);
                            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updatePublicGroup];
                            
                        }else{
                            [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat: @"update groups_public  set total_members='%@'  where group_server_id = '%@' ",result[@"group_member"],result[@"id"] ]];
                            
                        }
                        
                    }else{
                        
                        NSString *insertPublicGroup=[NSString stringWithFormat:@"insert into groups_public (group_server_id, location_name, category_name, added_date, group_name,group_type, group_pic,group_description,total_members,admin_id,group_member) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",result[@"id"],result[@"bottom_display"],result[@"category_name"],result[@"created_on"],[result[@"name"] normalizeDatabaseElement],result[@"type"],result[@"group_pic"],[result[@"group_description"] normalizeDatabaseElement],result[@"group_member"],result[@"created_by"],result[@"member_details"]];
                        //NSLog(@"query %@",insertPublicGroup);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertPublicGroup];
                        //                        ChatScreen *chatScreen = [[ChatScreen alloc]init];
                        //                        chatScreen.chatType = @"group";
                        //                        chatScreen.chatTitle=[result[@"name"] normalizeDatabaseElement];
                        //                        [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[result[@"id"] integerValue],(NSString*)jabberUrl]];
                        //
                        //                        chatScreen.groupType=result[@"type"] ;
                        //                        if ([chatScreen.chatHistory count]==0)
                        //                            [chatScreen retreiveHistory:nil];
                        //                        [self appDelegate].currentUser=@"";
                        
                    }
                    
                    
                }
                
                //                NSDictionary *memberDetails = result[@"member_details"];
                //                //NSLog(@"member details%@",memberDetails);
                //                if ([memberDetails count]==0 ){
                //                    //NSLog(@"no members");
                //                }else{
                //                    for (NSDictionary *member in memberDetails){
                //
                //                        //NSLog(@"user_id%@ \n profile_pic%@ \n location_name%@ \n is_admin%@ \n display_name%@",member[@"user_id"],member[@"profile_pic"],member[@"location_name"],member[@"is_admin"],member[@"display_name"]);
                //
                //
                //                        NSString *checkIfMemberExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@",result[@"id"],member[@"user_id"]];
                //                        BOOL memberExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberExists];
                //                        if (memberExistOrNot) {
                //                            NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set group_id = '%@', contact_id = '%@', is_admin = '%@', contact_name ='%@', contact_location ='%@', contact_image='%@',deleted=0 where group_id = '%@' and contact_id='%@' ",result[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] normalizeDatabaseElement],member[@"location_name"],member[@"profile_pic"],result[@"id"],member[@"user_id"]];
                //                            //NSLog(@"query %@",updateMembers);
                //                            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                //                        }else{
                //
                ////                            NSString *insertMembers=[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, is_admin, contact_name, contact_location,contact_image) values ('%@','%@','%@','%@','%@','%@')",result[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] normalizeDatabaseElement],member[@"location_name"],member[@"profile_pic"]];
                //                            //NSLog(@"query %@",insertMembers);
                ////                            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertMembers];
                //                        }
                //                        //download image and save in the cache
                //                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                //                            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,member[@"profile_pic"]]]];
                //
                //                            dispatch_async(dispatch_get_main_queue(), ^{
                //                                //cell.imageView.image = [UIImage imageWithData:imgData];
                //                                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                //                                //NSLog(@"paths=%@",paths);
                //                                NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",member[@"profile_pic"]]];
                //                                //NSLog(@"member pic path=%@",memberPicPath);
                //                                //Writing the image file
                //                                [imgData writeToFile:memberPicPath atomically:YES];
                //
                //
                //                            });
                //
                //                        });
                //
                //
                //                    }
                //                }
                
                NSDictionary *deletedMemberDetails = result[@"deleted_member_details"];
                if ([deletedMemberDetails count]==0 ){
                    //NSLog(@"no members");
                }else{
                    for (NSDictionary *members in deletedMemberDetails){
                        
                        //NSLog(@"user_id%@ \n profile_pic%@ \n location_name%@ \n is_admin%@ \n display_name%@",member[@"user_id"],member[@"profile_pic"],member[@"location_name"],member[@"is_admin"],member[@"display_name"]);
                        
                        
                        NSString *checkIfMemberExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@ ",result[@"id"],members[@"user_id"]];
                        BOOL memberExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberExists];
                        if (memberExistOrNot) {
                            NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set group_id = '%@', contact_id = '%@', is_admin = '%@', contact_name ='%@', contact_location ='%@', contact_image='%@' where group_id = '%@' and contact_id='%@' ",result[@"id"],members[@"user_id"],members[@"is_admin"],[members[@"display_name"] normalizeDatabaseElement],members[@"location_name"],members[@"profile_pic"],result[@"id"],members[@"user_id"]];
                            //NSLog(@"query %@",updateMembers);
                            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                        }else{
                            
                            //                            NSString *insertMembers=[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, is_admin, contact_name, contact_location,contact_image) values ('%@','%@','%@','%@','%@','%@')",result[@"id"],members[@"user_id"],members[@"is_admin"],[members[@"display_name"] normalizeDatabaseElement],members[@"location_name"],members[@"profile_pic"]];
                            //NSLog(@"query %@",insertMembers);
                            //                            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertMembers];
                        }
                        //download image and save in the cache
                        //                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        //                            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,members[@"profile_pic"]]]];
                        //
                        //                            dispatch_async(dispatch_get_main_queue(), ^{
                        //                                //cell.imageView.image = [UIImage imageWithData:imgData];
                        //                                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                        //                                //NSLog(@"paths=%@",paths);
                        //                                NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",members[@"profile_pic"]]];
                        //                                //NSLog(@"member pic path=%@",memberPicPath);
                        //                                //Writing the image file
                        //                                [imgData writeToFile:memberPicPath atomically:YES];
                        //
                        //
                        //                            });
                        //
                        //                        });
                        
                        
                    }
                }
                
                
                
                NSDictionary *deletedMembers = result[@"Deleted_members"];
                //NSLog(@"deleted members%@",deletedMembers);
                if ([deletedMembers count]==0 ){
                    //NSLog(@"no members");
                }else{
                    for (NSDictionary *deletedMember in deletedMembers){
                        //NSLog(@"deleted user id%@ \n",deletedMember);
                        /*
                         NSString *checkIfMemberToDeleteExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@",result[@"id"],deletedMember];
                         BOOL memberToDeleteExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberToDeleteExists];
                         if (memberToDeleteExistOrNot) {
                         NSString *deleteMemberQuery=[NSString stringWithFormat:@"delete from group_members where group_id=%@ and contact_id=%@ ",result[@"id"],deletedMember];
                         //NSLog(@"query %@",deleteMemberQuery);
                         [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteMemberQuery];
                         }*/
                        NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set deleted = 1 where group_id = '%@' and contact_id='%@' ",result[@"id"],deletedMember];
                        //NSLog(@"query %@",updateMembers);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                        
                    }
                }
                
            }
            if ([deletedGroups count]==0 )
            {
                //NSLog(@"no deleted groups");
            }else{
                for (NSDictionary *deletedGroup in deletedGroups){
                    //NSLog(@"deleted group id%@ \n",deletedGroup);
                    
                    NSString *deleteGroupPrivateQuery=[NSString stringWithFormat:@"delete from groups_private where group_server_id=%@",deletedGroup];
                    //NSLog(@"query %@",deleteGroupPrivateQuery);
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteGroupPrivateQuery];
                    NSString *deleteGroupPublicQuery=[NSString stringWithFormat:@"delete from groups_public where group_server_id=%@",deletedGroup];
                    //NSLog(@"query %@",deleteGroupPublicQuery);
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteGroupPublicQuery];
                    NSString *deleteGroupMembersQuery=[NSString stringWithFormat:@"delete from group_members where group_id=%@",deletedGroup];
                    
                    //NSLog(@"query %@",deleteGroupMembersQuery);
                    
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteGroupMembersQuery];
                }
            }
            if ([pendingGroups count]==0 )
            {
                //NSLog(@"no pending groups");
            }else{
                for (NSDictionary *pendingGroup in pendingGroups){
                    
                    //NSLog(@"group_id%@ \n name%@ \n type%@ \n group pic%@ \n",pendingGroup[@"group_id"],pendingGroup[@"group_name"],pendingGroup[@"group_type"],pendingGroup[@"profile_pic"]);
                    
                    NSString *checkIfGroupExists=[NSString stringWithFormat:@"select * from group_invitations where group_id=%@",pendingGroup[@"group_id"]];
                    BOOL groupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfGroupExists];
                    if (groupExistOrNot) {
                        NSString *updateGroup=[NSString stringWithFormat:@"update  group_invitations set group_id = '%@', group_name = '%@', group_pic = '%@', group_type ='%@' where group_id = '%@' ",pendingGroup[@"group_id"],[pendingGroup[@"group_name"]normalizeDatabaseElement],pendingGroup[@"profile_pic"],pendingGroup[@"group_type"],pendingGroup[@"group_id"]];
                        //NSLog(@"query %@",updateGroup);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateGroup];
                    }else{
                        
                        NSString *insertGroup=[NSString stringWithFormat:@"insert into group_invitations (group_id, group_name, group_pic, group_type) values ('%@','%@','%@','%@')",pendingGroup[@"group_id"],[pendingGroup[@"group_name"] normalizeDatabaseElement],pendingGroup[@"profile_pic"],pendingGroup[@"group_type"]];
                        //NSLog(@"query %@",insertGroup);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertGroup];
                    }
                    
                }
                
            }
            
            
        }
        
        //
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update master_table set group_timestamp='%@'",group_list[@"timestamp"]]];
        
        [self refreshGroupList];
        fetchGroupsConn=nil;
        
        [fetchGroupsConn cancel];
        if (fetchContactsConn==nil){
            [self freezerRemove];
        }
    }
    
}
// to fetch all the contacts and groups of the app user
-(void)fetchContacts{
    
    //    [self freezerAnimate];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSArray *groupArray = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_timestamp from master_table"]];
    NSString *contactTimeStampValue = [[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"CONTACT_TIMESTAMP" ForRowIndex:0 givenOutput:groupArray];
    NSString *postData = [NSString stringWithFormat:@"user_id=%@&contact_timestamp=%@",appUserId,contactTimeStampValue];
    NSLog(@"$[contacts%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/contact_list.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    fetchContactsConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [fetchContactsConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [fetchContactsConn start];
    fetchContactsResponse = [[NSMutableData alloc] init];
}
-(void)fetchGroups{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.timeoutInterval =50000.f;
    NSArray *groupArray = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select group_timestamp from master_table"]];
    groupTimeStampValue = [[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"GROUP_TIMESTAMP" ForRowIndex:0 givenOutput:groupArray];
//    groupTimeStampValue =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
    NSString *postData = [NSString stringWithFormat:@"user_id=%@&group_timestamp=%@",appUserId,groupTimeStampValue];
    NSLog(@"$[groups%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/member_group.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    fetchGroupsConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [fetchGroupsConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [fetchGroupsConn start];
    fetchGroupsResponse = [[NSMutableData alloc] init];
    
}


-(void)genetareNotification:(NSNotification*)notification{

    
    
}



@end
