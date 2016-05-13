//
//  CCSystemStatusSection.m
//  CCSystemStatus
//
//  Created by vsnRain on 25.01.2014.
//  Copyright (c) 2014 vsnRain. All rights reserved.
//

#import "CCSystemStatusSection.h"

#define kCCSystemStatusSettingsPath [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Preferences/com.vsnrain.ccsystemstatus.plist"]

@interface CCSystemStatusSection ()

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) CCSystemStatusSectionView *view;
@property (nonatomic, weak) UIViewController <CCSectionDelegate> *delegate;

@end

@implementation CCSystemStatusSection{
    NSTimer *timer;
}

int screenMode;

NSMutableOrderedSet *_enabled;
NSMutableOrderedSet *_disabled;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bundle = [NSBundle bundleForClass:[self class]];
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadSections, CFSTR("com.vsnrain.ccsystemstatus.settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        reloadSections();
        screenMode = 0;
    }
    return self;
}

- (CGFloat)sectionHeight {
    return 72.0f;
}

- (void)loadView {
    self.view = [[CCSystemStatusSectionView alloc] init];
    self.view.delegate = self;
    [self.view.screenButton addTarget:self action:@selector(screenTouched) forControlEvents:UIControlEventTouchDown];
}

- (UIView *)view {
    if (!_view) {
        [self loadView];
    }
    
    return _view;
}

void reloadSections(void){
    
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kCCSystemStatusSettingsPath];
    //NSSet *statistics = [NSSet setWithArray:[NSArray arrayWithObjects:@"WIFI-IP_INT", @"CELL-IP_EXT", @"RAM", @"CPU", @"WIFI-SSID", @"WIFI-MAC", @"ROOT", @"VAR", nil]];
    
    if(!prefs){
        _enabled = [NSMutableOrderedSet orderedSetWithArray:[NSArray arrayWithObjects:@"WIFI-IP_INT", @"CELL-IP_EXT", @"RAM", @"CPU", @"WIFI-SSID", @"WIFI-MAC", @"ROOT", @"VAR", nil]];
        
        NSMutableDictionary *newPrefs = [NSMutableDictionary dictionary];
        newPrefs[@"EnabledStatistics"] = _enabled.array;
        [newPrefs.copy writeToFile:kCCSystemStatusSettingsPath atomically:YES];
        prefs = newPrefs.copy;
    }else{
        _enabled = [NSMutableOrderedSet orderedSetWithArray:prefs[@"EnabledStatistics"]];
    }
    
    screenMode = 0;
}

- (void)controlCenterWillAppear {
    if (!timer){
        timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    }
    [timer fire];
}

- (void)controlCenterDidDisappear {
    if (timer){
        [timer invalidate];
        timer = nil;
    }
}

- (void) screenTouched{
    if (screenMode < ceil(_enabled.count/4.0f)-1) screenMode++;
    else screenMode = 0;
    
    [UIView transitionWithView:self.view duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.view hideAll];
        [self refresh];
    } completion:NULL];
}

-(void) refresh{
    
    for (int i = 0; i<=MIN(_enabled.count-(4*screenMode)-1, 3); i++){
        int k = 4*screenMode + i;
        
        [self.view unhide:i withImage:_enabled[k]];
        
        if ([_enabled[k] isEqualToString:@"WIFI-IP_INT"]){
            [self refreshIPwifi:self.view.screenLabel[i] cell:nil];
        }else if ([_enabled[k] isEqualToString:@"CELL-IP_EXT"]){
            [self refreshIPwifi:nil cell:self.view.screenLabel[i]];
        }else if ([_enabled[k] isEqualToString:@"RAM"]){
            [self refreshRam:self.view.screenLabel[i]];
        }else if ([_enabled[k] isEqualToString:@"CPU"]){
            [self refreshCpuLoad:self.view.screenLabel[i]];
        }else if ([_enabled[k] isEqualToString:@"WIFI-SSID"]){
            [self refreshSSID:self.view.screenLabel[i]];
        }else if ([_enabled[k] isEqualToString:@"WIFI-MAC"]){
            [self refreshSSIDMAC:self.view.screenLabel[i]];
        }else if ([_enabled[k] isEqualToString:@"ROOT"]){
            [self refreshRootFree:self.view.screenLabel[i]];
        }else if ([_enabled[k] isEqualToString:@"VAR"]){
            [self refreshVarFree:self.view.screenLabel[i]];
        }
    }
}

