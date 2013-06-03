#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"

#ifndef GSCAPABILITY_H
extern BOOL GSSystemHasCapability(CFStringRef capability);
#endif

#ifndef GSEVENT_H
extern void GSSendAppPreferencesChanged(CFStringRef bundleID, CFStringRef key);
#endif

#define kABSBackboardPlist [NSHomeDirectory() stringByAppendingString:@"/Library/Preferences/com.apple.backboardd.plist"]
#define kABSAutoBrightnessKey @"BKEnableALS"

@interface AutoBrightnessSwitch : NSObject <FSSwitchDataSource>
@end

@implementation AutoBrightnessSwitch

- (id)init
{
    if ((self = [super init])) {
        BOOL hasSensor = GSSystemHasCapability(CFSTR("ambient-light-sensor"));
        if (!hasSensor) {
            [self release];
            return nil;
        }
    }

    return self;
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:kABSBackboardPlist];
    BOOL enabled = ([dict objectForKey:kABSAutoBrightnessKey] && [[dict valueForKey:kABSAutoBrightnessKey] boolValue]);

    return enabled;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
    if (newState == FSSwitchStateIndeterminate)
        return;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:kABSBackboardPlist] ?: [[NSMutableDictionary alloc] init];
    NSNumber *value = [NSNumber numberWithBool:newState];
    [dict setValue:value forKey:kABSAutoBrightnessKey];
    [dict writeToFile:kABSBackboardPlist atomically:YES];
    [dict release];

    GSSendAppPreferencesChanged(CFSTR("com.apple.backboardd"), (CFStringRef)kABSAutoBrightnessKey);

}

@end