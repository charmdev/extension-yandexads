#include <YandexAdsEx.h>
#include "YAviewController.m"

namespace yandexadsex {
	
	static YAviewController *yaViewController;
	static NSString *appkey;

	void init(const char *__appkey) {
		appkey = [NSString stringWithUTF8String:__appkey];

		yaViewController = [YAviewController alloc];

		[yaViewController init:appkey];

	}

	void showRewarded() { 
		NSLog(@"%s", __PRETTY_FUNCTION__);
		[yaViewController showAd];
		
	}

}
