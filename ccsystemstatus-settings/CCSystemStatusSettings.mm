#import "CCSystemStatusSettings.h"

#define kCCSystemStatusSettingsPath [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Preferences/com.vsnrain.ccsystemstatus.plist"]

@implementation CCSystemStatusSettingsListController{
    NSMutableOrderedSet *_enabled;
    NSMutableOrderedSet *_disabled;
    
}
//////////////////////////////////// CLEAR MAKEFILE

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.title = @"CCSystemStatus";
        
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kCCSystemStatusSettingsPath];
        
        if(!prefs){
            _enabled = [NSMutableOrderedSet orderedSetWithArray:[NSArray arrayWithObjects:@"WIFI-IP_INT", @"CELL-IP_EXT", @"RAM", @"CPU", @"WIFI-SSID", @"WIFI-MAC", @"ROOT", @"VAR", nil]];
            
            NSMutableDictionary *newPrefs = [NSMutableDictionary dictionary];
            newPrefs[@"EnabledStatistics"] = _enabled.array;
            [newPrefs.copy writeToFile:kCCSystemStatusSettingsPath atomically:YES];
            prefs = newPrefs.copy;
        }else{
            _enabled = [NSMutableOrderedSet orderedSetWithArray:prefs[@"EnabledStatistics"]];
            _disabled = [NSMutableOrderedSet orderedSetWithArray:prefs[@"DisabledStatistics"]];
        }
        
        //_enabled = [NSMutableOrderedSet orderedSetWithArray:[NSArray arrayWithObjects:@"WIFI-IP_INT", @"CELL-IP_EXT", @"RAM", @"CPU", nil]];
        //_disabled = [NSMutableOrderedSet orderedSetWithArray:[NSArray arrayWithObjects:@"WIFI-SSID", @"WIFI-MAC", @"ROOT", @"VAR", nil]];
    }
    
    return self;
}

- (void)loadView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    self.view = tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setAllowsSelectionDuringEditing:YES];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.tableView setEditing:YES];
}


- (UITableView *)tableView {
    return (UITableView *)self.view;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if (_enabled.count == 0) return 1;
            return _enabled.count;
            break;
        case 1:
            if (_disabled.count ==0) return 1;
            return _disabled.count;
            break;
        case 2:
            return 0;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Enabled Statistics";
            break;
        case 1:
            return @"Disabled Statistics";
            break;
        case 3:
            return @"Settings";
            break;
            
        default:
            return @"";
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const cellID = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if ((indexPath.section == 0 && _enabled.count) || (indexPath.section == 1 && _disabled.count)) {
        
        NSString *internalName = (indexPath.section == 0 ? _enabled[indexPath.row] : _disabled[indexPath.row]);
        NSString *displayName;
        
        if ([internalName isEqualToString:@"WIFI-IP_INT"]){
            displayName = @"Internal WiFi IP";
        }else if ([internalName isEqualToString:@"CELL-IP_EXT"]){
            displayName = @"External cellular IP";
        }else if ([internalName isEqualToString:@"RAM"]){
            displayName = @"Free RAM";
        }else if ([internalName isEqualToString:@"CPU"]){
            displayName = @"System Load";
        }else if ([internalName isEqualToString:@"WIFI-SSID"]){
            displayName = @"WiFi Network SSID";
        }else if ([internalName isEqualToString:@"WIFI-MAC"]){
            displayName = @"WiFi MAC Address";
        }else if ([internalName isEqualToString:@"ROOT"]){
            displayName = @"Free space on root";
        }else if ([internalName isEqualToString:@"VAR"]){
            displayName = @"Free space on /private";
        }else{
            displayName = internalName;
        }
        
        cell.textLabel.text = displayName;
        cell.textLabel.alpha = 1.0f;
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
    
    }else {
        cell.textLabel.alpha = 0.5f;
        cell.textLabel.text = @"Empty";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section < 2);
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0 && _enabled.count) || (indexPath.section == 1 && _disabled.count)) {
        return NO;
    }
    else {
        return NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section < 2 && ((indexPath.section == 0 && _enabled.count) || (indexPath.section == 1 && _disabled.count)));
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section > 1) {
        return sourceIndexPath;
    }
    else if ((proposedDestinationIndexPath.section == 0 && !_enabled.count) || (proposedDestinationIndexPath.section == 1 && !_disabled.count)) {
        return [NSIndexPath indexPathForRow:0 inSection:proposedDestinationIndexPath.section];
    }
    else {
        return proposedDestinationIndexPath;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.tableView beginUpdates];
    
    BOOL clearRow = ((destinationIndexPath.section == 0 && !_enabled.count) || (destinationIndexPath.section == 1 && !_disabled.count));
    
    if (sourceIndexPath.section == 0) {
        NSString *sourceID = _enabled[sourceIndexPath.row];
        
        [_enabled removeObjectAtIndex:sourceIndexPath.row];
        
        if (destinationIndexPath.section == 0) {
            [_enabled insertObject:sourceID atIndex:destinationIndexPath.row];
        }
        else {
            [_disabled insertObject:sourceID atIndex:(clearRow ? 0 : destinationIndexPath.row)];
        }
    }
    else if (sourceIndexPath.section == 1) {
        NSString *sourceID = _disabled[sourceIndexPath.row];
        
        [_disabled removeObjectAtIndex:sourceIndexPath.row];
        
        if (destinationIndexPath.section == 1) {
            [_disabled insertObject:sourceID atIndex:destinationIndexPath.row];
        }
        else {
            [_enabled insertObject:sourceID atIndex:(clearRow ? 0 : destinationIndexPath.row)];
        }
    }
    
    if (clearRow) {
        NSIndexPath *remove = [NSIndexPath indexPathForRow:destinationIndexPath.section inSection:destinationIndexPath.section];
        
        [self.tableView deleteRowsAtIndexPaths:@[remove] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    BOOL insertRow = ((sourceIndexPath.section == 0 && !_enabled.count) || (sourceIndexPath.section == 1 && !_disabled.count));
    
    if (insertRow) {
        NSIndexPath *add = [NSIndexPath indexPathForRow:0 inSection:sourceIndexPath.section];
        
        [self.tableView insertRowsAtIndexPaths:@[add] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
    
    [self syncPrefs:YES];
}

- (void)syncPrefs:(BOOL)notificate {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
    
    if (_enabled) {
        prefs[@"EnabledStatistics"] = _enabled.array;
    }
    
    if (_disabled.count) {
        prefs[@"DisabledStatistics"] = _disabled.array;
    }
    
    /*
    if (_setting) {
        prefs[@"settingKey"] = @(YES);
    }
    */
    
    [prefs.copy writeToFile:kCCSystemStatusSettingsPath atomically:YES];
    
    if (notificate) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.vsnrain.ccsystemstatus.settingschanged"),  NULL, NULL, true);
    }
}

@end

