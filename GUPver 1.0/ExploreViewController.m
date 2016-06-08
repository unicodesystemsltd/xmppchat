//
//  ExploreViewController.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/13/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "PostListing.h"
#import "ExploreViewController.h"
#import "SecondViewController.h"
#import "GroupInfo.h"
#import "JSON.h"
#import "GroupTableCell.h"
#import "ViewContactProfile.h"
#import "DatabaseManager.h"
#import "ChatScreen.h"
#import "viewPrivateGroup.h"
#import "AppDelegate.h"

@interface ExploreViewController ()

@end

@implementation ExploreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Search", @"Search");
        self.navigationItem.title = @"Explore Users and Groups";
        //[self.navigationController.navigationBar setTitleTextAttributes:         [NSDictionary dictionaryWithObjectsAndKeys:          [UIColor greenColor],          UITextAttributeTextColor,          nil]];
        //self.tabBarItem.image = [UIImage imageNamed:@"search"];
        UIImage *selectedImage = [UIImage imageNamed:@"search_blue"];
        UIImage *unselectedImage = [UIImage imageNamed:@"search"];
        [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
-(IBAction)dissmisal:(UIButton*)sender1
{//NSLog(@"sender %@",sender1);
    //NSLog(@"sender superview %@",sender1.superview);
    
    [self.parentViewController.parentViewController.view setUserInteractionEnabled:YES];
    [sender1.superview removeFromSuperview];
}
-(void)plistSpooler
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AppData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: path])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        //NSLog(@"data %@",data);
        if (![[data objectForKey:@"Explore"] boolValue]) {
            
            [data setObject:[NSNumber numberWithInt:true] forKey:@"Explore"];
            CGSize deviceSize=[UIScreen mainScreen].bounds.size;
            UIImageView *Back=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            UIImage *backimage=[UIImage imageNamed:@"quicksearch"];
            [Back setImage:[backimage stretchableImageWithLeftCapWidth:backimage.size.width topCapHeight:backimage.size.width]];
            //  [self.view addSubview:Back];
            //   [self.view sendSubviewToBack:Back];
            [Back setUserInteractionEnabled:YES];
            UIButton *dismiss=[[UIButton alloc]initWithFrame:CGRectMake(deviceSize.width-110, 32, 100, 30)];
            [dismiss setTitle:@"Done" forState:UIControlStateNormal];
            [dismiss setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:178.0/255.0 blue:55.0/255.0 alpha:1 ]];
            [dismiss setUserInteractionEnabled:YES];
            [dismiss addTarget:self action:@selector(dissmisal:) forControlEvents:UIControlEventTouchUpInside];
            // UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self                                                                                        action:@selector(dissmisal:)];
            
            // swipe.direction = UISwipeGestureRecognizerDirectionLeft;
            // [dismiss addGestureRecognizer:swipe];
            [Back addSubview:dismiss];
            
            //NSLog(@"self %@ \n back %@ \n backback %@ \n backbackback %@",self,self.parentViewController,self.parentViewController.parentViewController,self.parentViewController.parentViewController.parentViewController);
            //[self.parentViewController.parentViewController.view setUserInteractionEnabled:NO];
            [self.parentViewController.parentViewController.view addSubview:Back];
            [self.parentViewController.parentViewController.view bringSubviewToFront:Back ];
            
            //NSLog(@"hiii");
        }
        [data writeToFile: path atomically:YES];
        //NSLog(@"data %@",data);
        //NSLog(@"data %@",data);
    }
    else
    {
        
        data = [[NSMutableDictionary alloc] init];
        [data setObject:[NSNumber numberWithInt:true] forKey:@"IsSuccesfullRun"];
        // [data setObject:[NSNumber numberWithInt:false] forKey:@"ChatScreen"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"HomeScreen"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"CreateGroup"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"Location"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"Explore"];
        [data writeToFile: path atomically:YES];
        
        
    }

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self plistSpooler];
    // Do any additional setup after loading the view from its nib.
    searchVariable = 0;
    categoryThumbnails  = [[NSMutableArray alloc] init];
    categoryNames = [[NSMutableArray alloc] init];
    categoryGroupNo = [[NSMutableArray alloc] init];
    categoryIds = [[NSMutableArray alloc] init];
    
    textLabel = [[NSMutableArray alloc] init];
    detailTextLabel = [[NSMutableArray alloc] init];
    imageView = [[NSMutableArray alloc] init];
    tableType = [[NSMutableArray alloc] init];
    typeArray = [[NSMutableArray alloc] init];
    resultIdArray = [[NSMutableArray alloc] init];
    userEmailId = [[NSMutableArray alloc] init];
    userStatus = [[NSMutableArray alloc] init];
    
    tempTextLabel = [[NSMutableArray alloc] init];
    tempDetailTextLabel = [[NSMutableArray alloc] init];
    tempImageView = [[NSMutableArray alloc] init];
    tempTableType = [[NSMutableArray alloc] init];
    tempTypeArray = [[NSMutableArray alloc] init];
    tempResultIdArray = [[NSMutableArray alloc] init];
    tempUserEmailId = [[NSMutableArray alloc] init];
    tempUserStatus = [[NSMutableArray alloc] init];
    
    appUserId =[[DatabaseManager getSharedInstance]getAppUserID];
    
    userFilter=1;
    privateFilter=1;
    publicFilter=1;
    
    
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor],
      UITextAttributeTextColor , [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],UITextAttributeTextShadowOffset,
      
      nil]];
    //[self setActivityIndicator];
    //[self listCategories];
}
-(void)setActivityIndicator
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor lightGrayColor]];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        search.barTintColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0];
    }
    else{
        search.tintColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0];
    }
    search.autocorrectionType = UITextAutocorrectionTypeNo;
    if(searchVariable==0)
    {
        
        
        
        if (categoryNames.count == 0) {
            
            [self setActivityIndicator];
            
            [self listCategories];
            
        }
        
        [self fetchGroupCount];
        
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [search resignFirstResponder];
    search.showsCancelButton=FALSE;
    //self.navigationItem.rightBarButtonItem = nil;
}




