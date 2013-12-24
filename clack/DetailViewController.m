//
//  DetailViewController.m
//  clack
//
//  Created by Evan Brooks on 12/16/13.
//  Copyright (c) 2013 Evan Brooks. All rights reserved.
//

#import "DetailViewController.h"
#import "SyntaxHighlightTextStorage.h"
#import "ImageAttachment.h"
#import "ClackTextView.h"
#import "DAKeyboardControl.h"


@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end


@implementation DetailViewController

@synthesize imgPicker;
@synthesize camPicker;

SyntaxHighlightTextStorage* _textStorage;
CGFloat _kbHeight = 0.0;
CGFloat _topOffset = 0.0;
CGFloat _baseFontSize = 20.0;

CGFloat _topMargin = 5.0;
CGFloat _bottomMargin = 15.0;
CGFloat _leftMargin = -5.0; //15.0;
CGFloat _rightMargin = 0.0; //15.0;

CGFloat _aboveKBMargin = 0.0;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
        self.textView.text = [[self.detailItem valueForKey:@"text"] description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _topOffset = 20; // height of statusbar (20) or status + nav (20 + 44)
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    
    UIView *statusBarView = [[UIApplication sharedApplication] valueForKey:[@[@"status", @"Bar"] componentsJoinedByString:@""]];
    [UIView beginAnimations:@"foo" context:nil];
    [UIView setAnimationDuration:0.3];
    statusBarView.alpha = 0.2;
    [UIView commitAnimations];
    
    self.imgPicker = [[UIImagePickerController alloc] init];
    self.imgPicker.allowsEditing = YES;
    self.imgPicker.delegate = (id) self;
    self.imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    self.camPicker = [[UIImagePickerController alloc] init];
    self.camPicker.allowsEditing = YES;
    self.camPicker.delegate = (id) self;
    self.camPicker.sourceType = UIImagePickerControllerSourceTypeCamera;

    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(goBackToList)];
    NSArray *toolbarItems = [NSArray arrayWithObjects: backButton, nil];

    self.toolbarItems = toolbarItems;
    
    [self createTextView];
    [self createToolbar];
    
//    __unsafe_unretained typeof(self) weakSelf = self;
//    [self.textView addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
//        //weakSelf.textView.superview.frame.size.height -
//        
//        CGFloat scrollPos = weakSelf.textView.contentOffset.y;
//        CGFloat screenHeight = weakSelf.view.window.frame.size.height;
//        CGFloat kbPos = keyboardFrameInView.origin.y;
//        CGFloat kbHeight = screenHeight - (kbPos - scrollPos);
//        
//        // NSLog(@"scrollpos: %f", scrollPos);
//        // NSLog(@"kbPos    : %f", kbPos);
//        // NSLog(@"kbHeight : %f", kbHeight);
//        weakSelf.textView.scrollEnabled = NO;
//        weakSelf.textView.contentInset = UIEdgeInsetsMake(20, 0, kbHeight, 0);
//        weakSelf.textView.scrollIndicatorInsets = weakSelf.textView.contentInset;
//        weakSelf.textView.scrollEnabled = YES;
//    }];
    
    [self configureView];
}

- (void)viewDidAppear:(BOOL)animated {
    
    // Animate initial kb
    //[UIView animateWithDuration:0.5 animations:^{
        [self.textView becomeFirstResponder];
    //}];

    [super viewWillAppear:animated];
}

-(void) toolbarButtonPress:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    // NSLog(@"%ld", (long)[segmentedControl selectedSegmentIndex]);

    switch ([segmentedControl selectedSegmentIndex]){
        case 0:
            // [self insertImage:[UIImage imageNamed:@"insert-test.png"] intoTextView:self.textView];
            [self presentViewController:self.imgPicker animated:YES completion:nil];
            break;
        case 1:
            //[self insertString:@"<img src='' />" intoTextView:self.textView];
            // [self insertImage:[UIImage imageNamed:@"insert-test-wide.png"] intoTextView:self.textView];
            [self presentViewController:self.camPicker animated:YES completion:nil];
            break;
        case 2:
            // Done button pressed
            [self resignKeyboard];
            break;
        case 3:
            [self insertString:@"#" intoTextView:self.textView];
            break;
        case 4:
            [self insertString:@"_" intoTextView:self.textView];
            break;
        case 5:
            [self insertString:@"*" intoTextView:self.textView];
            break;
        default:
            // Who even knows?
            break;
            
    }
    [segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
}

-(void) goBackToList {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    // image.image = img;
    
    NSLog(@"picked image");
    [self dismissViewControllerAnimated:YES completion:^{
        [self insertImage:img intoTextView:self.textView];
    }];
}

