//
//  SharedEmailViewController.m
//  ndspro
//
//  Created by fengyongning on 13-11-22.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "SharedEmailViewController.h"
#import "Names.h"
#import "YNFunctions.h"
#import "MBProgressHUD.h"
#import "UIBarButtonItem+Yn.h"
#import "IconDownloader.h"
#import "SelectFileListViewController.h"

@implementation FileView{
    NSDictionary *_dic;
}
@synthesize addFileButton;

-(id)init
{
    self=[super init];
    if (self) {
    }
    return self;
}
-(void)setButton
{
    self.imageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 70, 70)];
    self.imageView.image = [UIImage imageNamed:@"add_pic.png"];
    [self addSubview:self.imageView];
}
-(void)setDic:(NSDictionary *)dic
{
    if(dic)
    {
        self.dicData=dic;
        self.imageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 70, 70)];
        self.nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 30)];
        self.nameLabel.lineBreakMode=NSLineBreakByTruncatingMiddle;
        self.nameLabel.textAlignment=NSTextAlignmentCenter;
        self.nameLabel.font=[UIFont systemFontOfSize:12];
        [self addSubview:self.imageView];
        [self addSubview:self.nameLabel];
        
        NSString *fname=[dic objectForKey:@"fname"];
        NSString *fmime=[[fname pathExtension] lowercaseString];
        NSString *fisdir=[dic objectForKey:@"fisdir"];
        NSLog(@"fmime:%@",fmime);
        if ([fisdir isEqualToString:@"0"]) {
            self.imageView.image = [UIImage imageNamed:@"file_folder.png"];
        }else
            if ([fmime isEqualToString:@"png"]||
                [fmime isEqualToString:@"jpg"]||
                [fmime isEqualToString:@"jpeg"]||
                [fmime isEqualToString:@"bmp"]||
                [fmime isEqualToString:@"gif"])
            {
                NSString *fthumb=[dic objectForKey:@"fthumb"];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                fthumb =[YNFunctions picFileNameFromURL:fthumb];
                localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                self.imagePath=localThumbPath;
                NSLog(@"是否存在文件：%@",localThumbPath);
                if ([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]&&[UIImage imageWithContentsOfFile:localThumbPath]!=nil) {
                    NSLog(@"存在文件：%@",localThumbPath);
                    UIImage *icon=[UIImage imageWithContentsOfFile:localThumbPath];
                    CGSize itemSize = CGSizeMake(100, 100);
                    UIGraphicsBeginImageContext(itemSize);
                    CGRect theR=CGRectMake(0, 0, itemSize.width, itemSize.height);
                    if (icon.size.width>icon.size.height) {
                        theR.size.width=icon.size.width/(icon.size.height/itemSize.height);
                        theR.origin.x=-(theR.size.width/2)-itemSize.width;
                    }else
                    {
                        theR.size.height=icon.size.height/(icon.size.width/itemSize.width);
                        theR.origin.y=-(theR.size.height/2)-itemSize.height;
                    }
                    CGRect imageRect = CGRectMake(0, 0, 100, 100);
                    [icon drawInRect:imageRect];
                    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    self.imageView.image= image;
                    
                }else{
                    NSLog(@"将要下载的文件：%@",localThumbPath);
                    self.imageView.image = [UIImage imageNamed:@"file_pic.png"];
                    [self startIconDownload:dic forIndexPath:nil];
                }
            }else if ([fmime isEqualToString:@"doc"]||
                      [fmime isEqualToString:@"docx"]||
                      [fmime isEqualToString:@"rtf"])
            {
                self.imageView.image = [UIImage imageNamed:@"file_word.png"];
            }
            else if ([fmime isEqualToString:@"xls"]||
                     [fmime isEqualToString:@"xlsx"])
            {
                self.imageView.image = [UIImage imageNamed:@"file_excel.png"];
            }else if ([fmime isEqualToString:@"mp3"])
            {
                self.imageView.image = [UIImage imageNamed:@"file_music.png"];
            }else if ([fmime isEqualToString:@"mov"]||
                      [fmime isEqualToString:@"mp4"]||
                      [fmime isEqualToString:@"avi"]||
                      [fmime isEqualToString:@"rmvb"])
            {
                self.imageView.image = [UIImage imageNamed:@"file_moving.png"];
            }else if ([fmime isEqualToString:@"pdf"])
            {
                self.imageView.image = [UIImage imageNamed:@"file_pdf.png"];
            }else if ([fmime isEqualToString:@"ppt"]||
                      [fmime isEqualToString:@"pptx"])
            {
                self.imageView.image = [UIImage imageNamed:@"file_ppt.png"];
            }else if([fmime isEqualToString:@"txt"])
            {
                self.imageView.image = [UIImage imageNamed:@"file_txt.png"];
            }else
            {
                self.imageView.image = [UIImage imageNamed:@"file_other.png"];
            }
        self.nameLabel.text=fname;
    }
    else
    {
        CGRect addFileRect = CGRectMake(5, 15, 70, 70);
        self.addFileButton = [[UIButton alloc] initWithFrame:addFileRect];
        [self.addFileButton setBackgroundImage:[UIImage imageNamed:@"add_pic.png"] forState:UIControlStateNormal];
        [self addSubview:self.addFileButton];
    }
}