#pragma mark Table View Data Source Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    NSLog(@"Table  initialized ");
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(searchVariable==0)
    {
        NSLog(@"count cat %lu",(unsigned long)[categoryNames count]);
        return [categoryNames count];
    }
    
    else
    {
        if (tableView== filterTable.tableView)
            return 3;
        else
            return [resultIdArray count];
    }
    
    
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{if(filterTable.tableView==tableView)
    if([[[self appDelegate].ver objectAtIndex:0] intValue] < 7)
        return 44;
    else
        return 0.5;
    else
        return 0.5;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
 
 if(searchVariable == 0)
 {
 return @"Browse Groups by Category";
 }
 else
 {
 return @"Lookup User or Group";
 }
 
 
 
 }*/


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if(searchVariable==0)
    {
        static NSString *CellIdentifier = @"Cell Identifier";
        //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            categoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 30, 30)];
            categoryImageView.tag=3;
            [cell.contentView addSubview:categoryImageView];
            categoryNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x+45, cell.frame.origin.y+7,225,30)];
            [categoryNameLabel setBackgroundColor:[UIColor clearColor]];
            [categoryNameLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            categoryNameLabel.tag=1;
            categoryNameLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
            [cell.contentView addSubview:categoryNameLabel];
            categoryGroups=[[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width-60, cell.frame.origin.y+7,50,30)];
            [categoryGroups setBackgroundColor:[UIColor clearColor]];
            categoryGroups.textAlignment =NSTextAlignmentRight;
            categoryGroups.tag=2;
            categoryGroups.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
            [cell.contentView addSubview:categoryGroups];
        }
        
        
        BOOL isrecommended=[[categoryIds objectAtIndex:indexPath.row] isEqual:@"1"];
        //imageview
        for (UIView *cellS in cell.contentView.subviews) {
            NSLog(@"oo%@",cellS);
            if (cellS.tag==3) {
                UIImageView *ima=(UIImageView*)cellS;
                [ima setImage:[UIImage imageNamed:@"category_thumbnail"]];
                if ([categoryImageData count]<indexPath.row+1 )
                {
                    //download image and save in the cache
                    
                    NSFileManager *filemgr = [NSFileManager defaultManager];
                    NSString *Filepath=[self CachesPath:categoryThumbnails[indexPath.row]];
                    if ([filemgr fileExistsAtPath: Filepath ] == YES)
                    {NSLog(@"its there");
                        [ima setImage:[UIImage imageWithContentsOfFile:Filepath]];
                    }
                    else
                    {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/category_pics/%@",gupappUrl,categoryThumbnails[indexPath.row]]]];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //cell.imageView.image = [UIImage imageWithData:imgData];
                                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                                NSLog(@"paths=%@",paths);
                                // NSString *categoryPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",categoryThumbnails[indexPath.row]]];
                                //   NSLog(@"category pic path=%@",categoryPicPath);
                                //Writing the image file
                                [imgData writeToFile:Filepath atomically:YES];
                                [ima setImage:[UIImage imageNamed:Filepath]];
                                [ExploreTableView reloadData];
                            });
                            //
                        });
                        
                    }
                    
                    //  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    //   NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",[categoryThumbnails objectAtIndex:indexPath.row]]];
                    //  NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
                    // ima.image = [UIImage imageWithData:pngData];
                }
                // else
                // ima.image = [UIImage imageWithData:[categoryImageData objectAtIndex:indexPath.row]];
                //[ima setHidden:isrecommended];
            }
            if (cellS.tag==1) {
                UILabel *catna=(UILabel*)cellS;
                catna.text=[categoryNames objectAtIndex:indexPath.row];
                if(isrecommended)
                {
                    [cell setBackgroundColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1]];
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1]];
                    [catna setBackgroundColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1]];
                    [catna setTextColor:[UIColor whiteColor]];
                    [catna setTextAlignment:NSTextAlignmentLeft];
                }
                else
                {
                    [cell setBackgroundColor:[UIColor whiteColor]];
                    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
                    [catna setBackgroundColor:[UIColor whiteColor]];
                    [catna setTextColor:[UIColor blackColor]];
                    [catna setTextAlignment:NSTextAlignmentLeft];
                }
            }
            if (cellS.tag==2) {
                UILabel *catgr=(UILabel*)cellS;
                NSLog(@"count %@",[categoryGroupNo objectAtIndex:indexPath.row]);
                catgr.text =[NSString stringWithFormat:@"%@",[categoryGroupNo objectAtIndex:indexPath.row]];
                [catgr setTextColor:isrecommended?[UIColor whiteColor]:[UIColor blackColor]];
            }
            
        }
        
        // [categoryImageView setImage:[UIImage imageNamed:@"category_thumbnail"]];
        
        //category name
        
        // categoryName.text =[categoryNames objectAtIndex:indexPath.row];
        
        
        //groups associated
        //  categoryGroups.text =[categoryGroupNo objectAtIndex:indexPath.row];
        
        
        //load images
        /*  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
         NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://gupapp.com/Gup_demo/scripts/media/images/category_pics/%@",categoryThumbnails[indexPath.row]]]];
         
         dispatch_async(dispatch_get_main_queue(), ^{
         
         categoryImageView.image = [UIImage imageWithData:imgData];
         
         
         });
         
         });*/
        return cell;
    }
    else
    {
        if (tableView== filterTable.tableView) {
            static NSString *Identifier2 = @"CellType2";
            // cell type 2
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier2];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier2];
            }
            filterOptionsList= [[NSMutableArray alloc]initWithObjects:@"Users",@"Private Groups",@"Public Groups", nil];
            cell.backgroundColor=[UIColor clearColor];
            cell.textLabel.text = [filterOptionsList objectAtIndex:indexPath.row];
            //cell.backgroundColor=[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            // set cell properties
            if (userFilter==1) {
                if (indexPath.row==0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                
            }
            
            if (privateFilter==1) {
                if (indexPath.row==1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                
            }
            if (publicFilter==1) {
                if (indexPath.row==2) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            
            
            
            return cell;
            
        }
        
        /*static NSString *Identifier2 = @"CellType2";
         // cell type 2
         UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier2];
         if (cell == nil) {
         
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier2];
         
         }
         
         cell.imageView.image = [UIImage imageNamed:@"lock"];
         cell.textLabel.text = @"US IT Professionals";
         cell.detailTextLabel.text =@"Created By: Admin";
         cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
         cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15.f];
         cell.detailTextLabel.textColor = [UIColor grayColor];
         [cell setAccessoryType: UITableViewCellAccessoryDetailButton];
         return cell;*/
        else
        {
            static NSString *simpleTableIdentifier = @"GroupTableCell";
            
            GroupTableCell *cell = (GroupTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupTableCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            else
            {
                cell=nil;
                
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupTableCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
                
            }
            //cell.imageView.layer.borderWidth=5.0f;
            
            
            UIImageView *iconImage= [[UIImageView alloc]initWithFrame:CGRectMake(18, 18, 18, 18)];
            //iconImage.image = [UIImage imageNamed:@"globe"];
            
            if ([[typeArray objectAtIndex:indexPath.row]isEqualToString:@"private#local"]){
                iconImage.image =[UIImage imageNamed:@"private_local"];
            }else if([[typeArray objectAtIndex:indexPath.row] isEqualToString:@"private#global"]){
                iconImage.image =[UIImage imageNamed:@"private_global"];
            }else if ([[typeArray objectAtIndex:indexPath.row]isEqualToString:@"public#local"]){
                iconImage.image =[UIImage imageNamed:@"pin15"];
            }else if ([[typeArray objectAtIndex:indexPath.row]isEqualToString:@"public#global"]){
                
                iconImage.image =[UIImage imageNamed:@"globe15"];
            }else{
                iconImage.image = [UIImage imageNamed:nil];
                //[iconImage removeFromSuperview];
            }
            [cell.imageView addSubview:iconImage];
            if ([[typeArray objectAtIndex:indexPath.row]isEqualToString:@"private#local"]||[[typeArray objectAtIndex:indexPath.row]isEqualToString:@"private#global"]||[[typeArray objectAtIndex:indexPath.row]isEqualToString:@"public#local"]||[[typeArray objectAtIndex:indexPath.row]isEqualToString:@"public#global"]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,imageView[indexPath.row]]]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imageView.image = [UIImage imageWithData:imgData];
                        
                        
                    });
                    
                });
                
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,imageView[indexPath.row]]]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imageView.image = [UIImage imageWithData:imgData];
                        
                        
                    });
                    
                });
                
            }
            
            
            
            cell.textLabel.text = [textLabel objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [detailTextLabel objectAtIndex:indexPath.row];
            if ( [[[self appDelegate].ver objectAtIndex:0] intValue] >= 7)
                [cell setAccessoryType: UITableViewCellAccessoryDetailButton];
            else
                [cell setAccessoryType: UITableViewCellAccessoryDetailDisclosureButton];
            // [cell setAccessoryType: UITableViewCellAccessoryDetailButton];
            return cell;
        }
    }
    
}
-(NSString *)CachesPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(searchVariable==0)
    {
        [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                                   initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
        SecondViewController *detailCategoryPage = [[SecondViewController alloc]init];
        detailCategoryPage.chatTitle = [categoryNames objectAtIndex:indexPath.row];
//        detailCategoryPage.tojid = 
        detailCategoryPage.categoryId = [categoryIds objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailCategoryPage animated:NO];
    } else{
        if (tableView== filterTable.tableView) {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(indexPath.row==0) {
                
                if(cell.accessoryType== UITableViewCellAccessoryCheckmark){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    userFilter=0;
                    
                }else{
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    userFilter=1;
                    
                    
                }
            }
            else if(indexPath.row==1){
                if (cell.accessoryType== UITableViewCellAccessoryCheckmark){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    privateFilter=0;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    privateFilter=1;
                    
                    
                }
                
            }else if(indexPath.row==2){
                if (cell.accessoryType== UITableViewCellAccessoryCheckmark){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    publicFilter=0;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    publicFilter=1;
                    
                    
                }
                
            }
            
            NSLog(@"printout private filter and public filter value %d, %d, %d",userFilter,privateFilter,publicFilter);
            
        }else{
            [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                                       initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
            if ([[tableType objectAtIndex:indexPath.row] isEqualToString:@"group"]) {
                NSString *userId =[[DatabaseManager getSharedInstance]getAppUserID];
                if ([[typeArray objectAtIndex:indexPath.row]isEqualToString:@"private#local"]||[[typeArray objectAtIndex:indexPath.row]isEqualToString:@"private#global"]) {
                    [self setActivityIndicator];
                    selectedGroupId= [resultIdArray objectAtIndex:indexPath.row];
                    selectedGroupName=[textLabel objectAtIndex:indexPath.row];
                    selectedGroupPic=[imageView objectAtIndex:indexPath.row];
                    selectedGroupType=[typeArray objectAtIndex:indexPath.row];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",selectedGroupId,userId];
                    NSLog(@"postdata%@",postData);
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/private_grp_user_status.php",gupappUrl]]];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                    initiateGroupJoinConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                    [initiateGroupJoinConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [initiateGroupJoinConn start];
                    initiateGroupJoinResponse = [[NSMutableData alloc] init];
                    
                }else{
                    //check whter group is already added
                    selectedGroupId= [resultIdArray objectAtIndex:indexPath.row];
                    NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",selectedGroupId];
                    BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
                    if (!publicGroupExistOrNot) {
                        [self setActivityIndicator];
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                        NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",selectedGroupId,userId];
                        NSLog(@"postdata%@",postData);
                        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_fav.php",gupappUrl]]];
                        [request setHTTPMethod:@"POST"];
                        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                        addFavGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                        [addFavGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                        [addFavGroupConn start];
                        addFavGroupResponse = [[NSMutableData alloc] init];
                        
                    }else{
//                        ChatScreen *chatScreen = [[ChatScreen alloc]init];
//                        chatScreen.chatType = @"group";
//                        chatScreen.chatTitle=[textLabel objectAtIndex:indexPath.row];
//                        chatScreen.toJid =[NSString stringWithFormat:@"group_%d@%@",[selectedGroupId integerValue],(NSString*)groupJabberUrl];
//                        [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[selectedGroupId integerValue],(NSString*)jabberUrl]];
//                        chatScreen.groupType=[typeArray objectAtIndex:indexPath.row];
//                        [self.navigationController pushViewController:chatScreen animated:YES];
                        
                        
                        PostListing *detailPage = [[PostListing alloc]init];
                        detailPage.chatTitle=[textLabel objectAtIndex:indexPath.row];
                        detailPage.groupId = selectedGroupId;
                        detailPage.groupName = [textLabel objectAtIndex:indexPath.row];
                        detailPage.groupType=[typeArray objectAtIndex:indexPath.row];
                        [self appDelegate].isUSER=0;
                        [self.navigationController pushViewController:detailPage animated:YES];

                        
                    }
                }
            }else{
                NSString *userId =[[DatabaseManager getSharedInstance]getAppUserID];
                selectedContactId=[resultIdArray objectAtIndex:indexPath.row];
                if (![[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"select user_email from contacts where user_id=%@",selectedContactId]]) {
                    [self setActivityIndicator];
                    
                    selectedContactEmail=[userEmailId objectAtIndex:indexPath.row];
                    selectedContactName=[textLabel objectAtIndex:indexPath.row];
                    selectedContactPic=[imageView objectAtIndex:indexPath.row];
                    selectedContactStatus=[userStatus objectAtIndex:indexPath.row];
                    selectedContactLocation=[detailTextLabel objectAtIndex:indexPath.row];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    NSString *postData = [NSString stringWithFormat:@"user_id=%@&contact_id=%@",userId,selectedContactId];
                    NSLog(@"postdata%@",postData);
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_to_contact.php",gupappUrl]]];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                    addContactConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                    [addContactConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [addContactConn start];
                    addContactResponse = [[NSMutableData alloc] init];
                    
                }else{
                    
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update contacts set deleted=0 where user_id=%@",selectedContactId]];
                    NSLog(@"open the chat screen here..");
                    ChatScreen *chatScreen = [[ChatScreen alloc]init];
                    chatScreen.chatType = @"personal";
                    chatScreen.chatTitle=[textLabel objectAtIndex:indexPath.row];
                    [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[selectedContactId integerValue],(NSString*)jabberUrl]];
                    chatScreen.groupType=@"";
                    [self.navigationController pushViewController:chatScreen animated:YES];
                    
                }
                
            }
        }
        
    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if(searchVariable==1)
    {
        if ([[tableType objectAtIndex:indexPath.row] isEqualToString:@"group"]) {
            // check whether the user is the admin of the group.
            
            
            NSLog(@"group id check:%@ userid:%@",[resultIdArray objectAtIndex:indexPath.row],appUserId);
            int is_admin=[[DatabaseManager getSharedInstance]isAdminOrNot:[resultIdArray objectAtIndex:indexPath.row] contactId:appUserId];
            NSLog(@"is_admin%i",is_admin);
            if (is_admin == 1) {
                viewPrivateGroup *viewGroupAsAdmin = [[viewPrivateGroup alloc]init];
                viewGroupAsAdmin.title = [textLabel objectAtIndex:indexPath.row];
                viewGroupAsAdmin.groupId = [resultIdArray objectAtIndex:indexPath.row];
                viewGroupAsAdmin.groupType =[typeArray objectAtIndex:indexPath.row];
                viewGroupAsAdmin.viewType = @"Explore";
                [self.navigationController pushViewController:viewGroupAsAdmin animated:NO];
            }
            else
            {
                
                GroupInfo *viewGroupPage = [[GroupInfo alloc]init];
                viewGroupPage.title = [textLabel objectAtIndex:indexPath.row];
                viewGroupPage.groupId = [resultIdArray objectAtIndex:indexPath.row];
                viewGroupPage.groupType = [typeArray objectAtIndex:indexPath.row];
                viewGroupPage.viewType = @"Explore";
                [self.navigationController pushViewController:viewGroupPage animated:NO];
                
            }
        }
        else
        {
            NSLog(@"in else for user");
            ViewContactProfile *viewContactPage = [[ViewContactProfile alloc]init];
            viewContactPage.triggeredFrom = @"explore";
            viewContactPage.userId=[resultIdArray objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:viewContactPage animated:NO];
            
        }
        
    }
    
    
}


// search bar delegates

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton=FALSE;
    [self handleSearch:searchBar];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton=TRUE;
    //[ExploreTableView reloadData];
    
    //searchVariable =5;
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //[self handleSearch:searchBar];
}

- (void)handleSearch:(UISearchBar *)searchBar {
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Searching....Please Wait !";
    
    NSLog(@"User searched for %@", searchBar.text);
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
    [self clearArrays:@"array"];
    
    [self clearArrays:@"temp"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *searchText=[NSString stringWithFormat:@"%@",searchBar.text];
    NSString *postData = [NSString stringWithFormat:@"search_data=%@&user_id=%@",searchText,appUserId];
    NSLog(@"request %@",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/search_group_user.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //set post data of request
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    //initialize a connection from request
    searchConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [searchConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [searchConn start];
    
    searchResponse = [[NSMutableData alloc] init];
    //searchVariable =1;
    //[ExploreTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    searchBar.showsCancelButton=FALSE;
    [searchBar resignFirstResponder];// if you want the keyboard to go away
    searchVariable =0;
    [ExploreTableView reloadData];
    groupByCategoryLabel.text=@"BROWSE GROUPS BY CATEGORY";
    groupByCategoryLabel.textColor=[UIColor lightGrayColor];
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)listCategories
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"user_id=%@",appUserId];
    NSLog(@"request %@",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/fetch_category_update.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //set post data of request
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    fetchLocationConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [fetchLocationConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [fetchLocationConn start];
    fetchLocationResponse = [[NSMutableData alloc] init];
}
-(void)fetchGroupCount
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"user_id=%@",appUserId];
    NSLog(@"request %@",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/fetch_category_update.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //set post data of request
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    groupCountConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [groupCountConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [groupCountConn start];
    groupCountResponse = [[NSMutableData alloc] init];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == fetchLocationConn) {
        [fetchLocationResponse setLength:0];
    }
    if (connection == searchConn) {
        [searchResponse setLength:0];
    }
    if (connection == addContactConn) {
        [addContactResponse setLength:0];
    }
    if (connection == initiateGroupJoinConn) {
        [initiateGroupJoinResponse setLength:0];
    }
    if (connection == addGroupConn) {
        [addGroupResponse setLength:0];
    }
    if (connection == addFavGroupConn) {
        [addFavGroupResponse setLength:0];
    }
    if (connection == groupCountConn) {
        [groupCountResponse setLength:0];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did recieve data");
    if (connection == fetchLocationConn) {
        [fetchLocationResponse appendData:data];
    }
    if (connection == searchConn) {
        [searchResponse appendData:data];
    }
    if (connection == addContactConn) {
        [addContactResponse appendData:data];
    }
    if (connection == initiateGroupJoinConn) {
        [initiateGroupJoinResponse appendData:data];
    }
    if (connection == addGroupConn) {
        [addGroupResponse appendData:data];
    }
    if (connection == addFavGroupConn) {
        [addFavGroupResponse appendData:data];
    }
    if (connection == groupCountConn) {
        [groupCountResponse appendData:data];
    }
    
    
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [HUD hide:YES];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@" finished loading");
    if (connection == fetchLocationConn) {
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:fetchLocationResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSArray *results = res[@"category_list"];
        if ([results count]==0 )
        {
            [HUD hide:YES];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                   
                                                             message:@"No categories present."
                                   
                                                            delegate:nil
                                   
                                                   cancelButtonTitle:@"OK"
                                   
                                                   otherButtonTitles:nil];
            [alert show];
        }
        else{
            NSLog(@"====EVENTS==3 %@",res);
            [categoryIds removeAllObjects];
            [categoryThumbnails removeAllObjects];
            [categoryNames removeAllObjects];
            [categoryGroupNo removeAllObjects];
            
            for (NSDictionary *result in results) {
                
                NSString *categoryId = result[@"category_id"];
                NSString *categoryName = result[@"category_name"];
                NSString *groupsAssociated = result[@"group_associated"];
                NSString *displayPic = result[@"display_pic_50"];
                
                
                NSLog(@"category id: %@",categoryId);
                NSLog(@"category name: %@",categoryName);
                NSLog(@"group no: %@",groupsAssociated);
                NSLog(@"display pic: %@",displayPic);
                
                
                [categoryIds addObject:categoryId];
                [categoryThumbnails addObject:displayPic];
                [categoryNames addObject:categoryName];
                [categoryGroupNo addObject:groupsAssociated];
                
                NSLog(@"category name %@",categoryNames);
                NSLog(@"category thumbnails %@",categoryThumbnails);
                
                
                
                
            }
            [HUD hide:YES];
            [ExploreTableView reloadData];
            fetchLocationConn=nil;
            [fetchLocationConn cancel];
        }
    }
    //searchVariable = 0;
    if (connection == groupCountConn) {
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:groupCountResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSArray *results = res[@"category_list"];
        
        if ([results count]!=0) {
            NSLog(@"====EVENTS==3 %@",res);
            [categoryIds removeAllObjects];
            [categoryGroupNo removeAllObjects];
            
            for (NSDictionary *result in results) {
                
                [categoryIds addObject:result[@"category_id"]];
                [categoryGroupNo addObject:result[@"group_associated"]];
                
                NSLog(@"category name %@",categoryIds);
                NSLog(@"category thumbnails %@",categoryGroupNo);
                
                
            }
            
            [ExploreTableView reloadData];
            groupCountConn=nil;
            [groupCountConn cancel];
        }
    }
    
    if (connection == searchConn) {
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:searchResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        //[activityIndicator stopAnimating];
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        
        NSDictionary *results = res[@"group_list"];
        NSLog(@"results: %@", results);
        NSDictionary *groups=results[@"list"];
        NSLog(@"groups: %@", groups);
        
        if ([groups count]==0 )
        {
            [HUD hide:YES];
            groupByCategoryLabel.textColor = [UIColor redColor];
            groupByCategoryLabel.text = @"NO MATCH FOUND";
            
            
            /* UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
             
             message:@"No results found."
             
             delegate:nil
             
             cancelButtonTitle:@"OK"
             
             otherButtonTitles:nil];
             [alert show];*/
        }
        
        //NSLog(@"====EVENTS==3 %@",res);
        else{
            for (NSDictionary *result in groups) {
                NSLog(@"app uid %@",appUserId);
                if (![result[@"id"]isEqualToString:appUserId]){
                    NSString *resultId = result[@"id"];
                    NSString *name = result[@"name"];
                    NSString *table_type = result[@"table_type"];
                    NSString *type = result[@"type"];
                    NSString *bottom_display = result[@"bottom_display"];
                    NSString *display_pic = result[@"thumbnail"];
                    NSString *email = result[@"email"];
                    NSString *status = result[@"user_status"];
                    
                    NSLog(@"resultId: %@",resultId);
                    NSLog(@"name: %@",name);
                    NSLog(@"table type: %@",table_type);
                    NSLog(@"type: %@",type);
                    NSLog(@"bottomdisplay: %@",bottom_display);
                    NSLog(@"display pic: %@",display_pic);
                    NSLog(@"email: %@",email);
                    NSLog(@"status: %@",status);
                    //NSLog(@"location: %@",location);
                    
                    if(resultId != nil) {
                        [resultIdArray addObject:resultId];
                    }else{
                        [resultIdArray addObject:@""];
                    }
                    if(name != nil) {
                        [textLabel addObject:name];
                    }else{
                        [textLabel addObject:@""];
                    }
                    if(table_type != nil) {
                        [tableType addObject:table_type];
                    }else{
                        [tableType addObject:@""];
                    }
                    if(type != nil) {
                        [typeArray addObject:type];
                    }else{
                        [typeArray addObject:@""];
                    }
                    if(bottom_display != nil) {
                        [detailTextLabel addObject:bottom_display];
                    }else{
                        [detailTextLabel addObject:@""];
                    }
                    if(display_pic != nil) {
                        [imageView addObject:display_pic];
                    }else{
                        [imageView addObject:@""];
                    }
                    if(email != nil) {
                        [userEmailId addObject:email];
                    }else{
                        [userEmailId addObject:@""];
                    }
                    if(status != nil) {
                        [userStatus addObject:status];
                        
                    }else{
                        [userStatus addObject:@""];
                        
                    }
                    NSLog(@" id %@",resultIdArray);
                    NSLog(@"group names %@",textLabel);
                    NSLog(@"table type %@",tableType);
                    NSLog(@"type array %@",typeArray);
                    NSLog(@"bottom disp %@",detailTextLabel);
                    NSLog(@"image %@",imageView);
                    NSLog(@"email arr %@",userEmailId);
                    NSLog(@"status arr %@",userStatus);
                    
                }
                
            }
            [tempResultIdArray addObjectsFromArray:resultIdArray];
            [tempTextLabel addObjectsFromArray:textLabel];
            [tempTableType addObjectsFromArray:tableType];
            [tempTypeArray addObjectsFromArray:typeArray];
            [tempDetailTextLabel addObjectsFromArray:detailTextLabel];
            [tempImageView addObjectsFromArray:imageView];
            [tempUserEmailId addObjectsFromArray:userEmailId];
            [tempUserStatus addObjectsFromArray:userStatus];
            if (resultIdArray.count==0) {
                groupByCategoryLabel.textColor = [UIColor redColor];
                groupByCategoryLabel.text = @"NO MATCH FOUND";
                
            }else{
                groupByCategoryLabel.textColor = [UIColor lightGrayColor];
                groupByCategoryLabel.text=@"SEARCH RESULTS";
                
            }
            searchVariable =1;
            [ExploreTableView reloadData];
            [HUD hide:YES];
            
            UIButton *FilterButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 40.0f, 30.0f)];
            [FilterButton setTitle:@"Filter" forState:UIControlStateNormal];//[UIColor
            [FilterButton addTarget:self action:@selector(setFilterTable:) forControlEvents:UIControlEventTouchUpInside];
            [FilterButton setTitleColor:[UIColor colorWithRed:5.0/255.0 green:122/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
            // UIBarButtonItem *Cancel = [[UIBarButtonItem alloc]                initWithTitle:@"Cancel"                style:UIBarButtonItemStyleBordered                target:self                action:@selector(CancelForward)];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:FilterButton];
            
            // filterButton = [[UIBarButtonItem alloc]                            initWithTitle:@"Filter"                            style:UIBarButtonItemStyleBordered                            target:self                            action:@selector(setFilterTable:)];
            //self.navigationItem.rightBarButtonItem = filterButton;
            searchConn=nil;
            [searchConn cancel];
        }
    }
    if (connection == addContactConn) {
        NSLog(@"====EVENTS");
        NSString *str1 = [[NSMutableString alloc] initWithData:addContactResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str1);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        
        NSDictionary *res= [jsonparser objectWithString:str1];
        
        NSLog(@" result %@",res);
        
        NSDictionary *response= res[@"response"];
        
        NSLog(@"response %@",response);
        NSString *status = response[@"status"];
        NSString *error = response[@"error"];
        NSLog(@"status = %@ error =  %@",status,error);
        
        if ([status isEqualToString:@"0"]){
            NSLog(@"selected %@,%@,%@,%@,%@,%@",selectedContactId,selectedContactEmail,selectedContactName,selectedContactPic,selectedContactStatus,selectedContactLocation);
            NSString *insertQuery=[NSString stringWithFormat:@"insert into contacts (user_id, user_email, user_name, user_pic, user_status,user_location) values ('%@','%@','%@','%@','%@','%@')",selectedContactId,selectedContactEmail,[selectedContactName stringByReplacingOccurrencesOfString:@"'" withString:@"''"],selectedContactPic,selectedContactStatus,selectedContactLocation];
            [[self appDelegate]addFriendWithJid:[[NSString stringWithFormat:@"user_%@@",selectedContactId] stringByAppendingString:(NSString*)jabberUrl ] nickName:selectedContactName];
            
            NSLog(@"query %@",insertQuery);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertQuery];
            
            //download image and save in the cache
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,selectedContactPic]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //cell.imageView.image = [UIImage imageWithData:imgData];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSLog(@"paths=%@",paths);
                    NSString *contactPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",selectedContactPic]];
                    NSLog(@"conatct pic path=%@",contactPicPath);
                    //imageData=UIImageJPEGRepresentation(groupPic.image, 1);
                    //Writing the image file
                    [imgData writeToFile:contactPicPath atomically:YES];
                    
                    
                });
                
            });
            
            [HUD  hide:YES];
            
            ChatScreen *chatScreen = [[ChatScreen alloc]init];
            
            chatScreen.chatType = @"personal";
            chatScreen.chatTitle=selectedContactName;
            [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[selectedContactId integerValue],(NSString*)jabberUrl]];
            
            chatScreen.groupType=@"";
            
            
            NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
            [attributeDic setValue:@"chat" forKey:@"type"];
            [attributeDic setValue:[selectedContactId JID]forKey:@"to"];
            [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
            [attributeDic setValue:@"0" forKey:@"isResend"];
            NSString *body=[NSString stringWithFormat:@"%@ has added you ",[[DatabaseManager getSharedInstance]getAppUserName]];
            NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
            [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID] forKey:@"from_user_id"];
            [elementDic setValue:@"text" forKey:@"message_type"];
            [elementDic setValue:@"1" forKey:@"contactUpdate"];
            [elementDic setValue:@"1" forKey:@"show_notification"];
            [elementDic setValue:@"1" forKey:@"is_notify"];
            [elementDic setValue:@"0" forKey:@"isgroup"];
            //  NSLog(@"gid %@",groupId);
            // [elementDic setValue:[NSString stringWithFormat:@"%@",groupId ] forKey:@"groupID"];
            [elementDic setValue:body forKey:@"body"];
            
            [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            [self.navigationController pushViewController:chatScreen animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"User has been added to your contact list."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            
            [[self appDelegate]._chatDelegate buddyStatusUpdated];
        }else{
            
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        
        addContactConn=nil;
        
        [addContactConn cancel];
        
    }
    if (connection == initiateGroupJoinConn) {
        NSLog(@"====EVENTS");
        NSString *str1 = [[NSMutableString alloc] initWithData:initiateGroupJoinResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str1);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str1];
        NSLog(@" result %@",res);
        NSDictionary *response= res[@"response"];
        
        NSLog(@"response %@",response);
        NSString *status = response[@"status"];
        NSString *error = response[@"error"];
        NSLog(@"status = %@ error =  %@",status,error);
        if ([status isEqualToString:@"0"]){
            
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }else{
            
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.tag=1;
            [alert show];
            
        }
        [[self appDelegate]._chatDelegate buddyStatusUpdated];
        
        initiateGroupJoinConn=nil;
        
        [initiateGroupJoinConn cancel];
        
    }
    if (connection == addGroupConn) {
        NSLog(@"====EVENTS");
        NSString *str1 = [[NSMutableString alloc] initWithData:addGroupResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str1);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        
        NSDictionary *res= [jsonparser objectWithString:str1];
        
        NSLog(@" result %@",res);
        
        NSDictionary *response= res[@"response"];
        NSMutableArray *adminIdList= [[NSMutableArray alloc]init];
        
        adminIdList=response[@"admin_ids"];
        
        NSLog(@"admin id list: %@",adminIdList);
        NSLog(@"response %@",response);
        NSString *status = response[@"status"];
        NSString *error = response[@"error"];
        NSLog(@"status = %@ error =  %@",status,error);
        if ([status isEqualToString:@"0"]){
            
            [HUD hide:YES];
            
            NSString *checkIfGroupExists=[NSString stringWithFormat:@"select * from group_invitations where group_id=%@",selectedGroupId];
            BOOL groupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfGroupExists];
            if (groupExistOrNot) {
                NSString *updateQuery=[NSString stringWithFormat:@"update  group_invitations set group_id = '%@', group_name = '%@', group_pic = '%@', group_type ='%@' where group_id = '%@' ",selectedGroupId,[selectedGroupName normalizeDatabaseElement],selectedGroupPic,selectedGroupType,selectedGroupId];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateQuery];
            }
            else
            {
                NSString *insertQuery=[NSString stringWithFormat:@"insert into group_invitations (group_id, group_name, group_pic, group_type) values ('%@','%@','%@','%@')",selectedGroupId,[selectedGroupName normalizeDatabaseElement],selectedGroupPic,selectedGroupType];
                NSLog(@"query %@",insertQuery);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertQuery];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            for (int j=0; j<[adminIdList count]; j++)
            {
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                
                [attributeDic setValue:[[adminIdList objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *userName=[[DatabaseManager getSharedInstance]getAppUserName];
                NSString *body=[NSString stringWithFormat:@"%@ want to join your group %@",userName,selectedGroupName  ];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID] forKey:@"from_user_id"];
                
                
                // if ([[memberId objectAtIndex:j]isEqualToString:userID])
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                //  if ([userID isEqual:[memberId objectAtIndex:j]] ) {
                [elementDic setValue:@"1" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"is_notify"];
                // }
                //  else
                //  {
                //     [elementDic setValue:@"0" forKey:@"is_notify"];
                //      [elementDic setValue:@"0" forKey:@"show_notification"];
                //  }
                [elementDic setValue:@"1" forKey:@"isgroup"];
                // NSLog(@"gid %@",groupId);
                //  [elementDic setValue:[NSString stringWithFormat:@"%@",groupId ] forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
                
                
            }
            
            
            [[self appDelegate]._chatDelegate buddyStatusUpdated];
        }
        else
        {
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        //     ChatScreen *chatScreen = [[ChatScreen alloc]init];
        //    chatScreen.chatType = @"group";
        //    chatScreen.chatTitle=selectedGroupName;
        //   [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[selectedGroupId integerValue],(NSString*)jabberUrl]];
        
        //   chatScreen.groupType=selectedGroupType ;
        //    [chatScreen retreiveHistory:nil];
        
        addGroupConn=nil;
        
        [addGroupConn cancel];
        
    }
    
    if (connection == addFavGroupConn) {
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:addFavGroupResponse encoding:NSASCIIStringEncoding];
        
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
                    NSString *checkIfMemberExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@ and deleted!=1",groups[@"id"],member[@"user_id"]];
                    BOOL memberExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberExists];
                    if (memberExistOrNot) {
                        NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set group_id = '%@', contact_id = '%@', is_admin = '%@', contact_name ='%@', contact_location ='%@', contact_image='%@' where group_id = '%@' and contact_id='%@' ",groups[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"],groups[@"id"],member[@"user_id"]];
                        NSLog(@"query %@",updateMembers);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                    }else{
                        
//                        NSString *insertMembers=[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, is_admin, contact_name, contact_location,contact_image) values ('%@','%@','%@','%@','%@','%@')",groups[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"]];
                        //                        NSLog(@"query %@",insertMembers);
//                                                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertMembers];
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
                    NSString *checkIfMemberToDeleteExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@ and deleted!=1",groups[@"id"],deletedMember];
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
            NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@ and deleted!=1",groups[@"id"]]];
            NSMutableArray    *membersID=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempmembersID count];i++)
            {
                [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
            }
            
            NSLog(@"membersID %@",membersID);
            
            
            for (int j=0; j<[membersID count]; j++){
                
                NSLog(@"%@ %@",membersID,membersID[j]);
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
            
            [[self appDelegate]._chatDelegate buddyStatusUpdated];
//            ChatScreen *chatScreen = [[ChatScreen alloc]init];
//            chatScreen.chatType = @"group";
//            chatScreen.chatTitle=groups[@"group_name"];
//            chatScreen.toJid =[NSString stringWithFormat:@"group_%d@%@",[groups[@"id"] integerValue],(NSString*)groupJabberUrl];
//            [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[groups[@"id"] integerValue],(NSString*)jabberUrl]];
//            chatScreen.groupType=groups[@"group_type"] ;
//            [chatScreen retreiveHistory:nil];
//            [self.navigationController pushViewController:chatScreen animated:YES];
            
            
            
            PostListing *detailPage = [[PostListing alloc]init];
            detailPage.chatTitle=groups[@"group_name"];
            detailPage.groupId = groups[@"id"];
            detailPage.groupName = groups[@"group_name"];
            detailPage.groupType=groups[@"group_type"];
            [self appDelegate].isUSER=0;
            [self.navigationController pushViewController:detailPage animated:YES];
            

//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
            
        }else{
            
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            
        }
        
        addFavGroupConn=nil;
        [addFavGroupConn cancel];
    }
    
    
}
//uialertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
            
            
            
            NSLog(@"You have clicked submit%@%@",selectedGroupId,appUserId);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",selectedGroupId,appUserId];
            NSLog(@"$[%@]",postData);
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/private_grp_request.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            addGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [addGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [addGroupConn start];
            addGroupResponse = [[NSMutableData alloc] init];
        }
        
    }
    
}

