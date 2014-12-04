//
//  UATPActivityMail.m
//  ThirdPartyActivities
//
//  Created by Rob Amos on 3/12/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import "UATPActivityMail.h"
#import "NSURL+UAQueryStringDictionary.h"
#import "UATPPrivateURL.h"

@import MessageUI;

@interface UATPActivityMail () <MFMailComposeViewControllerDelegate>

@property (nonatomic, copy) NSArray *items;

@end

@implementation UATPActivityMail

@synthesize items=_items;

/**
 * Configuration
 **/

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return @"com.unsignedapps.thirdpartyactivities.mail";
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"action-title-send-mail", @"UATPLocalizable", @"Action Title for Sending Mail");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"send-mail"];
}

/**
 * Supporting Activity Items
 **/

+ (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (activityItems == nil || [activityItems count] == 0)
        return NO;
    
    // check if we have a URL in here
    for (id item in activityItems)
    {
        NSURL *url = nil;
        
        if ([item isKindOfClass:[NSURL class]])
            url = (NSURL *)item;
        
        else if ([item isKindOfClass:[NSString class]])
            url = [NSURL URLWithString:item];

        else if ([item isKindOfClass:[UATPPrivateURL class]])
            url = ((UATPPrivateURL *)item).url;

        // if we have a URL we can check it
        if (url != nil)
        {
            // not a supported URL?
            if (![url.scheme isEqualToString:@"mailto"])
                continue;
            
            // make sure we can open it
            return [MFMailComposeViewController canSendMail];
        }
    }
    
    return NO;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return [self.class canPerformWithActivityItems:activityItems];
}

/**
 * Performing the Activity
 **/

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    [self setItems:activityItems];
}

- (void)performActivity
{
    if (self.items == nil || [self.items count] == 0)
    {
        [self activityDidFinish:NO];
        return;
    }
    
    // find the first thing that can be a URL
    for (id item in self.items)
    {
        NSURL *url = nil;
        
        if ([item isKindOfClass:[NSURL class]])
            url = (NSURL *)item;
        
        else if ([item isKindOfClass:[NSString class]])
            url = [NSURL URLWithString:item];
        
        if (url == nil)
            continue;
        
        // supported scheme?
        if (![url.scheme isEqualToString:@"mailto"])
            continue;
        
        if (![MFMailComposeViewController canSendMail])
        {
            // if its not supported we can't recover with any other URL type
            [self activityDidFinish:NO];
            return;
        }
        
        // now go!
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        
        [controller setToRecipients:@[ url.resourceSpecifier ?: @"" ]];
        
        NSDictionary *query = url.UAQueryDictionary;
        
        if (query[@"cc"] != nil)
            [controller setCcRecipients:[query[@"cc"] componentsSeparatedByString:@","]];
        
        if (query[@"subject"] != nil)
            [controller setSubject:query[@"subject"]];
        
        if (query[@"body"] != nil)
            [controller setMessageBody:query[@"body"] isHTML:NO];
        
        [controller setMailComposeDelegate:self];
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:controller animated:YES completion:NULL];
        
        return;
    }
    
    [self activityDidFinish:NO];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    [self activityDidFinish:YES];
}

@end
