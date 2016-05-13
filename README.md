# ios-caffe-ObjectRecognition
Object Recognition Demo App



This is an example XCode project using iOS version of Caffe built by [aleph7](https://github.com/aleph7/caffe).

It also includes a class `Classifier` which is the `cpp_classification` imported from Caffe C++ example.
It classifies example image as following screenshot:

![sc](https://cloud.githubusercontent.com/assets/1332805/10410612/d0450f08-6f81-11e5-8dc5-2dd870639b4b.png)

## Dependencies

## Get started

Clone it:


pod install 


put your .caffemodel, deploy.prototxt, mean.binaryproto, labels and descriptors.txt (training) under models folder.

```
git clone git@github.com:aleph7/caffe.git @4560c2dcfff5b778c8f1177b8b541427239b3380 under main folder.(folder name for caffe should be "caffe")

mv @4560c2dcfff5b778c8f1177b8b541427239b3380 caffe
```

### Prepare model files

You need your `caffemodel`, `deploy.prototxt`, `mean.binaryproto` and `labels.txt` into `model/` directory.
This sample already includes files for testing except for `caffemodel`.

You can download BVLC CaffeNet Model from: [http://dl.caffe.berkeleyvision.org/bvlc_reference_caffenet.caffemodel](http://dl.caffe.berkeleyvision.org/bvlc_reference_caffenet.caffemodel).


On the device - you may get a termination from memory -> 
(it does work on simulator.)
Attempting to upgrade input file specified using deprecated V1LayerParameter: /Users/johndpope/Library/Developer/CoreSimulator/Devices/0A8A6936-550D-4446-B2B0-BC0F78099967/data/Containers/Bundle/Application/A42F3783-E170-4226-B2C5-AF4D9D781588/CaffeApp.app/model/bvlc_reference_caffenet.caffemodel

You can make these binary files and upgrade your .proto / caffemodels -> 
https://github.com/BVLC/caffe/tree/master/tools



Of course, you can use your own network model if you have.

## How to classify

```objective-c
NSString* model_file = [NSBundle.mainBundle pathForResource:@"deploy" ofType:@"prototxt" inDirectory:@"model"];
NSString* label_file = [NSBundle.mainBundle pathForResource:@"labels" ofType:@"txt" inDirectory:@"model"];
NSString* mean_file = [NSBundle.mainBundle pathForResource:@"mean" ofType:@"binaryproto" inDirectory:@"model"];
NSString* trained_file = [NSBundle.mainBundle pathForResource:@"bvlc_reference_caffenet" ofType:@"caffemodel" inDirectory:@"model"];
string model_file_str = std::string([model_file UTF8String]);
string label_file_str = std::string([label_file UTF8String]);
string trained_file_str = std::string([trained_file UTF8String]);
string mean_file_str = std::string([mean_file UTF8String]);

UIImage* example = [UIImage imageNamed:@"image_0002.jpg"];

cv::Mat src_img;
UIImageToMat(example, src_img);

Classifier classifier = Classifier(model_file_str, trained_file_str, mean_file_str, label_file_str);
std::vector<Prediction> result = classifier.Classify(src_img);
```

Output into console:

```objective-c
for (std::vector<Prediction>::iterator it = result.begin(); it != result.end(); ++it) {
  NSString* label = [NSString stringWithUTF8String:it->first.c_str()];
  NSNumber* probability = [NSNumber numberWithFloat:it->second];
  NSLog(@"label: %@, prob: %@", label, probability);
}
```

## License and Citation

### This example

[BSD 2-Clause license](https://github.com/BVLC/caffe/blob/master/LICENSE)

### Caffe

Caffe is released under the [BSD 2-Clause license](https://github.com/BVLC/caffe/blob/master/LICENSE).
The BVLC reference models are released for unrestricted use.

Please cite Caffe in your publications if it helps your research:

    @article{jia2014caffe,
      Author = {Jia, Yangqing and Shelhamer, Evan and Donahue, Jeff and Karayev, Sergey and Long, Jonathan and Girshick, Ross and Guadarrama, Sergio and Darrell, Trevor},
      Journal = {arXiv preprint arXiv:1408.5093},
      Title = {Caffe: Convolutional Architecture for Fast Feature Embedding},
      Year = {2014}
    }