- (void)startIconDownload:(NSDictionary *)dic forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader * iconDownloader = [[IconDownloader alloc] init];
    iconDownloader.data_dic=dic;
    iconDownloader.indexPathInTableView = indexPath;
    iconDownloader.delegate = self;
    [iconDownloader startDownload];
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
{
    // Remove the IconDownloader from the in progress list.
    // This will result in it being deallocated.
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.imagePath]&&[UIImage imageWithContentsOfFile:self.imagePath]!=nil) {
        NSLog(@"存在文件：%@",self.imagePath);
        UIImage *icon=[UIImage imageWithContentsOfFile:self.imagePath];
//        CGSize itemSize = CGSizeMake(100, 100);
//        UIGraphicsBeginImageContext(itemSize);
//        CGRect theR=CGRectMake(0, 0, itemSize.width, itemSize.height);
//        if (icon.size.width>icon.size.height) {
//            theR.size.width=icon.size.width/(icon.size.height/itemSize.height);
//            theR.origin.x=-(theR.size.width/2)-itemSize.width;
//        }else
//        {
//            theR.size.height=icon.size.height/(icon.size.width/itemSize.width);
//            theR.origin.y=-(theR.size.height/2)-itemSize.height;
//        }
//        CGRect imageRect = CGRectMake(0, 0, 100, 100);
//        //                        CGSize size=icon.size;
//        //                        if (size.width>size.height) {
//        //                            imageRect.size.height=size.height*(30.0f/imageRect.size.width);
//        //                            imageRect.origin.y+=(30-imageRect.size.height)/2;
//        //                        }else{
//        //                            imageRect.size.width=size.width*(30.0f/imageRect.size.height);
//        //                            imageRect.origin.x+=(30-imageRect.size.width)/2;
//        //                        }
//        [icon drawInRect:imageRect];
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        self.imageView.image= icon;
        //                        CGRect r=cell.imageView.frame;
        //                        r.size.width=r.size.height=30;
        //                        cell.imageView.frame=r;
        //cell.imageView.transform=CGAffineTransformMakeScale(0.5f,0.5f);
        
    }
}
@end

@interface SharedEmailViewController()<UIActionSheetDelegate,UIScrollViewDelegate,SCBEmailManagerDelegate,UITextFieldDelegate,UITextViewDelegate,UIAlertViewDelegate>
@property (strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) UIPopoverController *popoverFileSelectController;
- (void)resizeViews;
@end

