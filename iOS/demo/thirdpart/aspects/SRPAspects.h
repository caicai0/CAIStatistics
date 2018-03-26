//
//  SRPAspects.h
//  SRPAspects - A delightful, simple library for SRPAspect oriented programming.
//
//  Copyright (c) 2014 Peter Steinberger. Licensed under the MIT license.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, SRPAspectOptions) {
    SRPAspectPositionAfter   = 0,            /// Called after the original implementation (default)
    SRPAspectPositionInstead = 1,            /// Will replace the original implementation.
    SRPAspectPositionBefore  = 2,            /// Called before the original implementation.
    
    SRPAspectOptionAutomaticRemoval = 1 << 3 /// Will remove the hook after the first execution.
};

/// Opaque SRPAspect Token that allows to deregister the hook.
@protocol SRPAspectToken <NSObject>

/// Deregisters an SRPAspect.
/// @return YES if deregistration is successful, otherwise NO.
- (BOOL)remove;

@end

/// The SRPAspectInfo protocol is the first parameter of our block syntax.
@protocol SRPAspectInfo <NSObject>

/// The instance that is currently hooked.
- (id)instance;

/// The original invocation of the hooked method.
- (NSInvocation *)originalInvocation;

/// All method arguments, boxed. This is lazily evaluated.
- (NSArray *)arguments;

@end

/**
 SRPAspects uses Objective-C message forwarding to hook into messages. This will create some overhead. Don't add SRPAspects to methods that are called a lot. SRPAspects is meant for view/controller code that is not called a 1000 times per second.

 Adding SRPAspects returns an opaque token which can be used to deregister again. All calls are thread safe.
 */
@interface NSObject (SRPAspects)

/// Adds a block of code before/instead/after the current `selector` for a specific class.
///
/// @param block SRPAspects replicates the type signature of the method being hooked.
/// The first parameter will be `id<SRPAspectInfo>`, followed by all parameters of the method.
/// These parameters are optional and will be filled to match the block signature.
/// You can even use an empty block, or one that simple gets `id<SRPAspectInfo>`.
///
/// @note Hooking static methods is not supported.
/// @return A token which allows to later deregister the SRPAspect.
+ (id<SRPAspectToken>)SRPAspect_hookSelector:(SEL)selector
                           withOptions:(SRPAspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

/// Adds a block of code before/instead/after the current `selector` for a specific instance.
- (id<SRPAspectToken>)SRPAspect_hookSelector:(SEL)selector
                           withOptions:(SRPAspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

@end


typedef NS_ENUM(NSUInteger, SRPAspectErrorCode) {
    SRPAspectErrorSelectorBlacklisted,                   /// Selectors like release, retain, autorelease are blacklisted.
    SRPAspectErrorDoesNotRespondToSelector,              /// Selector could not be found.
    SRPAspectErrorSelectorDeallocPosition,               /// When hooking dealloc, only SRPAspectPositionBefore is allowed.
    SRPAspectErrorSelectorAlreadyHookedInClassHierarchy, /// Statically hooking the same method in subclasses is not allowed.
    SRPAspectErrorFailedToAllocateClassPair,             /// The runtime failed creating a class pair.
    SRPAspectErrorMissingBlockSignature,                 /// The block misses compile time signature info and can't be called.
    SRPAspectErrorIncompatibleBlockSignature,            /// The block signature does not match the method or is too large.

    SRPAspectErrorRemoveObjectAlreadyDeallocated = 100   /// (for removing) The object hooked is already deallocated.
};

extern NSString *const SRPAspectErrorDomain;
