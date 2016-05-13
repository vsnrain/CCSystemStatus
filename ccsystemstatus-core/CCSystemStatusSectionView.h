//
//  CCSystemStatusSectionView.h
//  CCSystemStatus
//
//  Created by vsnRain on 25.01.2014.
//  Copyright (c) 2014 vsnRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CCSystemStatusSectionDelegate <NSObject>
- (void) refresh;
- (void) screenTouched;
@end

@interface CCSystemStatusSectionView : UIView

@property (strong, nonatomic) id<CCSystemStatusSectionDelegate> delegate;

@property (strong, nonatomic) NSOrderedSet *screenLabel;
@property (strong, nonatomic) NSOrderedSet *screenImage;

@property (strong, nonatomic) UIButton *screenButton;

-(void) unhide:(int)num withImage:(NSString *)string;
-(void) hideAll;

@end