@class FileVieww;
@implementation SharedEmailViewController{
    TITokenFieldView * _tokenFieldView;
	UITextView * _messageView;
    UIView *_filesView;
	
	CGFloat _keyboardHeight;
}
@synthesize tyle,em;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidLayoutSubviews
{
    [self resizeViews];
    [_tokenFieldView resetSize];
    [self reloadFiles];
}
- (void)viewDidLoad
{
    UIBarButtonItem *cancel=[[UIBarButtonItem alloc] initWithTitleStr:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [self.navigationItem setLeftBarButtonItem:cancel];
    UIBarButtonItem *send=[[UIBarButtonItem alloc] initWithTitleStr:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sendAction:)];
    [self.navigationItem setRightBarButtonItem:send];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
	[self.view setBackgroundColor:[UIColor whiteColor]];
	
	_tokenFieldView = [[TITokenFieldView alloc] initWithFrame:self.view.bounds];
    if(tyle==kTypeShareIn)
    {
        [self.navigationItem setTitle:@"内部分享"];
        [_tokenFieldView setIsShowSelectButton:YES];
        [_tokenFieldView setup];
        [_tokenFieldView.selectButton addTarget:self action:@selector(clickSelected:) forControlEvents:UIControlEventTouchDown];
        [_tokenFieldView.selectButton setHidden:NO];
        [_tokenFieldView.changeLabel setHidden:NO];
        [_tokenFieldView.tokenField setPlaceholder:@""];
        _tokenFieldView.tokenField.tyle = kTypeTokenIn;
    }
    else
    {
        [self.navigationItem setTitle:@"邮件分享"];
        [_tokenFieldView setup];
        [_tokenFieldView setIsShowSelectButton:NO];
        [_tokenFieldView.selectButton setHidden:YES];
        [_tokenFieldView.changeLabel setHidden:YES];
        [_tokenFieldView.tokenField setPlaceholder:@"          使用“换行”来区分多个联系人"];
        _tokenFieldView.tokenField.tyle = kTypeTokenEx;
    }
	[self.view addSubview:_tokenFieldView];
	
    [_tokenFieldView setDelegate:self];
    
	[_tokenFieldView.tokenField setDelegate:self];
	[_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:TITokenFieldControlEventFrameDidChange];
	[_tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;，；"]]; // Default is a comma
    [_tokenFieldView.tokenField setPromptText:@"收件人："];
    [_tokenFieldView.tokenField setKeyboardType:UIKeyboardTypeEmailAddress];
    [_tokenFieldView setPromptText:@"主题："];
    [_tokenFieldView.titileField setPlaceholder:@"必填"];
    [_tokenFieldView.titileField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_tokenFieldView.titileField setDelegate:self];
    [_tokenFieldView.titileField setFont:[UIFont systemFontOfSize:14]];
    
	
    
	_messageView = [[UITextView alloc] initWithFrame:_tokenFieldView.contentView.bounds];
	[_messageView setScrollEnabled:NO];
	[_messageView setDelegate:self];
	[_messageView setFont:[UIFont systemFontOfSize:15]];
	[_messageView setText:@""];
	[_tokenFieldView.contentView addSubview:_messageView];
    
    _filesView=[[UIView alloc] initWithFrame:_tokenFieldView.contentView2.bounds];
    [_tokenFieldView.contentView2 addSubview:_filesView];
	
    [self reloadFiles];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
//	[_tokenFieldView becomeFirstResponder];
    [self getEmailTitle];
}

-(void)clickSelected:(id)sender
{
    UserListViewController *ulvc=[[UserListViewController alloc] init];
//    if(self.usrids)
//    {
//        ulvc.selectedItems = [[NSMutableArray alloc] initWithArray:self.usrids];
//    }
//    else
//    {
//        ulvc.selectedItems = [[NSMutableArray alloc] init];
//    }
    ulvc.listViewDelegate=self;
    [self.navigationController pushViewController:ulvc animated:YES];
}
- (void)getEmailTitle
{
    self.em=[[SCBEmailManager alloc] init];
    self.em.delegate=self;
    [self.em getEmailTitle];
}
- (void)getEmailTemplate
{
    self.em=[[SCBEmailManager alloc] init];
    self.em.delegate=self;
    NSMutableArray *namesArray=[NSMutableArray array];
    for (NSDictionary *dic in self.fileArray) {
        NSString *f_name=[dic objectForKey:@"fname"];
        [namesArray addObject:f_name];
    }
    NSString *fileNames=[namesArray componentsJoinedByString:@"/"];
    [self.em getEmailTemplateWithName:fileNames];
}
- (void)reloadFiles
{
    for (UIView *view in _filesView.subviews) {
        [view removeFromSuperview];
    }
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, _filesView.bounds.size.width-20, 21)];
    label.text=@"分享内容";
    [_filesView addSubview:label];
    BOOL isFloder = NO;
    
    int numPerRow=self.view.bounds.size.width/80;
    
    for (int i=0; i<self.fileArray.count; i++) {
        int row=i/numPerRow;
        int column=i%numPerRow;
        FileView *fv=[[FileView alloc] initWithFrame:CGRectMake(column*(self.view.bounds.size.width/numPerRow), row*(100)+30, self.view.bounds.size.width/numPerRow, 100)];
        if (i==self.fileArray.count) {
            [fv setButton];
            [fv setIndex:i];
        }else
        {
            NSDictionary *dic=[self.fileArray objectAtIndex:i];
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                [fv addTarget:self action:@selector(floderTouch:) forControlEvents:UIControlEventTouchUpInside];
            }else
            {
                [fv addTarget:self action:@selector(fileTouch:) forControlEvents:UIControlEventTouchUpInside];
            }

            [fv setDic:[self.fileArray objectAtIndex:i]];
            [fv setIndex:i];
            
        }
        [_filesView addSubview:fv];
    }
    
    int row=self.fileArray.count/numPerRow,column=self.fileArray.count%numPerRow;
    FileView *fv=[[FileView alloc] initWithFrame:CGRectMake(column*(self.view.bounds.size.width/numPerRow), row*(100)+20, self.view.bounds.size.width/numPerRow, 100)];
    for (int i=0; i<self.fileArray.count; i++) {
        
        if (i==self.fileArray.count) {
            [fv setButton];
            [fv setIndex:i];
        }else
        {
            NSDictionary *dic = [self.fileArray objectAtIndex:i];
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if (![fisdir isEqualToString:@"0"]) {
                [fv setDic:nil];
            }
            [fv setIndex:i];
            [fv addTarget:self action:@selector(fileTouch:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    [fv.addFileButton addTarget:self action:@selector(clickedButton) forControlEvents:UIControlEventTouchDown];
    [fv setIndex:self.fileArray.count];
    [fv addTarget:self action:@selector(addFileView:) forControlEvents:UIControlEventTouchUpInside];
    [_filesView addSubview:fv];
    
	CGFloat newHeight = (self.fileArray.count/numPerRow+1)*100+90;
	CGRect newTextFrame = _tokenFieldView.contentView2.frame;
	newTextFrame.size.height = newHeight;
    [_tokenFieldView.contentView2 setFrame:newTextFrame];
    [_filesView setFrame:_tokenFieldView.contentView2.bounds];
	[_tokenFieldView updateContentSize];
}

- (void)addFileView:(id)sender
{
    
}
- (void)floderTouch:(id)sender
{
    SelectFileListViewController *flVC=[[SelectFileListViewController alloc] init];
    if(self.fileArray.count>0)
    {
        NSDictionary *dic = [self.fileArray objectAtIndex:0];
        flVC.spid=[dic objectForKey:@"spid"];
    }
    flVC.f_id=@"0";
    flVC.title=@"请选择文件夹";
    flVC.delegate=self;
    flVC.type=kSelectTypeFloderChange;
    flVC.rootName=@"我的文件";
    flVC.roletype=@"2"; //2为我的文件夹 1为企业文件夹
    flVC.isHasSelectFile=YES;
    flVC.isFirstView = YES;
    flVC.selectFileEmialViewDelegate=self;
    YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:flVC];
//    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
//    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
//    [nav.navigationBar setTintColor:[UIColor whiteColor]];
//    [self presentViewController:nav animated:YES completion:nil];
    
    if (![self.popoverFileSelectController isPopoverVisible]) {
        self.popoverFileSelectController=[[UIPopoverController alloc] initWithContentViewController:nav];
        [self.popoverFileSelectController presentPopoverFromRect:CGRectMake(0, 0, 320, 768) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        //Dismiss if the button is tapped while pop over is visible
        [self.popoverFileSelectController dismissPopoverAnimated:YES];
    }

}

- (void)fileTouch:(id)sender
{
    FileView *fv=(FileView *)sender;
    UIActionSheet *as=[[UIActionSheet alloc] initWithTitle:fv.nameLabel.text delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
    [as setTag:fv.index];
    [as showInView:[[UIApplication sharedApplication] keyWindow]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{[self resizeViews];}]; // Make it pweeetty.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self resizeViews];
}

- (void)showContactsPicker:(id)sender {
	
	// Show some kind of contacts picker in here.
	// For now, here's how to add and customize tokens.
//	
//	NSArray * names = [Names listOfNames];
//	
//	TIToken * token = [_tokenFieldView.tokenField addTokenWithTitle:[names objectAtIndex:(arc4random() % names.count)]];
//	[token setAccessoryType:TITokenAccessoryTypeDisclosureIndicator];
//	// If the size of the token might change, it's a good idea to layout again.
//	[_tokenFieldView.tokenField layoutTokensAnimated:YES];
//	
//	NSUInteger tokenCount = _tokenFieldView.tokenField.tokens.count;
//	[token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 2) == 0 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	_keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
    int tabBarOffset = self.tabBarController == nil ?  0 : self.tabBarController.tabBar.frame.size.height;
	[_tokenFieldView setFrame:((CGRect){_tokenFieldView.frame.origin, {self.view.bounds.size.width, self.view.bounds.size.height + tabBarOffset - _keyboardHeight}})];
	[_messageView setFrame:_tokenFieldView.contentView.bounds];
}
#pragma mark - TITokenFieldDelegate
//- (BOOL)tokenField:(TITokenField *)tokenField willAddToken:(TIToken *)token
//{
//    if (tokenField.tokenTitles.count>=10) {
//        tokenField.text=nil;
//        return NO;
//    }
//    return YES;
//}
- (void)tokenField:(TITokenField *)tokenField didAddToken:(TIToken *)token;
{
    BOOL isHas=NO;
    for (int i=0;i<tokenField.tokenTitles.count-1;i++) {
        NSString *theT=[tokenField.tokenTitles objectAtIndex:i];
        if ([theT isEqualToString:token.title]) {
            isHas=YES;
            break;
        }
    }
    if (isHas) {
        [tokenField removeToken:token];
        return;
    }
//    if (tokenField.tokenTitles.count>10) {
//        [tokenField removeToken:token];
//        return;
//    }
}
- (BOOL)tokenField:(TITokenField *)tokenField willRemoveToken:(TIToken *)token {
	return YES;
}

- (void)tokenFieldChangedEditing:(TITokenField *)tokenField {
	// There's some kind of annoying bug where UITextFieldViewModeWhile/UnlessEditing doesn't do anything.
	[tokenField setRightViewMode:(tokenField.editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever)];
}

- (void)tokenFieldFrameDidChange:(TITokenField *)tokenField {
	[self textViewDidChange:_messageView];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if (textField==_tokenFieldView.titileField) {
        //NSLog(@"UserName");
        NSMutableString *text = [textField.text mutableCopy];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 64;
    }
    return YES;
}
#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView==_messageView) {
        //NSLog(@"UserName");
        NSMutableString *stext = [textView.text mutableCopy];
        [stext replaceCharactersInRange:range withString:text];
        return [stext length] <= 500;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
	
	CGFloat oldHeight = _tokenFieldView.frame.size.height - _tokenFieldView.tokenField.frame.size.height - _tokenFieldView.titileField.frame.size.height - _tokenFieldView.contentView2.frame.size.height;
    CGSize size=[textView sizeThatFits:CGSizeMake(320, 2000)];
	CGFloat newHeight = size.height;
	if (newHeight<100) {
        newHeight=100;
    }
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = _tokenFieldView.contentView.frame;
	newFrame.size.height = newHeight;
	
//	if (newHeight < oldHeight){
//		newTextFrame.size.height = oldHeight;
//		newFrame.size.height = oldHeight;
//	}
    
	[_tokenFieldView.contentView setFrame:newFrame];
    CGRect new2Frame=_tokenFieldView.contentView2.frame;
    new2Frame.origin.y=CGRectGetMaxY(newFrame);
    [_tokenFieldView.contentView2 setFrame:new2Frame];
	[textView setFrame:newTextFrame];
	[_tokenFieldView updateContentSize];
}
#pragma mark - 操作方法
-(void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)checkIsEmail:(NSString *)text
{
    NSArray *array=[text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";,"]];
    for (NSString *strValue in array) {
        NSString *Regex =@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        //@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        //(\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*;)*
        //(\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*[,;])*\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*|(\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*[,;])*
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
        
        if (![emailTest evaluateWithObject:strValue]) {
            return NO;
        };
    }
    return YES;
}
-(NSArray *)checkAllEmail
{
    NSMutableArray *errorEmail=[NSMutableArray array];
    for (NSString *text in _tokenFieldView.tokenTitles) {
        if (![self checkIsEmail:text]) {
            [errorEmail addObject:text];
        }
    }
    return errorEmail;
}
-(BOOL)canSend
{
    NSString *recevers;
    NSString *eTitle;
    NSString *eContent;
    recevers=[_tokenFieldView.tokenTitles componentsJoinedByString:@";"];
    eTitle=_tokenFieldView.titileField.text;
    eContent=_messageView.text;
    //不设上限
//    if (_tokenFieldView.tokenTitles.count>10)
//    {
//        if (self.hud) {
//            [self.hud removeFromSuperview];
//        }
//        self.hud=nil;
//        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//        [self.view.superview addSubview:self.hud];
//        [self.hud show:NO];
//        self.hud.labelText=@"收件人数量不能超过10个";
//        //self.hud.labelText=error_info;
//        self.hud.mode=MBProgressHUDModeText;
//        self.hud.margin=10.f;
//        [self.hud show:YES];
//        [self.hud hide:YES afterDelay:1.0f];
//        return NO;
//
//    }
    NSString *noSpaceString=[eTitle stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (eTitle==nil||[eTitle isEqualToString:@""]||[noSpaceString isEqualToString:@""]) {
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view.superview addSubview:self.hud];
        [self.hud show:NO];
        self.hud.labelText=@"请填写主题";
        //self.hud.labelText=error_info;
        self.hud.mode=MBProgressHUDModeText;
        self.hud.margin=10.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
        return NO;
    }
    if (((recevers==nil||[recevers isEqualToString:@""]) && self.tyle == kTypeShareEx) || (self.tyle == kTypeShareIn && self.emails.count==0) ) {
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view.superview addSubview:self.hud];
        [self.hud show:NO];
        self.hud.labelText=@"请填写收件人";
        //self.hud.labelText=error_info;
        self.hud.mode=MBProgressHUDModeText;
        self.hud.margin=10.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
        return NO;
    }
    else if(tyle==kTypeShareEx && [self checkAllEmail].count!=0)
    {
        NSArray *errorArray=[self checkAllEmail];
        NSString *message;
        message=[errorArray objectAtIndex:0];
        if (errorArray.count>1) {
            message=[NSString stringWithFormat:@"“%@”等",message];
        }else
        {
            message=[NSString stringWithFormat:@"“%@”",message];
        }
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"以下收件人存在格式错误" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [av setTag:234];
        [av show];
        [_tokenFieldView.tokenField becomeFirstResponder];
        return NO;
    }
    return YES;
}
-(void)sendAction:(id)sender
{
    [_tokenFieldView.tokenField becomeFirstResponder];

    [_tokenFieldView endEditing:YES];
    if (![self canSend]) {
        return;
    }
    NSMutableArray *ids=[[NSMutableArray alloc] init];
    for (NSDictionary *dic in self.fileArray) {
        NSString *fid=[dic objectForKey:@"fid"];
        [ids addObject:fid];
    }
    self.fids=ids;
    self.em=[[SCBEmailManager alloc] init];
    self.em.delegate=self;
    
    NSString *recevers;
    NSString *eTitle;
    NSString *eContent;
//    recevers=[_tokenFieldView.tokenTitles componentsJoinedByString:@";"];
    recevers=[_tokenFieldView.tokenTitles componentsJoinedByString:@","];
    eTitle=_tokenFieldView.titileField.text;
    eContent=_messageView.text;
    
    if (self.tyle==kTypeSendEx) {
        [self.em createLinkMailWithFids:self.fids title:eTitle content:eContent receivelist:recevers];
    }
    else
    {
        [self.em sendFilesWithSubject:eTitle userids:self.usrids usernames:self.usernameList useremails:self.emails sendfiles:self.fids message:eContent];
    }
    
    
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"正在发送...";
    self.hud.mode=MBProgressHUDModeIndeterminate;
    self.hud.margin=10.f;
    [self.hud show:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int tag=actionSheet.tag;
    if (tag>=0) {
        if (buttonIndex==0) {
            if (self.fileArray.count==1) {
                UIActionSheet *as=[[UIActionSheet alloc] initWithTitle:@"至少要分享一个文件" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
                [as setTag:-1];
                [as showInView:[[UIApplication sharedApplication] keyWindow]];
                return;
            }
            //删除选中文件！
            NSMutableArray *ma=[[NSMutableArray alloc] initWithArray:self.fileArray];
            [ma removeObjectAtIndex:tag];
            self.fileArray=ma;
            [self reloadFiles];
        }
    }else if(tag==-1)
    {
        
    }
}
#pragma mark - SCBEmailManagerDelegate
-(void)createLinkSucceed:(NSDictionary *)datadic
{
    NSLog(@"Link:%@",[datadic objectForKey:@"msg"]);
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"分享成功";
    //self.hud.labelText=error_info;
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self performSelector:@selector(cancelAction:) withObject:self afterDelay:1.0f];
}
-(void)sendEmailSucceed
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"分享成功";
    //self.hud.labelText=error_info;
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self performSelector:@selector(cancelAction:) withObject:self afterDelay:1.0f];
}
-(void)sendEmailFail
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"发送失败";
    //self.hud.labelText=error_info;
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)networkError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"链接失败，请检查网络";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)getEmailTemplateSucceed:(NSDictionary *)datadic
{
    NSString *content=[datadic objectForKey:@"content"];
    NSString *title=[datadic objectForKey:@"title"];
    [_messageView setText:content];
    [_tokenFieldView.titileField setText:title];
}
-(void)getEmailTemplateFail
{
    
}
-(void)getEmailTitleSucceed:(NSString *)title
{
    [_tokenFieldView.titileField setText:title];

}
#pragma mark userListViewControllerDelegate

