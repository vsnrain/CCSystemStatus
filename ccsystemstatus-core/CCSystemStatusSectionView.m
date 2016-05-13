//
//  CCSystemStatusSectionView.m
//  CCSystemStatus
//
//  Created by vsnRain on 25.01.2014.
//  Copyright (c) 2014 vsnRain. All rights reserved.
//

#import "CCSystemStatusSectionView.h"

#define ipad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@implementation CCSystemStatusSectionView{
    UIImage *wifiImage;
    UIImage *cellularImage;
    UIImage *ramImage;
    UIImage *cpuImage;
    UIImage *rootImage;
    UIImage *varImage;
    
    UILabel *label[4];
    UIImageView *image[4];
    
    int width;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        /////////////////////////////////////
        
        wifiImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"wifi" ofType:@"png"]];
        cellularImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"cellular" ofType:@"png"]];
        ramImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"ram" ofType:@"png"]];
        cpuImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"cpu" ofType:@"png"]];
        
        rootImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"root" ofType:@"png"]];
        varImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"var" ofType:@"png"]];
        
        /////////////////////////////////////
        
        image[0] = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 25, 25)];
        image[0].alpha = 0.7;
        [self addSubview:image[0]];
        
        image[1] = [[UIImageView alloc] initWithFrame:CGRectMake(12, 39, 25, 25)];
        image[1].alpha = 0.7;
        [self addSubview:image[1]];
        
        image[2] = [[UIImageView alloc] initWithFrame:CGRectMake(201, 8, 25, 25)];
        image[2].alpha = 0.7;
        [self addSubview:image[2]];
        
        image[3] = [[UIImageView alloc] initWithFrame:CGRectMake(201, 39, 25, 25)];
        image[3].alpha = 0.7;
        [self addSubview:image[3]];
        
        /////////////////////////////////////
        
        label[0] = [[UILabel alloc] initWithFrame:CGRectMake(44, 8, 135, 25)];
        label[0].alpha = 0.8;
        label[0].numberOfLines = 1;
        label[0].adjustsFontSizeToFitWidth = YES;
        label[0].text = @"N/A";
        [self addSubview:label[0]];
        
        label[1] = [[UILabel alloc] initWithFrame:CGRectMake(44, 39, 135, 25)];
        label[1].alpha = 0.8;
        label[1].numberOfLines = 1;
        label[1].adjustsFontSizeToFitWidth = YES;
        label[1].text = @"N/A";
        [self addSubview:label[1]];
        
        label[2] = [[UILabel alloc] initWithFrame:CGRectMake(233, 8, 75, 25)];
        label[2].alpha = 0.8;
        label[2].numberOfLines = 1;
        label[2].adjustsFontSizeToFitWidth = YES;
        label[2].minimumScaleFactor=0.7;
        label[2].textAlignment = NSTextAlignmentRight;
        label[2].text = @"N/A";
        [self addSubview:label[2]];
        
        label[3] = [[UILabel alloc] initWithFrame:CGRectMake(233, 39, 75, 25)];
        label[3].numberOfLines = 1;
        label[3].adjustsFontSizeToFitWidth = YES;
        label[3].minimumScaleFactor=0.7;
        label[3].textAlignment = NSTextAlignmentRight;
        label[3].text = @"N/A";
        [self addSubview:label[3]];
        
        /////////////////////////////////////
        
        self.screenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.screenButton];
        
        /////////////////////////////////////
        
        self.screenLabel = [[NSOrderedSet alloc] initWithObjects:label[0], label[1], label[2], label[3], nil];
        self.screenImage = [[NSOrderedSet alloc] initWithObjects:image[0], image[1], image[2], image[3], nil];
    }
    return self;
}

-(void) hideAll{
    for (int i = 0; i<4; i++){
        image[i].hidden = YES;
        label[i].hidden = YES;
    }
}

-(void) unhide:(int)num withImage:(NSString *)string{

    image[num].hidden = NO;
    label[num].hidden = NO;
    
    if ([string isEqualToString:@"WIFI-IP_INT"]){
        image[num].image = wifiImage;
    }else if ([string isEqualToString:@"CELL-IP_EXT"]){
        image[num].image = cellularImage;
    }else if ([string isEqualToString:@"RAM"]){
        image[num].image = ramImage;
    }else if ([string isEqualToString:@"CPU"]){
        image[num].image = cpuImage;
    }else if ([string isEqualToString:@"WIFI-SSID"]){
        image[num].image = wifiImage;
    }else if ([string isEqualToString:@"WIFI-MAC"]){
        image[num].image = wifiImage;
    }else if ([string isEqualToString:@"ROOT"]){
        image[num].image = rootImage;
    }else if ([string isEqualToString:@"VAR"]){
        image[num].image = varImage;
    }else{
        image[num].hidden = YES;
        label[num].hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    width = self.frame.size.width;
    int h = width/2;
    
    image[0].frame = CGRectMake(8, 8, 26, 26);
    image[1].frame = CGRectMake(8, 38, 26, 26);
    image[2].frame = CGRectMake(h+4, 8, 26, 26);
    image[3].frame = CGRectMake(h+4, 38, 26, 26);
    
    label[0].frame = CGRectMake(42, 8, h-4-8-26-8, 26);
    label[1].frame = CGRectMake(42, 38, h-4-8-26-8, 26);
    label[2].frame = CGRectMake(h+4+26+8, 8, h-4-8-26-8, 26);
    label[3].frame = CGRectMake(h+4+26+8, 38, h-4-8-26-8, 26);
    
    self.screenButton.frame = CGRectMake(0, 0, width, 72);
    
    for (int i = 0; i<4; i++){
        label[i].text = @"";
    }
    
    [self.delegate refresh];
}

@end
