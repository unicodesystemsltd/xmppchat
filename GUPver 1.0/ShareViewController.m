//
//  ShareViewController.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ShareViewController.h"
#import <Social/Social.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
static NSString *urlToBeShared=@"";

static NSString *ContentToBeShared=@"Found this cool new app called Gup for location based public and private group chats. Visit http://gupapp.com to download";//@"Found this cool new app called Gup where you can participate in one on one and public group chats. Check our for yourself";Found this cool new app called Gup where you can participate in one on one and public group chats and it's location based. Visit http://gupapp.com to download
static NSString *ImageToBeShared = @"Gup LOGO.png";
static NSString * const kClientId = @"1049791696445.apps.googleusercontent.com";

@interface ShareViewController ()

@end

@implementation ShareViewController
@synthesize signInButton,mc;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = NSLocalizedString(@"Share", @"Share");
        self.navigationItem.title = @"Invite Friends";
        //self.tabBarItem.image = [UIImage imageNamed:@"share"];
        UIImage *selectedImage = [UIImage imageNamed:@"share_blue"];
        UIImage *unselectedImage = [UIImage imageNamed:@"share"];
        [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}
-(void)tap{
    
    id<GPPNativeShareBuilder> shareBuilder= (id<GPPNativeShareBuilder>) [[GPPShare sharedInstance] nativeShareDialog];
    NSLog(@"basic data %@",ContentToBeShared);
    NSLog(@"share url %@",urlToBeShared);
    [shareBuilder setPrefillText:[NSString stringWithFormat:@"%@ \n \n  %@",ContentToBeShared,urlToBeShared]];
   // [shareBuilder attachImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",ImageToBeShared]]];
    [shareBuilder open];
    
}
- (void)viewDidLoad{
    
    [super viewDidLoad];
    isIpad= [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;

    // Do any additional setup after loading the view from its nib.
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGoogleUserID = YES;
    signIn.shouldFetchGooglePlusUser = YES;
    // signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    signIn.scopes = [NSArray arrayWithObjects: kGTLAuthScopePlusLogin, // defined in GTLPlusConstants.h
                     nil];
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    //[self refreshInterfaceBasedOnSignIn];
    [signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];

    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:UITextAttributeTextColor]];
    [self initialiseView];
}
-(void)refreshInterfaceBasedOnSignIn{
    
    if ([[GPPSignIn sharedInstance] authentication]) {
    
        [self tap];
        // The user is signed in.
        // self.signInButton.hidden = YES;
        // Perform other actions here, such as showing a sign-out button
        
    } else {
        //   self.signInButton.hidden = NO;
        // Perform other actions here
    }
}
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        // Do some error handling here.
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
    if (error) {
        // Do some error handling here.
    } else {
        //  _labelFirstName.text = [NSString stringWithFormat:@"Hello %@  ", signIn.authentication.userEmail];
        NSLog(@"user id  ==++= %@", signIn.userID);
        NSLog(@"google plus user ==++= %@", signIn.googlePlusUser);
        
        NSLog(@"user email  === %@", signIn.authentication.userEmail);
        
        [self refreshInterfaceBasedOnSignIn];
    }

}
- (void)finishedSharingWithError:(NSError *)error {
    if (!error) {
        NSLog(@"Shared succesfully");
    } else if(error.code == kGPPErrorShareboxCanceled) {
        NSLog(@"User cancelled share");
    } else {
        NSLog(@"Unknown share error: %@", [error localizedDescription]);
    }
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        
     //   self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:100.0/255.0 green:234.0/255.0 blue:224.0/255.0 alpha:1.0];
       [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor lightGrayColor]];
        
        
    }else{
        
     //   self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:100.0/255.0 green:234.0/255.0 blue:224.0/255.0 alpha:1.0];
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor lightGrayColor]];
        
        
    }
    
}

