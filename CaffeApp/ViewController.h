//
//  ViewController.h
//  CaffeApp
//
//  Created by Takuya Matsuyama on 7/11/15.
//  Copyright (c) 2015 Takuya Matsuyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
- (IBAction)takePhoto:(id)sender;
- (IBAction)selectPhoto:(id)sender;
- (IBAction)classify:(id)sender;
- (NSString*)predictWithImage: (UIImage*)image;
- (NSString*)predictWithBuffer: (CMSampleBufferRef)buffer;

@property (weak, nonatomic) IBOutlet UILabel *recogObject;



@end

