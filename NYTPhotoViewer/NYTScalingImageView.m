//
//  NYTScalingImageView.m
//  NYTPhotoViewer
//
//  Created by Harrison, Andrew on 7/23/13.
//  Copyright (c) 2015 The New York Times Company. All rights reserved.
//

#import "NYTScalingImageView.h"

#import "tgmath.h"

@interface NYTScalingImageView ()

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (nonatomic) UIImageView *imageView;

@end

@implementation NYTScalingImageView

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithImage:[UIImage new] frame:frame];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self commonInitWithImage:nil imageData:nil];
    }

    return self;
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    [self centerScrollViewContents];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateZoomScale];
    [self centerScrollViewContents];
}

#pragma mark - NYTScalingImageView

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self commonInitWithImage:image imageData:nil];
    }
    
    return self;
}

- (instancetype)initWithImageData:(NSData *)imageData frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInitWithImage:nil imageData:imageData];
    }
    
    return self;
}

- (void)commonInitWithImage:(UIImage *)image imageData:(NSData *)imageData {
    [self setupInternalImageViewWithImage:image imageData:imageData];
    [self setupImageScrollView];
    [self updateZoomScale];
}

#pragma mark - Setup

- (void)setupInternalImageViewWithImage:(UIImage *)image imageData:(NSData *)imageData {
    UIImage *imageToUse = image ?: [UIImage imageWithData:imageData];

    self.imageView = [[UIImageView alloc] initWithImage:imageToUse];
    [self updateImage:imageToUse imageData:imageData];
    
    [self addSubview:self.imageView];
}

- (void)updateImage:(UIImage *)image {
    [self updateImage:image imageData:nil];
}

- (void)updateImageData:(NSData *)imageData {
    [self updateImage:nil imageData:imageData];
}

- (void)updateImage:(UIImage *)image imageData:(NSData *)imageData {
    UIImage *imageToUse = image ?: [UIImage imageWithData:imageData];

    // Remove any transform currently applied by the scroll view zooming.
    self.imageView.transform = CGAffineTransformIdentity;
    self.imageView.image = imageToUse;

    self.imageView.frame = CGRectMake(0, 0, imageToUse.size.width, imageToUse.size.height);
    
    self.contentSize = imageToUse.size;
    
    [self updateZoomScale];
    [self centerScrollViewContents];
}

- (void)setupImageScrollView {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (void)updateZoomScale {
    if (self.imageView.image) {
        CGSize imageSize = self.imageView.image.size;
        CGRect scrollViewFrame = self.bounds;
        
        CGFloat scaleWidth = scrollViewFrame.size.width / imageSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / imageSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        
        self.minimumZoomScale = minScale;
        self.maximumZoomScale = MAX(minScale, self.maximumZoomScale);
        self.zoomScale = self.minimumZoomScale;
        
        // scrollView.panGestureRecognizer.enabled is on by default and enabled by
        // viewWillLayoutSubviews in the container controller so disable it here
        // to prevent an interference with the container controller's pan gesture.
        //
        // This is enabled in scrollViewWillBeginZooming so panning while zoomed-in
        // is unaffected.
        self.panGestureRecognizer.enabled = NO;
    }
}

#pragma mark - Centering

- (void)centerScrollViewContents {
    CGFloat horizontalInset = 0;
    CGFloat verticalInset = 0;
    
    if (self.contentSize.width < CGRectGetWidth(self.bounds)) {
        horizontalInset = (CGRectGetWidth(self.bounds) - self.contentSize.width) * 0.5;
    }
    
    if (self.contentSize.height < CGRectGetHeight(self.bounds)) {
        verticalInset = (CGRectGetHeight(self.bounds) - self.contentSize.height) * 0.5;
    }
    
    if (self.window.screen.scale < 2.0) {
        horizontalInset = __tg_floor(horizontalInset);
        verticalInset = __tg_floor(verticalInset);
    }
    
    // Use `contentInset` to center the contents in the scroll view. Reasoning explained here: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
    self.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}

@end
