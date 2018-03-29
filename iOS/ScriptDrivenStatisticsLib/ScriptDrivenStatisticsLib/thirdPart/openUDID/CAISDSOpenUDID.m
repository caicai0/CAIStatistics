//
//  CAISDSOpenUDID.m
//  openudid
//
//  initiated by Yann Lechelle (cofounder @Appsfire) on 8/28/11.
//  Copyright 2011, 2012 CAISDSOpenUDID.org
//
//  Initiators/root branches
//      iOS code: https://github.com/ylechelle/CAISDSOpenUDID
//      Android code: https://github.com/vieux/CAISDSOpenUDID
//
//  Contributors:
//      https://github.com/ylechelle/CAISDSOpenUDID/contributors
//

/*
 http://en.wikipedia.org/wiki/Zlib_License
 
 This software is provided 'as-is', without any express or implied
 warranty. In no event will the authors be held liable for any damages
 arising from the use of this software.
 
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must not
 claim that you wrote the original software. If you use this software
 in a product, an acknowledgment in the product documentation would be
 appreciated but is not required.
 
 2. Altered source versions must be plainly marked as such, and must not be
 misrepresented as being the original software.
 
 3. This notice may not be removed or altered from any source
 distribution.
*/

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "CAISDSOpenUDID.h"
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIPasteboard.h>
#import <UIKit/UIKit.h>
#else
#import <AppKit/NSPasteboard.h>
#endif

#define CAISDSOpenUDIDLog(fmt, ...)
//#define CAISDSOpenUDIDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
//#define CAISDSOpenUDIDLog(fmt, ...) NSLog((@"[Line %d] " fmt), __LINE__, ##__VA_ARGS__);

static NSString * kCAISDSOpenUDIDSessionCache = nil;
static NSString * const kCAISDSOpenUDIDDescription = @"CAISDSOpenUDID_with_iOS6_Support";
static NSString * const kCAISDSOpenUDIDKey = @"CAISDSOpenUDID";
static NSString * const kCAISDSOpenUDIDSlotKey = @"CAISDSOpenUDID_slot";
static NSString * const kCAISDSOpenUDIDAppUIDKey = @"CAISDSOpenUDID_appUID";
static NSString * const kCAISDSOpenUDIDTSKey = @"CAISDSOpenUDID_createdTS";
static NSString * const kCAISDSOpenUDIDOOTSKey = @"CAISDSOpenUDID_optOutTS";
static NSString * const kCAISDSOpenUDIDDomain = @"org.CAISDSOpenUDID";
static NSString * const kCAISDSOpenUDIDSlotPBPrefix = @"org.CAISDSOpenUDID.slot.";
static int const kCAISDSOpenUDIDRedundancySlots = 100;

@interface CAISDSOpenUDID (Private)
+ (void) _setDict:(id)dict forPasteboard:(id)pboard;
+ (NSMutableDictionary*) _getDictFromPasteboard:(id)pboard;
+ (NSString*) _generateFreshCAISDSOpenUDID;
@end

@implementation CAISDSOpenUDID

// Archive a NSDictionary inside a pasteboard of a given type
// Convenience method to support iOS & Mac OS X
//
+ (void) _setDict:(id)dict forPasteboard:(id)pboard {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR		
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict] forPasteboardType:kCAISDSOpenUDIDDomain];
#else
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict] forType:kCAISDSOpenUDIDDomain];
#endif
}

// Retrieve an NSDictionary from a pasteboard of a given type
// Convenience method to support iOS & Mac OS X
//
+ (NSMutableDictionary*) _getDictFromPasteboard:(id)pboard {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR	
    id item = [pboard dataForPasteboardType:kCAISDSOpenUDIDDomain];
#else
	id item = [pboard dataForType:kCAISDSOpenUDIDDomain];
#endif	
    if (item) {
        @try{
            item = [NSKeyedUnarchiver unarchiveObjectWithData:item];
        } @catch(NSException* e) {
            CAISDSOpenUDIDLog(@"Unable to unarchive item %@ on pasteboard!", [pboard name]);
            item = nil;
        }
    }
    
    // return an instance of a MutableDictionary 
    return [NSMutableDictionary dictionaryWithDictionary:(item == nil || [item isKindOfClass:[NSDictionary class]]) ? item : nil];
}