-(void) refreshIPwifi:(UILabel *)label1 cell:(UILabel *)label2{
    NSString* wifiIP = @"N/A";
    NSString* dataIP = @"N/A";
    
    struct ifaddrs *temp_addr = NULL;
    
    if (!getifaddrs(&temp_addr)) {
        // Loop through linked list of interfaces
        //temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    wifiIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }else if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"]) {
                    dataIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(temp_addr);
    
    label1.text = wifiIP;
    label2.text = dataIP;
}

-(void) refreshRam:(UILabel *)label{
    NSString* ramStr;
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS){
        ramStr = @"N/A";
    }else{
        //pagesize = 4096;
        host_page_size(host_port, &pagesize);
        //pagesize = getpagesize();
        
        natural_t bytes = (vm_stat.free_count * pagesize);
        float mbytes = bytes/1048576.f;
        
        ramStr = [NSString stringWithFormat:@"%.1f MB", mbytes];
    }
    
    label.text = ramStr;
}

-(void) refreshCpuLoad:(UILabel *)label{
    double load[3];
    if (getloadavg(load, 3) == -1) label.text = @"N/A";
    label.text = [NSString stringWithFormat:@"%.2f %.2f %.2f", load[0], load[1], load[2]];
}

-(void) refreshSSID:(UILabel *)label{
    CFArrayRef myArray = CNCopySupportedInterfaces();
    CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
    
    NSString* wifiName = @"N/A";
    if (myDict) wifiName = CFDictionaryGetValue(myDict, kCNNetworkInfoKeySSID);
    
    label.text = wifiName;
}

-(void) refreshSSIDMAC:(UILabel *)label{
    in_addr_t addr;
    int res = getdefaultgateway(&addr);
    if (res==0) {
        label.text = [self ip2mac:addr];
    }else{
        label.text = @"N/A";
    }
    //NSLog([NSString stringWithUTF8String:inet_ntoa(addr)]);
}

-(void) refreshRootFree:(UILabel *)label{
    uint64_t rootFreeSpace = 0;
    
    NSDictionary *rootDictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/" error: nil];
    
    if (rootDictionary) {
        rootFreeSpace = [[rootDictionary objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
        float mb = rootFreeSpace/1000000.f;
        
        if (mb < 1000) label.text = [NSString stringWithFormat:@"%.1f MB", mb];
        else label.text = [NSString stringWithFormat:@"%.1f GB", mb/1000.f];
    }else {
        label.text = @"N/A";
    }
}

-(void) refreshVarFree:(UILabel *)label{
    uint64_t varFreeSpace = 0;
    
    NSDictionary *varDictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/var/" error: nil];
    
    if (varDictionary) {
        varFreeSpace = [[varDictionary objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
        float mb = varFreeSpace/1000000.f;
        
        if (mb < 1000) label.text = [NSString stringWithFormat:@"%.1f MB", mb];
        else label.text = [NSString stringWithFormat:@"%.1f GB", mb/1000.f];
    }else {
        label.text = @"N/A";
    }
}

int getdefaultgateway(in_addr_t *addr)
{
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
        NET_RT_FLAGS, RTF_GATEWAY};
    size_t l;
    char * buf, * p;
    struct rt_msghdr * rt;
    struct sockaddr * sa;
    struct sockaddr * sa_tab[RTAX_MAX];
    int i;
    int r = -1;
    if(sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
        return -1;
    }
    if(l>0) {
        buf = malloc(l);
        if(sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
            return -1;
        }
        for(p=buf; p<buf+l; p+=rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for(i=0; i<RTAX_MAX; i++) {
                if(rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }
            
            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
               && sa_tab[RTAX_DST]->sa_family == AF_INET
               && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                
                
                if(((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    char ifName[128];
                    if_indextoname(rt->rtm_index,ifName);
                    
                    if(strcmp("en0", ifName)==0){
                        
                        *addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                        r = 0;
                        
                        //*addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr;
                        //NSString *test = ip2mac(((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr);
                        //ip2mac(addr);
                    }
                }
            }
        }
        free(buf);
    }
    return r;
}

- (NSString*)ip2mac:(in_addr_t)addr
{
    NSString *ret = nil;
    
    size_t needed;
    char *buf, *next;
    
    struct rt_msghdr *rtm;
    struct sockaddr_inarp *sin;
    struct sockaddr_dl *sdl;
    
    int mib[6];
    
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_INET;
    mib[4] = NET_RT_FLAGS;
    mib[5] = RTF_LLINFO;
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &needed, NULL, 0) < 0) return @"N/A"; //err(1, "route-sysctl-estimate");
    
    if ((buf = (char*)malloc(needed)) == NULL) return @"N/A"; //err(1, "malloc");
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), buf, &needed, NULL, 0) < 0) return @"N/A"; //err(1, "retrieval of routing table");
    
    for (next = buf; next < buf + needed; next += rtm->rtm_msglen) {
        
        rtm = (struct rt_msghdr *)next;
        sin = (struct sockaddr_inarp *)(rtm + 1);
        sdl = (struct sockaddr_dl *)(sin + 1);
        
        if (addr != sin->sin_addr.s_addr || sdl->sdl_alen < 6)
            continue;
        
        u_char *cp = (u_char*)LLADDR(sdl);
        
        ret = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]];
        break;
    }
    
    free(buf);
    return ret;
}

@end