- (void) saveItem {
    [self.detailItem setValue:@"Whoo I saved" forKey:@"snippet"];
    [self.detailItem setValue:self.textView.text forKey:@"text"];
}

#pragma mark -
#pragma mark - Inserting

- (void) insertString: (NSString *) insertingString intoTextView: (UITextView *) textView
{
    NSRange range = textView.selectedRange;
    NSString * firstHalfString = [textView.text substringToIndex:range.location];
    NSString * secondHalfString = [textView.text substringFromIndex: range.location];
    textView.scrollEnabled = NO;  // turn off scrolling or you'll get dizzy ... I promise
    
    textView.text = [NSString stringWithFormat: @"%@%@%@",
                     firstHalfString,
                     insertingString,
                     secondHalfString];
    
    // put cursor after inserted string
    range.location += [insertingString length];
    textView.selectedRange = range;
    textView.scrollEnabled = YES;  // turn scrolling back on.
}

- (void) insertImage: (UIImage *) insertingImage intoTextView: (UITextView *) textView
{
    // Make attachment
    NSTextAttachment *attachment = [[ImageAttachment alloc] init];
    attachment.image = insertingImage;
    attachment.bounds = CGRectMake(0, 0, insertingImage.size.width, insertingImage.size.height);
    
    // Split text at current cursor position
    NSRange range = textView.selectedRange;
    NSRange firstRange = NSMakeRange(0, range.location);
    NSRange secondRange = NSMakeRange(range.location, textView.attributedText.length - range.location);
    NSAttributedString * firstHalfString = [textView.attributedText attributedSubstringFromRange: firstRange];
    NSAttributedString * secondHalfString = [textView.attributedText attributedSubstringFromRange: secondRange];
    
    // Build new attributed string with image in the middle
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    [attrString appendAttributedString: firstHalfString];
    [attrString appendAttributedString: [[NSAttributedString alloc] initWithString:@"\n"]];
    [attrString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [attrString appendAttributedString: [[NSAttributedString alloc] initWithString:@"\n"]];
    [attrString appendAttributedString: secondHalfString];
    
    // Disable scrolling
    textView.scrollEnabled = NO;
    
    // Insert new attributed string
    textView.attributedText = attrString;
    
    // Put after image attatchment character(?) and the two newline characters (3 in total)
    range.location = range.location + 3;
    textView.selectedRange = range;
    
    // Re-enable scrolling
    textView.scrollEnabled = YES;
    
    
    // Update
    [_textStorage update];
    
    // Scroll to position
    // [self _showTextViewCaretPosition:textView];
}


#pragma mark -

#pragma mark - Create toolbar

-(void)createToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    // [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    
    
    
    NSArray *segmentsArray = [NSArray arrayWithObjects: @"Pics",
                              [[UIImage imageNamed:@"btn-camera.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                              @"OK",
                              @"#",
                              @"_",
                              @"*",
                              nil
                              ];
    UISegmentedControl *segmented = [[UISegmentedControl alloc] initWithItems:segmentsArray];
    segmented.frame = CGRectMake(0, 0, 320, 44);
    [segmented addTarget:self action:@selector(toolbarButtonPress:) forControlEvents:UIControlEventValueChanged];
    segmented.tintColor = [UIColor clearColor];
    
    [segmented setTitleTextAttributes:@{NSForegroundColorAttributeName:self.view.tintColor} forState:UIControlStateNormal];
    //[segmented setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateHighlighted];
    
    [segmented setBackgroundImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal barMetrics: UIBarMetricsDefault];
    [segmented setBackgroundImage:[UIImage imageNamed:@"overlay-bg.png"] forState:UIControlStateHighlighted barMetrics: UIBarMetricsDefault];
    
    UIBarButtonItem *segmentBarButton =[[UIBarButtonItem alloc] initWithCustomView:segmented];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = -16; // Hack to remove left margin
    NSArray *toolbarItems = [NSArray arrayWithObjects: space, segmentBarButton, nil];
    [toolbar setItems:toolbarItems];
    [self.textView addSubview:toolbar];
    [self.textView setInputAccessoryView:toolbar];

    toolbar.barTintColor = [UIColor colorWithRed:0.84 green:0.85 blue:0.87 alpha:0.3];
    // toolbar.barTintColor = [UIColor whiteColor];
    toolbar.translucent = YES;
    toolbar.alpha = 0.6;
}

# pragma mark - Create textView

- (void)createTextView
{
    // 1. Create the text storage that backs the editor
    NSDictionary* attrs = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
    NSAttributedString* attrString = [[NSAttributedString alloc]
                                      initWithString: [self.detailItem text]
                                      attributes:attrs];
    _textStorage = [SyntaxHighlightTextStorage new];
    [_textStorage appendAttributedString:attrString];
    
    CGRect newTextViewRect = self.view.bounds;
    
    // 2. Create the layout manager
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    // 3. Create a text container
    CGSize containerSize = CGSizeMake(newTextViewRect.size.width,  CGFLOAT_MAX);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [_textStorage addLayoutManager:layoutManager];
    
    // 4. Create a custom ClackTextView instead of a UITextView
    self.textView = [[ClackTextView alloc] initWithFrame:newTextViewRect
                                    textContainer:container];
    self.textView.delegate = (id) self;
    self.textView.font = [UIFont systemFontOfSize:_baseFontSize];
    self.textView.alwaysBounceVertical = YES;
    self.textView.delaysContentTouches = NO;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;

    [self updateTextViewContentInset];
    self.textView.textContainerInset = UIEdgeInsetsMake(_topMargin, _leftMargin, _bottomMargin, _rightMargin);

    [self.view addSubview:self.textView];
}


#pragma mark - UITextViewDelegate

// based on John Eriksson - https://devforums.apple.com/message/918284#918284

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self saveItem];
}