-(void)didSelectUserIDS:(NSArray *)ids Names:(NSArray *)names emails:(NSArray *)emails
{
    [_tokenFieldView.tokenField removeAllTokens];
    self.usrids=ids;
    self.usernameList=names;
    self.names=[names componentsJoinedByString:@";"];
    self.emails=emails;
    NSMutableString *tableString = [[NSMutableString alloc] init];
    for(int i=0;i<names.count;i++)
    {
        [tableString appendString:[names objectAtIndex:i]];
        if(i+1 < names.count)
        {
            [tableString appendString:@","];
        }
    }
    [_tokenFieldView.tokenField setPlaceholder:@""];
    _tokenFieldView.changeLabel.text = tableString;
}

-(void)clickedButton
{
    if (self.fileArray.count == 50) {
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"一次最多只能分享50个文件" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [av show];
        return;
        
    }
    
    MainViewController *viewController=[[MainViewController alloc] init];
    viewController.delegate=self;
    viewController.type=kTypeShare;
    viewController.sharedEmialViewDelegate=self;
    YNNavigationController *nav=[[YNNavigationController alloc] initWithRootViewController:viewController];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
//    [nav.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
//    [nav.navigationBar setTintColor:[UIColor whiteColor]];
//    [self presentViewController:nav animated:YES completion:nil];
    if (![self.popoverFileSelectController isPopoverVisible]) {
        self.popoverFileSelectController=[[UIPopoverController alloc] initWithContentViewController:nav];
        [self.popoverFileSelectController presentPopoverFromRect:CGRectMake(0, 0, 320, 768) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        //Dismiss if the button is tapped while pop over is visible
        [self.popoverFileSelectController dismissPopoverAnimated:YES];
    }
}

-(void)fileListSucceed:(NSData *)data
{
    NSLog(@"文件发送成功");
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"文件分享成功";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self dissViewcontroller];
}

-(void)sendFilesSucceed:(NSDictionary *)datadic
{
    NSLog(@"文件发送成功：%@",datadic);
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"文件分享成功";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    
    [self dissViewcontroller];
}

-(void)dissViewcontroller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addSharedFileView:(NSDictionary *)dictionary
{
    [self.fileArray addObject:dictionary];
    [self reloadFiles];
    if(self.popoverFileSelectController.isPopoverVisible)
    {
        //Dismiss if the button is tapped while pop over is visible
        [self.popoverFileSelectController dismissPopoverAnimated:YES];
    }
}
-(void)changeFloderView:(NSDictionary *)dictionary
{
    [self.fileArray removeAllObjects];
    [self.fileArray addObject:dictionary];
    [self reloadFiles];
    if(self.popoverFileSelectController.isPopoverVisible)
    {
        //Dismiss if the button is tapped while pop over is visible
        [self.popoverFileSelectController dismissPopoverAnimated:YES];
    }
}

@end
