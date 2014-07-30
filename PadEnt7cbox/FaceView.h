//
//  FaceView.h
//  tigerTalker
//
//  Created by hudie on 14-6-24.
//  Copyright (c) 2014年 hudie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceView : UIView {
    
    NSMutableArray *_phraseArray;
    UIScrollView   *_sv;
    UIPageControl  *_pc;
    BOOL pageControlIsChanging;
}

@property (nonatomic, assign) id       delegate;
@property (nonatomic, retain) NSArray        *faceArray;
@property (nonatomic, retain) NSMutableArray *imageArray;

@end