-(IBAction)setFilterTable:(id)sender
{
    [pop dismissPopoverAnimated:YES];
    //the view controller you want to present as popover
    //  UIViewController *controller = [[UIViewController alloc] init];
    filterTable = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //initWithFrame:CGRectMake(15, 92, 100, 100) style:UITableViewStyleGrouped];
    [filterTable.tableView setFrame:CGRectMake(15, 92, 100, 100)];
    
    filterTable.tableView.backgroundColor=[UIColor clearColor];
    
    filterTable.tableView.delegate = self;
    filterTable.tableView.dataSource = self;
    filterTable.tableView.scrollEnabled=FALSE;
    //controller.view=filterTable;
    // controller.title = @"Filter";
    //our popover
    //pop=[[UIPopoverController alloc] initWithContentViewController:controller];
    
    navController = [[UINavigationController alloc] initWithRootViewController:filterTable];
    filterTable.title=@"Filter";
    [navController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor] ,UITextAttributeTextColor,[UIFont fontWithName:@"Helvetica Neue" size:17],UITextAttributeFont, nil]];
    //  [navController.navigationBar setBackgroundColor:[UIColor greenColor] ];
    pop=[[UIPopoverController alloc]initWithContentViewController:navController ];
    
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 50.0f, 30.0f)];
    
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];//[UIColor
    [doneButton addTarget:self action:@selector(donefiltering:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitleColor:[UIColor colorWithRed:5.0/255.0 green:122/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
    // UIBarButtonItem *Cancel = [[UIBarButtonItem alloc]                initWithTitle:@"Cancel"                style:UIBarButtonItemStyleBordered                target:self                action:@selector(CancelForward)];
    navController.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    UIButton *clearButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 50.0f, 30.0f)];
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];//[UIColor
    [clearButton addTarget:self action:@selector(cancelPop:) forControlEvents:UIControlEventTouchUpInside];
    [clearButton setTitleColor:[UIColor colorWithRed:5.0/255.0 green:122/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
    // UIBarButtonItem *Cancel = [[UIBarButtonItem alloc]                initWithTitle:@"Cancel"                style:UIBarButtonItemStyleBordered                target:self                action:@selector(CancelForward)];
    navController.navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
    
    // UIBarButtonItem *doneButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(donefiltering:)];
    // navController.navigationBar.topItem.rightBarButtonItem=doneButtonItem;
    // UIBarButtonItem *cancelButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPop:)];
    //   navController.navigationBar.topItem.leftBarButtonItem=cancelButtonItem;
    //[self.navigationController pushViewController:controller animated:YES];
    
    [pop setPopoverContentSize:CGSizeMake(self.view.frame.size.width-10, 180)];
    //[pop presentPopoverFromBarButtonItem:filterButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    
    CGRect rect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 10, 10);
    [pop presentPopoverFromRect:rect inView:self.view permittedArrowDirections:NO animated:NO];
    
    /* popover = [[FPPopoverController alloc] initWithViewController:controller];
     popover.contentSize = CGSizeMake(200,182);
     
     popover.arrowDirection = FPPopoverNoArrow;
     popover.border = NO;
     [popover presentPopoverFromView:segControl];*/
}
-(void)donefiltering:(id)sender
{
    
    if (userFilter==1||privateFilter==1||publicFilter==1) {
        [self clearArrays:@"array"];
    }
    
    if (userFilter==1) {
        
        for (int m=0; m<tempResultIdArray.count; m++) {
            if ([tempTypeArray[m] isEqualToString:@"0"]) {
                [resultIdArray addObject:[tempResultIdArray objectAtIndex:m]];
                [textLabel addObject:[tempTextLabel objectAtIndex:m]];
                [tableType addObject:[tempTableType objectAtIndex:m]];
                [typeArray addObject:[tempTypeArray objectAtIndex:m]];
                [detailTextLabel addObject:[tempDetailTextLabel objectAtIndex:m]];
                [imageView addObject:[tempImageView objectAtIndex:m]];
                [userEmailId addObject:[tempUserEmailId objectAtIndex:m]];
                [userStatus addObject:[tempUserStatus objectAtIndex:m]];
            }
        }
    }
    if (privateFilter==1) {
        
        for (int m=0; m<tempResultIdArray.count; m++) {
            if ([tempTypeArray[m] isEqualToString:@"private#local"]||[tempTypeArray[m] isEqualToString:@"private#global"]) {
                [resultIdArray addObject:[tempResultIdArray objectAtIndex:m]];
                [textLabel addObject:[tempTextLabel objectAtIndex:m]];
                [tableType addObject:[tempTableType objectAtIndex:m]];
                [typeArray addObject:[tempTypeArray objectAtIndex:m]];
                [detailTextLabel addObject:[tempDetailTextLabel objectAtIndex:m]];
                [imageView addObject:[tempImageView objectAtIndex:m]];
                [userEmailId addObject:[tempUserEmailId objectAtIndex:m]];
                [userStatus addObject:[tempUserStatus objectAtIndex:m]];
            }
        }
    }
    if (publicFilter==1) {
        
        for (int m=0; m<tempResultIdArray.count; m++) {
            if ([tempTypeArray[m] isEqualToString:@"public#global"]||[tempTypeArray[m] isEqualToString:@"public#local"]) {
                [resultIdArray addObject:[tempResultIdArray objectAtIndex:m]];
                [textLabel addObject:[tempTextLabel objectAtIndex:m]];
                [tableType addObject:[tempTableType objectAtIndex:m]];
                [typeArray addObject:[tempTypeArray objectAtIndex:m]];
                [detailTextLabel addObject:[tempDetailTextLabel objectAtIndex:m]];
                [imageView addObject:[tempImageView objectAtIndex:m]];
                [userEmailId addObject:[tempUserEmailId objectAtIndex:m]];
                [userStatus addObject:[tempUserStatus objectAtIndex:m]];
            }
        }
    }
    
    if(resultIdArray .count==0)
    {
        groupByCategoryLabel.textColor = [UIColor redColor];
        groupByCategoryLabel.text=@"NO RESULTS";
    }
    else
    {
        groupByCategoryLabel.textColor = [UIColor lightGrayColor];
        groupByCategoryLabel.text=@"SEARCH RESULTS";
    }
    searchVariable =1;
    [ExploreTableView reloadData];
    //userFilter=0;
    //privateFilter=0;
    //publicFilter=0;
    
    [pop dismissPopoverAnimated:YES];
}
-(void)cancelPop:(id)sender
{
    userFilter=1;
    publicFilter=1;
    privateFilter=1;
    [filterTable.tableView reloadData];
    [self donefiltering:nil];
    [pop dismissPopoverAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)clearArrays:(NSString *)variable
{
    if ([variable isEqualToString:@"temp"]) {
        [tempResultIdArray removeAllObjects];
        [tempTextLabel removeAllObjects];
        [tempTableType removeAllObjects];
        [tempTypeArray removeAllObjects];
        [tempDetailTextLabel removeAllObjects];
        [tempImageView removeAllObjects];
        [tempUserEmailId removeAllObjects];
        [tempUserStatus removeAllObjects];
    }
    else
    {
        [resultIdArray removeAllObjects];
        [textLabel removeAllObjects];
        [tableType removeAllObjects];
        [typeArray removeAllObjects];
        [detailTextLabel removeAllObjects];
        [imageView removeAllObjects];
        [userEmailId removeAllObjects];
        [userStatus removeAllObjects];
    }
}




@end
