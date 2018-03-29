//
//  CAISDSAspects.h
//  CAISDSAspects - A delightful, simple library for CAISDSAspect oriented programming.
//
//  Copyright (c) 2014 Peter Steinberger. Licensed under the MIT license.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, CAISDSAspectOptions) {
    CAISDSAspectPositionAfter   = 0,            /// Called after the original implementation (default)
    CAISDSAspectPositionInstead = 1,            /// Will replace the original implementation.
    CAISDSAspectPositionBefore  = 2,            /// Called before the original implementation.
    
    CAISDSAspectOptionAutomaticRemoval = 1 << 3 /// Will remove the hook after the first execution.
};

/// Opaque CAISDSAspect Token that allows to deregister the hook.
@protocol CAISDSAspectToken <NSObject>

/// Deregisters an CAISDSAspect.
/// @return YES if deregistration is successful, otherwise NO.
- (BOOL)remove;

@end

/// The CAISDSAspectInfo protocol is the first parameter of our block syntax.
@protocol CAISDSAspectInfo <NSObject>

/// The instance that is currently hooked.
- (id)instance;

/// The original invocation of the hooked method.
- (NSInvocation *)originalInvocation;

/// All method arguments, boxed. This is lazily evaluated.
- (NSArray *)arguments;

@end

/**
 CAISDSAspects uses Objective-C message forwarding to hook into messages. This will create some overhead. Don't add CAISDSAspects to methods that are called a lot. CAISDSAspects is meant for view/controller code that is not called a 1000 times per second.

 Adding CAISDSAspects returns an opaque token which can be used to deregister again. All calls are thread safe.
 */
@interface NSObject (CAISDSAspects)

/// Adds a block of code before/instead/after the current `selector` for a specific class.
///
/// @param block CAISDSAspects replicates the type signature of the method being hooked.
/// The first parameter will be `id<CAISDSAspectInfo>`, followed by all parameters of the method.
/// These parameters are optional and will be filled to match the block signature.
/// You can even use an empty block, or one that simple gets `id<CAISDSAspectInfo>`.
///
/// @note Hooking static methods is not supported.
/// @return A token which allows to later deregister the CAISDSAspect.
+ (id<CAISDSAspectToken>)CAISDSAspect_hookSelector:(SEL)selector
                           withOptions:(CAISDSAspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

/// Adds a block of code before/instead/after the current `selector` for a specific instance.
- (id<CAISDSAspectToken>)CAISDSAspect_hookSelector:(SEL)selector
                           withOptions:(CAISDSAspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

@end


typedef NS_ENUM(NSUInteger, CAISDSAspectErrorCode) {
    CAISDSAspectErrorSelectorBlacklisted,                   /// Selectors like release, retain, autorelease are blacklisted.
    CAISDSAspectErrorDoesNotRespondToSelector,              /// Selector could not be found.
    CAISDSAspectErrorSelectorDeallocPosition,               /// When hooking dealloc, only CAISDSAspectPositionBefore is allowed.
    CAISDSAspectErrorSelectorAlreadyHookedInClassHierarchy, /// Statically hooking the same method in subclasses is not allowed.
    CAISDSAspectErrorFailedToAllocateClassPair,             /// The runtime failed creating a class pair.
    CAISDSAspectErrorMissingBlockSignature,                 /// The block misses compile time signature info and can't be called.
    CAISDSAspectErrorIncompatibleBlockSignature,            /// The block signature does not match the method or is too large.

    CAISDSAspectErrorRemoveObjectAlreadyDeallocated = 100   /// (for removing) The object hooked is already deallocated.
};

extern NSString *const CAISDSAspectErrorDomain;
