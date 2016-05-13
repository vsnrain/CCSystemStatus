//
//  CCSystemStatusSection.h
//  CCSystemStatus
//
//  Created by vsnRain on 25.01.2014.
//  Copyright (c) 2014 vsnRain. All rights reserved.
//

#import "CCSection-Protocol.h"
#import "CCSystemStatusSectionView.h"

#import <SystemConfiguration/CaptiveNetwork.h>

#include "NSTask.h"
#include "route.h"
#include "if_ether.h"
#include "if_dl.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

#import <mach/mach.h>
#import <mach/mach_host.h>

#include <netinet/in.h>
#include <sys/sysctl.h>
#include <net/if.h>

#define CTL_NET         4               /* network, see socket.h */

#define ROUNDUP(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

@interface CCSystemStatusSection : NSObject <CCSection, CCSystemStatusSectionDelegate>

@end
