//
//  ViewController.m
//  CaffeApp
//
//  Created by Takuya Matsuyama on 7/11/15.
//  Copyright (c) 2015 Takuya Matsuyama. All rights reserved.
//

#import "ViewController.h"
#import "Classifier.h"
#import "opencv2/highgui/ios.h"
#import "Knn.h"


@interface ViewController (){
    

UIImage* classificationImage;
int initialFlag;
vector<DataModel> trainingDescVect;

}@end

@implementation ViewController

- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    

}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    classificationImage = chosenImage;
    
 
    NSString* result = [self predictWithImage:chosenImage];
    dispatch_async(dispatch_get_main_queue(), ^{
        _label.text = result;
    });
    [picker dismissViewControllerAnimated:YES completion:NULL];

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadModel];
    UIImage* image = [UIImage imageNamed:@"image_0002.jpg"];
    _imageView.image = image;
    _label.text = @"Classifying..";
    
    NSString* result = [self predictWithImage:image];
    dispatch_async(dispatch_get_main_queue(), ^{
        _label.text = result;
    });
}

- (IBAction)predict1:(id)sender {
    UIImage* image = [UIImage imageNamed:@"image_0001.jpg"];
    _imageView.image = image;
    _label.text = @"Classifying..";
    
    NSString* result = [self predictWithImage:image];
    dispatch_async(dispatch_get_main_queue(), ^{
        _label.text = result;
    });
}
- (IBAction)predict2:(id)sender {
    UIImage* image = [UIImage imageNamed:@"image_0002.jpg"];
    _imageView.image = image;
    _label.text = @"Classifying..";
    
    NSString* result = [self predictWithImage:image];
    dispatch_async(dispatch_get_main_queue(), ^{
        _label.text = result;
    });
}



Classifier * classifier;

- (void)loadModel{
    NSString* model_file = [NSBundle.mainBundle pathForResource:@"deploy" ofType:@"prototxt" inDirectory:@"model"];
    NSString* label_file = [NSBundle.mainBundle pathForResource:@"labels" ofType:@"txt" inDirectory:@"model"];
    NSString* mean_file = [NSBundle.mainBundle pathForResource:@"mean" ofType:@"binaryproto" inDirectory:@"model"];
    NSString* trained_file = [NSBundle.mainBundle pathForResource:@"bvlc_reference_caffenet" ofType:@"caffemodel" inDirectory:@"model"];
    
    string model_file_str = std::string([model_file UTF8String]);
    string label_file_str = std::string([label_file UTF8String]);
    string trained_file_str = std::string([trained_file UTF8String]);
    string mean_file_str = std::string([mean_file UTF8String]);
    
    classifier = new Classifier(model_file_str, trained_file_str, mean_file_str, label_file_str);
}

- (NSString*)predictWithBuffer: (CMSampleBufferRef)buffer{
    
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(buffer);
    
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    
    
    //Processing here
    int bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // put buffer in open cv, no memory copied
    cv::Mat src_img = cv::Mat(bufferHeight,bufferWidth,CV_8UC4,pixel);
    
    //End processing
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );

    cv::Mat bgra_img;
    // needs to convert to BGRA because the image loaded from UIImage is in RGBA
    cv::cvtColor(src_img, bgra_img, CV_RGBA2BGRA);
    
    std::vector<Prediction> result = classifier->Classify(bgra_img);
    
    NSString* ret = nil;
    
    for (std::vector<Prediction>::iterator it = result.begin(); it != result.end(); ++it) {
        NSString* label = [NSString stringWithUTF8String:it->first.c_str()];
        NSNumber* probability = [NSNumber numberWithFloat:it->second];
        NSLog(@"label: %@, prob: %@", label, probability);
        if (it == result.begin()) {
            ret = label;
        }
    }
    
    return ret;
}
- (void) parseBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    
    
    //Processing here
    int bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // put buffer in open cv, no memory copied
    cv::Mat mat = cv::Mat(bufferHeight,bufferWidth,CV_8UC4,pixel);
    
    //End processing
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
}

- (NSString*)predictWithImage: (UIImage*)image;
{
    cv::Mat src_img, bgra_img;
    UIImageToMat(image, src_img);
    // needs to convert to BGRA because the image loaded from UIImage is in RGBA
    cv::cvtColor(src_img, bgra_img, CV_RGBA2BGRA);
    
    std::vector<Prediction> result = classifier->Classify(bgra_img);
    
    NSString* ret = nil;
    
    for (std::vector<Prediction>::iterator it = result.begin(); it != result.end(); ++it) {
        NSString* label = [NSString stringWithUTF8String:it->first.c_str()];
        NSNumber* probability = [NSNumber numberWithFloat:it->second];
        NSLog(@"label: %@, prob: %@", label, probability);
        if (it == result.begin()) {
            ret = label;
        }
    }
    
    return ret;
}

@end