-(void)initialiseView
{
    
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    [shareTable setDelegate:self];
    [shareTable setDataSource:self];
}
#pragma Mailing delegates
- (void)showEmail
{
    @try {
        // Email Subject
        
        mc= [[MFMailComposeViewController alloc] init];
        if ([MFMailComposeViewController canSendMail])
        {mc.mailComposeDelegate = self;
            [mc setSubject:@"Check It Now"];
            [mc setMessageBody:[NSString stringWithFormat:@"%@ \n %@",ContentToBeShared,urlToBeShared] isHTML:NO];
            //  NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"%@",ImageToBeShared]]);
            //  [mc addAttachmentData:imageData mimeType:@"image/png" fileName:@"MyImageName"];
            
            //[mc setToRecipients:];
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
            //[self presentModalViewController:mc animated:YES];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"exception found %@",exception);
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
#pragma Messaging delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:Nil message:@"Failed to Send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    shareTable.userInteractionEnabled=YES;
}
- (void)showSMS:(NSString*)file {
    shareTable.userInteractionEnabled=NO;
    @try {
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:Nil message:@"Your Device doesn't Support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }
        else
        {
        // NSArray *recipents = @[@"12345678", @"72345524"];
        NSString *message = [NSString stringWithFormat:@" \n %@ \n %@",/* file,*/ContentToBeShared,urlToBeShared];
        
        messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        // [messageController setRecipients:recipents];
        [messageController setBody:message];
        
        // Present message view controller on screen
        [self presentViewController:messageController animated:YES completion:nil];
        }
        }
    @catch (NSException *exception)
    {
        NSLog(@"exception found %@",exception);
        }
  
}

#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return isIpad?1:2;
    if (section == 1)
        return isIpad?3:4;
    else
        return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0)
        return @"SEND VIA";
    else if(section == 1)
        return @"SHARE VIA";
    else
        return nil;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        if(indexPath.section == 0)
    {
        int customIndex=isIpad?indexPath.row+1 :indexPath.row;
        switch(customIndex) {
            case 0: // Initialize cell 1
          
            {
                cell.imageView.image = [UIImage imageNamed:@"sms"];
                cell.textLabel.text = @"SMS";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
               
            }
                 break;
                
            case 1: // Initialize cell 2
            {
                cell.imageView.image = [UIImage imageNamed:@"email"];
                cell.textLabel.text = @"Mail";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];            }
                break;
                
        }
        
    }
    else if(indexPath.section == 1)
    { int customIndex=indexPath.row!=0?isIpad?indexPath.row+1 :indexPath.row:0;
        switch(customIndex) {
            case 0: // Initialize cell 1
            {
                cell.imageView.image = [UIImage imageNamed:@"fb"];
                cell.textLabel.text = @"Facebook";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
                
                break;
            case 1: // Initialize cell 2
               
                {
                cell.imageView.image = [UIImage imageNamed:@"whatsapp"];
                cell.textLabel.text = @"WhatsApp";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                
            }
                break;
            case 2: // Initialize cell 3
            { signInButton=[[GPPSignInButton alloc]init];
                cell.imageView.image = [UIImage imageNamed:@"gplus"];
                cell.textLabel.text = @"Google+";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                
            }
                break;
            case 3: // Initialize cell 3
            {
                cell.imageView.image = [UIImage imageNamed:@"twitter"];
                cell.textLabel.text = @"Twitter";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                
            }
                break;
                
        }
    }
    
    else if(indexPath.section == 2)
    {
                cell.imageView.image = [UIImage imageNamed:@"rateReview"];
                cell.textLabel.text = @"Rate/Review Us";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
    }

    
    return cell;
    
    
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    { int customIndex=isIpad?indexPath.row+1 :indexPath.row;
        if (customIndex==0)
        {
            
            [self showSMS:ImageToBeShared];
            
        }
        else
        {//if ([MFMailComposeViewController canSendMail])
       
            [self showEmail];
       
        }
    }
   else if(indexPath.section==1)
    {int customIndex=indexPath.row!=0?isIpad?indexPath.row+1 :indexPath.row:0;
        if (customIndex==0)
        {
            SLComposeViewController *FacebookSheet = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeFacebook];

         //  if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook ])
        //{
            @try {
                
                
            [FacebookSheet setInitialText:ContentToBeShared];
            [FacebookSheet addURL:[NSURL URLWithString:urlToBeShared]];
            NSLog(@"website%@",urlToBeShared);
                FacebookSheet.editing=NO;
           // [FacebookSheet addImage:[UIImage imageNamed:ImageToBeShared]];
            [self.navigationController presentViewController:FacebookSheet animated:YES completion:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
                FacebookSheet.editing=NO;
                
            }];

            
            
//        }
  //      else
      //  {[self.navigationController presentViewController:FacebookSheet animated:NO completion:^{            [self.navigationController popToRootViewControllerAnimated:YES];
            
        //}];
            }
           
            @catch (NSException *exception) {
                                UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"%@",exception] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil ];
            [noti show];
            }
        
        
            
            
            
        }
        else if(customIndex==1){
            NSLog(@"%@",[self encodeImage]);
            NSURL *whatsappURL = [NSURL URLWithString:[self encodeURIComponent:[NSString stringWithFormat:@"whatsapp://send?text=%@\n%@",ContentToBeShared,urlToBeShared]]];
            NSLog(@"%@",whatsappURL);
            NSLog(@"%@",whatsappURL);
            if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
                [[UIApplication sharedApplication]openURL: whatsappURL];
          
            }
            else
            {UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Install Whatsapp on Your Phone" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil ];
                [noti show];
            }
         
        }
        else if (customIndex==2)
        {
            [signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
          //  if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter ])
            //{
             @try {
                SLComposeViewController *TwitterSheet = [SLComposeViewController
                                                         composeViewControllerForServiceType:SLServiceTypeTwitter];
                [TwitterSheet setInitialText:ContentToBeShared];
                [TwitterSheet addURL:[NSURL URLWithString:urlToBeShared]];
                NSLog(@"website%@",urlToBeShared);
           //     [TwitterSheet addImage:[UIImage imageNamed:ImageToBeShared]];
                [self presentViewController:TwitterSheet animated:YES completion:nil];
            }
            //else
          /*  {
                UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:@"Please make sure you are login to Twitter Account on your device" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil ];
                [noti show];
            }*/
                 @catch (NSException *exception) {
                     UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"%@",exception] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil ];
                     [noti show];
                 }


        }
    }
   else if(indexPath.section==2){
       NSString *appId = [[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] componentsSeparatedByString:@"."] lastObject];
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id863991482"]];
    }

   
}
- (NSString *)encodeURIComponent:(NSString *)string
{
    NSString *s = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return s;
}
-(NSString*)encodeImage
{NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:ImageToBeShared]);
    NSString *imageString = [NSString stringWithFormat:@"%@", [imageData base64Encoding]];
    NSLog(@"%@",imageString);
    return imageString;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
