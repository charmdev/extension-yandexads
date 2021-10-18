
#import "YAviewController.h"
#import <YandexMobileAds/YandexMobileAds.h>

@interface YAviewController () <YMARewardedAdDelegate>

@property (nonatomic, strong) YMARewardedAd *rewardedVideoAd;

@property (assign) BOOL giveReward;

@end

@implementation YAviewController

extern "C" void YAsendAdsEvent(const char* event);

- (void)init:(NSString *)rewardedid
{
	NSLog(@"Rewarded video LoadAd id %@", rewardedid);

	self.rewardedVideoAd = [[YMARewardedAd alloc] initWithBlockID:rewardedid];
	self.rewardedVideoAd.delegate = self;
	[self.rewardedVideoAd load];
}

- (void)reloadAd:(NSString *)rewardedid
{
	NSLog(@"Rewarded video RELOAD id %@", rewardedid);

	//[self.rewardedVideoAd release];

	self.rewardedVideoAd = [[YMARewardedAd alloc] initWithBlockID:rewardedid];
	//self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:rewardedid];
	self.rewardedVideoAd.delegate = self;
	[self.rewardedVideoAd load];

}

- (void)showAd
{
	//if (!self.rewardedVideoAd || !self.rewardedVideoAd.isAdValid)
	//{
	//   NSLog(@"Rewarded video Ad not loaded. Click load to request an ad");
	//} else
	{

		self.giveReward = false;
		
		UIViewController *root_ = [[[UIApplication sharedApplication] keyWindow] rootViewController];
		//[self.rewardedVideoAd showAdFromRootViewController:root_];
		[self.rewardedVideoAd presentFromViewController:root_];

		NSLog(@"Rewarded video ShowAd");
	}
}

#pragma mark - YMARewardedAdDelegate

- (void)rewardedAdDidLoad:(YMARewardedAd *)rewardedAd
{
	YAsendAdsEvent("rewardedcanshow");

	NSLog(@"Rewarded video ad was loaded. Can present now.");
}
- (void)rewardedAd:(YMARewardedAd *)rewardedAd didReward:(id<YMAReward>)reward
{
	self.giveReward = true;
	NSLog(@"Rewarded video was completed successfully.");

	//if (self.giveReward)
	{
		YAsendAdsEvent("rewardedcompleted");
	}
	//else
	{
	//	YAsendAdsEvent("rewardedskip");
	}

}
- (void)rewardedAd:(YMARewardedAd *)rewardedAd willPresentScreen:(UIViewController *)viewController
{
	NSLog(@"Rewarded video impression is being captured.");

	YAsendAdsEvent("rewarded_displaying");
}
- (void)rewardedAdDidFailToLoad:(YMARewardedAd *)rewardedAd error:(NSError *)error
{
	self.giveReward = false;
	NSLog(@"Rewarded Loading failed");
}
- (void)rewardedAdDidFailToPresentAd:(YMARewardedAd *)rewardedAd error:(NSError *)error
{
	self.giveReward = false;
	NSLog(@"Rewarded Failed to present rewarded ad.");
}






- (void)rewardedAdWillLeaveApplication:(YMARewardedAd *)rewardedAd
{
    NSLog(@"Rewarded ad will leave application");
}


- (void)rewardedAdWillAppear:(YMARewardedAd *)rewardedAd
{
    NSLog(@"Rewarded ad will appear");
}

- (void)rewardedAdDidAppear:(YMARewardedAd *)rewardedAd
{
    NSLog(@"Rewarded ad did appear");
}

- (void)rewardedAdWillDisappear:(YMARewardedAd *)rewardedAd
{
    NSLog(@"Rewarded ad will disappear");
}

- (void)rewardedAdDidDisappear:(YMARewardedAd *)rewardedAd
{
    NSLog(@"Rewarded ad did disappear");
}




@end