// Private method to create and return a new CAISDSOpenUDID
// Theoretically, this function is called once ever per application when calling [CAISDSOpenUDID value] for the first time.
// After that, the caching/pasteboard/redundancy mechanism inside [CAISDSOpenUDID value] returns a persistent and cross application CAISDSOpenUDID
//
+ (NSString*) _generateFreshCAISDSOpenUDID {
    
    NSString* _openUDID = nil;
    
    // August 2011: One day, this may no longer be allowed in iOS. When that is, just comment this line out.
    // March 25th 2012: this day has come, let's remove this "outlawed" call...
    // August 2012: well, perhaps much ado about nothing; in any case WWDC2012 gave us something to work with; read below
#if TARGET_OS_IPHONE	
//    if([UIDevice instancesRespondToSelector:@selector(uniqueIdentifier)]){
//        _openUDID = [[UIDevice currentDevice] uniqueIdentifier];
//    }
#endif
    
    //
    // !!!!! IMPORTANT README !!!!!
    //
    // August 2012: iOS 6 introduces new APIs that help us deal with the now deprecated [UIDevice uniqueIdentifier]
    // Since iOS 6 is still pre-release and under NDA, the following piece of code is meant to produce an error at
    // compile time. Accredited developers integrating CAISDSOpenUDID are expected to review the iOS 6 release notes and
    // documentation, and replace the underscore ______ in the last part of the selector below with the right
    // selector syntax as described here (make sure to use the right one! last word starts with the letter "A"):
    // https://developer.apple.com/library/prerelease/ios/#documentation/UIKit/Reference/UIDevice_Class/Reference/UIDevice.html
    //
    // The semantic compiler warnings are still normal if you are compiling for iOS 5 only since Xcode will not
    // know about the two instance methods used on that line; the code running on iOS will work well at run-time.
    // Either way, it's time that you junped on the iOS 6 bandwagon and start testing your code on iOS 6 ;-)
    //
    // WHAT IS THE SIGNIFICANCE OF THIS CHANGE?
    //
    // Essentially, this means that CAISDSOpenUDID will keep on behaving the same way as before for existing users or
    // new users in iOS 5 and before. For new users on iOS 6 and after, the new official public APIs will take over.
    // CAISDSOpenUDID will therefore be obsoleted when iOS reaches significant adoption, anticipated around mid-2013.

    /*

        September 14; ok, new development. The alleged API has moved!
        This part of the code will therefore be updated when iOS 6 is actually released.
        Nevertheless, if you want to go ahead, the code should be pretty easy to
        guess... it involves including a .h file from a nine-letter framework that ends
        with the word "Support", and then assigning _openUDID with the only identifier method called on the sharedManager of that new class... don't forget to add
        the framework to your project!
     
#if TARGET_OS_IPHONE
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        _openUDID = [[[UIDevice currentDevice] identifierForA_______] UUIDString];
# error                                                         ^ read comments above, fix accordingly, and remove this #error line
    }
#endif
    
     */
    
    // Next we generate a UUID.
    // UUIDs (Universally Unique Identifiers), also known as GUIDs (Globally Unique Identifiers) or IIDs
    // (Interface Identifiers), are 128-bit values guaranteed to be unique. A UUID is made unique over 
    // both space and time by combining a value unique to the computer on which it was generated—usually the
    // Ethernet hardware address—and a value representing the number of 100-nanosecond intervals since 
    // October 15, 1582 at 00:00:00.
    // We then hash this UUID with md5 to get 32 bytes, and then add 4 extra random bytes
    // Collision is possible of course, but unlikely and suitable for most industry needs (e.g. aggregate tracking)
    //
    if (_openUDID==nil) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
        unsigned char result[16];
        CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
        CFRelease(uuid);
        CFRelease(cfstring);

        _openUDID = [NSString stringWithFormat:
                     @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
                     result[0], result[1], result[2], result[3],
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15],
                     (unsigned long)(arc4random() % NSUIntegerMax)];
    }
    
    // Call to other developers in the Open Source community:
    //
    // feel free to suggest better or alternative "UDID" generation code above.
    // NOTE that the goal is NOT to find a better hash method, but rather, find a decentralized (i.e. not web-based)
    // 160 bits / 20 bytes random string generator with the fewest possible collisions.
    // 

    return _openUDID;
}