#pragma mark Scrolling

- (void)textViewDidChange:(UITextView *)textView {
    [_textStorage update];
    [self _showTextViewCaretPosition:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self _showTextViewCaretPosition:textView];
    // [_textStorage update];
}


- (void)_showTextViewCaretPosition:(UITextView *)textView {
    CGRect caretRect = [textView caretRectForPosition:self.textView.selectedTextRange.end];
    [textView scrollRectToVisible:caretRect animated:NO];
    
    /*
    
    CGFloat scrollPos = textView.contentOffset.y;
    CGFloat caretPos = caretRect.origin.y;
    if ((scrollPos + 30 > caretPos) || (scrollPos + 160 < caretPos)) {
        //[UIView beginAnimations:@"showCaret" context:nil];
        //[UIView setAnimationDuration:0.3];
        textView.contentOffset = CGPointMake(0.0,caretPos - 160);
        //[UIView commitAnimations];
    }
     */
    
    //textView.contentOffset = CGPointMake(0.0,caretRect.origin.y - 30);
}

// end based on John Eriksson

#pragma mark Keyboard

-(void)resignKeyboard {
    [self.textView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSLog(@"kb will show");
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _kbHeight = keyboardSize.height;
    [self updateTextViewContentInset];
    [self _showTextViewCaretPosition:self.textView];
    return;
}

- (void) keyboardDidShow:(NSNotification *)note
{
    NSLog(@"kb did show");
    return;
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    NSLog(@"kb will be hidden");
    _kbHeight = 0.0;
    [self updateTextViewContentInset];
}

-(void)updateTextViewContentInset {
    // [UIView beginAnimations:@"showCaret" context:nil];
    // [UIView setAnimationDuration:0.3];
    // self.textView.contentInset = UIEdgeInsetsMake(_topOffset, 0, _kbHeight, 0);
    // self.textView.scrollIndicatorInsets = self.textView.contentInset;
    // [UIView commitAnimations];
    
    
    self.textView.contentInset = UIEdgeInsetsMake(_topOffset, 0, _kbHeight + _aboveKBMargin, 0);
    self.textView.scrollIndicatorInsets = self.textView.contentInset;
}

//- (void) scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    NSLog(@"%f", scrollView.contentOffset.y);
//}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






/*! A custom TextStorage delegate method that replaces all the default NSAttachment instances with custom subclass ImageAttachment
 
 */
- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
    
    
    NSLog(@"didProcessEditing");
    
    //FLOG(@"textStorage:didProcessEditing:range:changeInLength: called");
    __block NSMutableDictionary *dict;
    
    [textStorage enumerateAttributesInRange:editedRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
         
         dict = [[NSMutableDictionary alloc] initWithDictionary:attributes];
         
         // Iterate over each attribute and look for attachments
         [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
             
             if ([[key description] isEqualToString:NSAttachmentAttributeName]) {
                 NSLog(@" textAttachment found");
                 //FLOG(@" textAttachment class is %@", [obj class]);
                 
                 NSTextAttachment *attachment = obj;
                 ImageAttachment *imgAttachment;
                 
                 if (attachment.image) {
                     //FLOG(@" attachment.image found");
                     imgAttachment = [[ImageAttachment alloc] initWithData:UIImagePNGRepresentation(attachment.image) ofType:attachment.fileType];
                 }
                 else {
                     //FLOG(@" attachment.image is nil");
                     imgAttachment = [[ImageAttachment alloc] initWithData:attachment.fileWrapper.regularFileContents ofType:attachment.fileType];
                 }
                 
                 [dict setValue:imgAttachment forKey:key];
             }
             
         }];
         
         [textStorage setAttributes:dict range:range];
         
     }];
    
}

@end
