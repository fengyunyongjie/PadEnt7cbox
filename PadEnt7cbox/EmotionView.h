//
//  EmotionView.h
//  tigerTalker
//
//  Created by hudie on 14-6-24.
//  Copyright (c) 2014年 hudie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FaceView;

@interface EmotionView : UIView {
    FaceView *_faceView;
}

@property (nonatomic, assign) UITextField *delegate;
@property (nonatomic, assign) UITextView *tvDelegate;

@end