// Main public method that returns the CAISDSOpenUDID
// This method will generate and store the CAISDSOpenUDID if it doesn't exist, typically the first time it is called
// It will return the null udid (forty zeros) if the user has somehow opted this app out (this is subject to 3rd party implementation)
// Otherwise, it will register the current app and return the CAISDSOpenUDID
//
+ (NSString*) value {
    return [CAISDSOpenUDID valueWithError:nil];
}

+ (NSString*) valueWithError:(NSError **)error {

    if (kCAISDSOpenUDIDSessionCache!=nil) {
        if (error!=nil)
            *error = [NSError errorWithDomain:kCAISDSOpenUDIDDomain
                                         code:kCAISDSOpenUDIDErrorNone
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"CAISDSOpenUDID in cache from first call",@"description", nil]];
        return kCAISDSOpenUDIDSessionCache;
    }
    
  	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // The AppUID will uniquely identify this app within the pastebins
    //
    NSString * appUID = [defaults objectForKey:kCAISDSOpenUDIDAppUIDKey];
    if(appUID == nil)
    {
      // generate a new uuid and store it in user defaults
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        appUID = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
        CFRelease(uuid);
    }
  
    NSString* openUDID = nil;
    NSString* myRedundancySlotPBid = nil;
    NSDate* optedOutDate = nil;
    BOOL optedOut = NO;
    BOOL saveLocalDictToDefaults = NO;
    BOOL isCompromised = NO;
    
    // Do we have a local copy of the CAISDSOpenUDID dictionary?
    // This local copy contains a copy of the openUDID, myRedundancySlotPBid (and unused in this block, the local bundleid, and the timestamp)
    //
    id localDict = [defaults objectForKey:kCAISDSOpenUDIDKey];
    if ([localDict isKindOfClass:[NSDictionary class]]) {
        localDict = [NSMutableDictionary dictionaryWithDictionary:localDict]; // we might need to set/overwrite the redundancy slot
        openUDID = [localDict objectForKey:kCAISDSOpenUDIDKey];
        myRedundancySlotPBid = [localDict objectForKey:kCAISDSOpenUDIDSlotKey];
        optedOutDate = [localDict objectForKey:kCAISDSOpenUDIDOOTSKey];
        optedOut = optedOutDate!=nil;
        CAISDSOpenUDIDLog(@"localDict = %@",localDict);
    }
    
    // Here we go through a sequence of slots, each of which being a UIPasteboard created by each participating app
    // The idea behind this is to both multiple and redundant representations of CAISDSOpenUDIDs, as well as serve as placeholder for potential opt-out
    //
    NSString* availableSlotPBid = nil;
    NSMutableDictionary* frequencyDict = [NSMutableDictionary dictionaryWithCapacity:kCAISDSOpenUDIDRedundancySlots];
    for (int n=0; n<kCAISDSOpenUDIDRedundancySlots; n++) {
        NSString* slotPBid = [NSString stringWithFormat:@"%@%d",kCAISDSOpenUDIDSlotPBPrefix,n];
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        UIPasteboard* slotPB = [UIPasteboard pasteboardWithName:slotPBid create:NO];
#else
        NSPasteboard* slotPB = [NSPasteboard pasteboardWithName:slotPBid];
#endif
        CAISDSOpenUDIDLog(@"SlotPB name = %@",slotPBid);
        if (slotPB==nil) {
            // assign availableSlotPBid to be the first one available
            if (availableSlotPBid==nil) availableSlotPBid = slotPBid;
        } else {
            NSDictionary* dict = [CAISDSOpenUDID _getDictFromPasteboard:slotPB];
            NSString* oudid = [dict objectForKey:kCAISDSOpenUDIDKey];
            CAISDSOpenUDIDLog(@"SlotPB dict = %@",dict);
            if (oudid==nil) {
                // availableSlotPBid could inside a non null slot where no oudid can be found
                if (availableSlotPBid==nil) availableSlotPBid = slotPBid;
            } else {
                // increment the frequency of this oudid key
                int count = [[frequencyDict valueForKey:oudid] intValue];
                [frequencyDict setObject:[NSNumber numberWithInt:++count] forKey:oudid];
            }
            // if we have a match with the app unique id,
            // then let's look if the external UIPasteboard representation marks this app as OptedOut
            NSString* gid = [dict objectForKey:kCAISDSOpenUDIDAppUIDKey];
            if (gid!=nil && [gid isEqualToString:appUID]) {
                myRedundancySlotPBid = slotPBid;
                // the local dictionary is prime on the opt-out subject, so ignore if already opted-out locally
                if (optedOut) {
                    optedOutDate = [dict objectForKey:kCAISDSOpenUDIDOOTSKey];
                    optedOut = optedOutDate!=nil;   
                }
            }
        }
    }
    
    // sort the Frequency dict with highest occurence count of the same CAISDSOpenUDID (redundancy, failsafe)
    // highest is last in the list
    //
    NSArray* arrayOfUDIDs = [frequencyDict keysSortedByValueUsingSelector:@selector(compare:)];
    NSString* mostReliableCAISDSOpenUDID = (arrayOfUDIDs!=nil && [arrayOfUDIDs count]>0)? [arrayOfUDIDs lastObject] : nil;
    CAISDSOpenUDIDLog(@"Freq Dict = %@\nMost reliable %@",frequencyDict,mostReliableCAISDSOpenUDID);
        
    // if openUDID was not retrieved from the local preferences, then let's try to get it from the frequency dictionary above
    //
    if (openUDID==nil) {        
        if (mostReliableCAISDSOpenUDID==nil) {
            // this is the case where this app instance is likely to be the first one to use CAISDSOpenUDID on this device
            // we create the CAISDSOpenUDID, legacy or semi-random (i.e. most certainly unique)
            //
            openUDID = [CAISDSOpenUDID _generateFreshCAISDSOpenUDID];
        } else {
            // or we leverage the CAISDSOpenUDID shared by other apps that have already gone through the process
            // 
            openUDID = mostReliableCAISDSOpenUDID;
        }
        // then we create a local representation
        //
        if (localDict==nil) { 
            localDict = [NSMutableDictionary dictionaryWithCapacity:4];
            [localDict setObject:openUDID forKey:kCAISDSOpenUDIDKey];
            [localDict setObject:appUID forKey:kCAISDSOpenUDIDAppUIDKey];
            [localDict setObject:[NSDate date] forKey:kCAISDSOpenUDIDTSKey];
            if (optedOut) [localDict setObject:optedOutDate forKey:kCAISDSOpenUDIDTSKey];
            saveLocalDictToDefaults = YES;
        }
    }
    else {
        // Sanity/tampering check
        //
        if (mostReliableCAISDSOpenUDID!=nil && ![mostReliableCAISDSOpenUDID isEqualToString:openUDID])
            isCompromised = YES;
    }
    
    // Here we store in the available PB slot, if applicable
    //
    CAISDSOpenUDIDLog(@"Available Slot %@ Existing Slot %@",availableSlotPBid,myRedundancySlotPBid);
    if (availableSlotPBid!=nil && (myRedundancySlotPBid==nil || [availableSlotPBid isEqualToString:myRedundancySlotPBid])) {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        UIPasteboard* slotPB = [UIPasteboard pasteboardWithName:availableSlotPBid create:YES];
        [slotPB setPersistent:YES];
#else
        NSPasteboard* slotPB = [NSPasteboard pasteboardWithName:availableSlotPBid];
#endif
        
        // save slotPBid to the defaults, and remember to save later
        //
        if (localDict) {
            [localDict setObject:availableSlotPBid forKey:kCAISDSOpenUDIDSlotKey];
            saveLocalDictToDefaults = YES;
        }
        
        // Save the local dictionary to the corresponding UIPasteboard slot
        //
        if (openUDID && localDict)
            [CAISDSOpenUDID _setDict:localDict forPasteboard:slotPB];
    }

    // Save the dictionary locally if applicable
    //
    if (localDict && saveLocalDictToDefaults)
        [defaults setObject:localDict forKey:kCAISDSOpenUDIDKey];

    // If the UIPasteboard external representation marks this app as opted-out, then to respect privacy, we return the ZERO CAISDSOpenUDID, a sequence of 40 zeros...
    // This is a *new* case that developers have to deal with. Unlikely, statistically low, but still.
    // To circumvent this and maintain good tracking (conversion ratios, etc.), developers are invited to calculate how many of their users have opted-out from the full set of users.
    // This ratio will let them extrapolate convertion ratios more accurately.
    //
    if (optedOut) {
        if (error!=nil) *error = [NSError errorWithDomain:kCAISDSOpenUDIDDomain
                                                     code:kCAISDSOpenUDIDErrorOptedOut
                                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Application with unique id %@ is opted-out from CAISDSOpenUDID as of %@",appUID,optedOutDate],@"description", nil]];
            
        kCAISDSOpenUDIDSessionCache = [NSString stringWithFormat:@"%040x",0];
        return kCAISDSOpenUDIDSessionCache;
    }

    // return the well earned openUDID!
    //
    if (error!=nil) {
        if (isCompromised)
            *error = [NSError errorWithDomain:kCAISDSOpenUDIDDomain
                                         code:kCAISDSOpenUDIDErrorCompromised
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Found a discrepancy between stored CAISDSOpenUDID (reliable) and redundant copies; one of the apps on the device is most likely corrupting the CAISDSOpenUDID protocol",@"description", nil]];
        else
            *error = [NSError errorWithDomain:kCAISDSOpenUDIDDomain
                                         code:kCAISDSOpenUDIDErrorNone
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"CAISDSOpenUDID succesfully retrieved",@"description", nil]];
    }
    kCAISDSOpenUDIDSessionCache = openUDID;
    return kCAISDSOpenUDIDSessionCache;
}

+ (void) setOptOut:(BOOL)optOutValue {

    // init call
    [CAISDSOpenUDID value];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // load the dictionary from local cache or create one
    id dict = [defaults objectForKey:kCAISDSOpenUDIDKey];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    } else {
        dict = [NSMutableDictionary dictionaryWithCapacity:2];
    }

    // set the opt-out date or remove key, according to parameter
    if (optOutValue)
        [dict setObject:[NSDate date] forKey:kCAISDSOpenUDIDOOTSKey];
    else
        [dict removeObjectForKey:kCAISDSOpenUDIDOOTSKey];

  	// store the dictionary locally
    [defaults setObject:dict forKey:kCAISDSOpenUDIDKey];
    
    CAISDSOpenUDIDLog(@"Local dict after opt-out = %@",dict);
    
    // reset memory cache 
    kCAISDSOpenUDIDSessionCache = nil;
    
}

@end
