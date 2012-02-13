//
//  AGViewController.m
//  Photo Importer
//
//  Created by Artur Grigor on 2/13/12.
//  Copyright (c) 2012 Universitatea "Babes-Bolyai". All rights reserved.
//

#import "AGViewController.h"

#import "SVProgressHUD.h"

@interface AGViewController ()

- (void)hideKeyboard;
- (void)importAction:(id)sender;
- (void)importNext;

@property (nonatomic, retain) NSMutableArray *filePaths;

@end

@implementation AGViewController

#pragma mark - Properties

@synthesize filePaths;

- (UILabel *)pathLabel
{
    if (pathLabel == nil) {
        pathLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.f, 20.f, self.view.frame.size.width - 40.f, 21.f)];
        pathLabel.backgroundColor = [UIColor clearColor];
        pathLabel.textColor = [UIColor whiteColor];
        pathLabel.text = @"Place your Photos into this folder";
    }
    
    return pathLabel;
}

- (UITextField *)pathTextField
{
    if (pathTextField == nil) {
        pathTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.f, 49.f, self.view.frame.size.width - 40.f, 31.f)];
        pathTextField.borderStyle = UITextBorderStyleRoundedRect;
        pathTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        pathTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        NSString *activeHomeDirectory = [@"~" stringByExpandingTildeInPath];
        NSArray *activeHomeDirectoryPathComponents = [activeHomeDirectory.pathComponents retain];
        NSString *homeDirectory = @"";
        if (activeHomeDirectoryPathComponents.count > 2) {
            homeDirectory = [homeDirectory stringByAppendingPathComponent:[activeHomeDirectoryPathComponents objectAtIndex:0]];
            homeDirectory = [homeDirectory stringByAppendingPathComponent:[activeHomeDirectoryPathComponents objectAtIndex:1]];
            homeDirectory = [homeDirectory stringByAppendingPathComponent:[activeHomeDirectoryPathComponents objectAtIndex:2]];
        }
        homeDirectory = [homeDirectory stringByAppendingPathComponent:@"Pictures/Photo Importer"];
        pathTextField.text = homeDirectory;
        
        pathTextField.delegate = self;
    }
    
    return pathTextField;
}

- (UIButton *)importButton
{
    if (importButton == nil) {
        importButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        importButton.frame = CGRectMake((self.view.frame.size.width - 72.f) / 2, 136.f, 72.f, 37.f);
        [importButton setTitle:@"Import" forState:UIControlStateNormal];
        
        [importButton addTarget:self action:@selector(importAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return importButton;
}

#pragma mark - Oject Lifecycle

- (void)dealloc
{
    [pathLabel release];
    [pathTextField release];
    [importButton release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.view addSubview:self.pathLabel];
        [self.view addSubview:self.pathTextField];
        [self.view addSubview:self.importButton];
        
        numberOfPhotos = 0;
        numberOfPhotosProcessed = 0;
        numberOfErrors = 0;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Hide keyboard gesture
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self                                                                                          action:@selector(hideKeyboard)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    pathLabel = nil;
    pathTextField = nil;
    importButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    return YES;
}

#pragma mark - Private

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - Actions

- (void)importAction:(id)sender
{
    NSString *path = [self.pathTextField.text copy];
    self.filePaths = [NSMutableArray array];
    for (NSString *filePath in [[NSFileManager defaultManager] enumeratorAtPath:path].allObjects)
    {
        NSString *fileExtension = [[filePath pathExtension] lowercaseString];
        BOOL isPhoto = ([fileExtension isEqualToString:@"jpg"] || [fileExtension isEqualToString:@"png"]);
        
        if (isPhoto) {
            [filePaths addObject:[path stringByAppendingPathComponent:filePath]];
        }
    }
    [path release];
    
    numberOfPhotos = filePaths.count;
    numberOfPhotosProcessed = 0;
    numberOfErrors = 0;
    
    [self importNext];
}

- (void)importNext
{
    UIImage *image = [UIImage imageWithContentsOfFile:[self.filePaths lastObject]];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil); 
    
    [self.filePaths removeLastObject];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    numberOfPhotosProcessed++;
    
    if (error)
    {
        numberOfErrors++;
        
        [SVProgressHUD dismissWithError:error.localizedDescription];
        return;        
    }
    
    if (numberOfPhotosProcessed == numberOfPhotos) {
        if (numberOfErrors == 0)
            [SVProgressHUD dismissWithSuccess:@"Success." afterDelay:3];
        else
            [SVProgressHUD dismissWithError:[NSString stringWithFormat:@"%d of %d have failed.", numberOfErrors, numberOfPhotos] afterDelay:3];
    }
    else
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%d of %d", numberOfPhotosProcessed, numberOfPhotos]];
    
    // Continue importing
    if (numberOfPhotosProcessed < numberOfPhotos)
        [self importNext];
}

@end
