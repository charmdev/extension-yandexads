package org.haxe.extension.yandexads;

import org.json.JSONObject;
import android.util.Log;
import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;
import android.opengl.GLSurfaceView;
import android.os.Handler;
import androidx.annotation.Keep;

import com.yandex.mobile.ads.common.InitializationListener;
import com.yandex.mobile.ads.common.MobileAds;

import com.yandex.mobile.ads.common.AdRequest;
import com.yandex.mobile.ads.common.AdRequestError;
import com.yandex.mobile.ads.rewarded.Reward;
import com.yandex.mobile.ads.rewarded.RewardedAd;
import com.yandex.mobile.ads.rewarded.RewardedAdEventListener;
import com.yandex.mobile.ads.common.ImpressionData;


public class YandexAdsEx extends Extension
{
	protected YandexAdsEx () { }

	protected static HaxeObject _callback = null;
	protected static String TAG = "YandexAds";
	protected static boolean giveReward = false;
	protected static boolean rewardSended = false;
	protected static boolean failRewarded = false;
	protected static RewardedAd mRewardedAd;
	protected static String blockID = null;
	

	public static void init(HaxeObject callback, String block_id) {
		_callback = callback;
		blockID = block_id;

		MobileAds.initialize(Extension.mainActivity, new InitializationListener() {
			@Override
			public void onInitializationCompleted() {
				Log.d(TAG, "SDK initialized");

				YandexAdsEx.loadRewardedAd();
			}
		});
	}

	public static void loadRewardedAd() {
		destroyRewardedAd();
		createRewardedAd();
		final AdRequest adRequest = new AdRequest.Builder().build();
		mRewardedAd.loadAd(adRequest);
	}

	public static void destroyRewardedAd() {
		if (mRewardedAd != null) {
			mRewardedAd.setRewardedAdEventListener(null);
			mRewardedAd.destroy();
			mRewardedAd = null;
		}
	}
	
	public static void createRewardedAd() {
		mRewardedAd = new RewardedAd(Extension.mainActivity);
		mRewardedAd.setBlockId(YandexAdsEx.blockID);

		Extension.mainActivity.runOnUiThread(new Runnable() {
			public void run() {
				
				mRewardedAd.setRewardedAdEventListener(
					new RewardedAdEventListener() {

						@Keep
						public void onImpression(final ImpressionData impressionData)
						{
							if (impressionData != null)
							{
								final String allData =  impressionData.getRawData(); 

								Log.d(TAG, "YANDEX rewarded onImpression " + allData);

								if (Extension.mainView == null) return;
								GLSurfaceView view = (GLSurfaceView) Extension.mainView;
								view.queueEvent(new Runnable() {
									public void run() {
										_callback.call1("onRewardedImpressionData", allData);
								}});
							}
							else
							{
								Log.d(TAG, "YANDEX rewarded onImpression == NULL");
							}
						}
						
						@Override
						public void onAdLoaded() {
							giveReward = false;
							rewardSended = false;

							if (Extension.mainView == null) return;
							GLSurfaceView view = (GLSurfaceView) Extension.mainView;
							view.queueEvent(new Runnable() {
								public void run() {
									_callback.call("onRewardedCanShow", new Object[] {});
							}});
						}
						
						@Override
						public void onRewarded(final Reward reward) {
							Log.d(TAG, "onRewardedVideoAdRewarded");
							
							giveReward = true;
							rewardSended = false;
						}
						
						@Override
						public void onAdFailedToLoad(final AdRequestError error) {
							Log.d(TAG, "onAdFailedToLoad " + error);
							giveReward = false;
							rewardSended = false;

							failRewarded = true;

							if (Extension.mainView == null) return;
							GLSurfaceView view = (GLSurfaceView) Extension.mainView;
							view.queueEvent(new Runnable() {
								public void run() {
									_callback.call("onVideoSkipped", new Object[] {});
							}});
						}
						
						@Override
						public void onAdShown() {
							Log.d(TAG, "onRewardedVideoAdShown");

							if (Extension.mainView == null) return;
							GLSurfaceView view = (GLSurfaceView) Extension.mainView;
							view.queueEvent(new Runnable() {
								public void run() {
									_callback.call("onRewardedDisplaying", new Object[] {});
							}});
						}
						
						@Override
						public void onAdDismissed() {
							
							Log.d(TAG, "onRewardedVideoAdDismissed " + giveReward + " " + rewardSended);

							if (giveReward && !rewardSended) {
								if (Extension.mainView == null) return;
								GLSurfaceView view = (GLSurfaceView) Extension.mainView;
								view.queueEvent(new Runnable() {
									public void run() {
										_callback.call("onRewardedCompleted", new Object[] {});
								}});

								Log.d(TAG, "onRewardedVideoAdClosed! giveReward");
							}
							else if (!giveReward && !rewardSended) {
								if (Extension.mainView == null) return;
								GLSurfaceView view = (GLSurfaceView) Extension.mainView;
								view.queueEvent(new Runnable() {
									public void run() {
										_callback.call("onVideoSkipped", new Object[] {});
								}});

								Log.d(TAG, "onRewardedVideoAdClosed! !giveReward");
							}

							giveReward = false;
							rewardSended = false;

							new Handler().postDelayed(new Runnable() {
								@Override
								public void run() {
									YandexAdsEx.loadRewardedAd();
								}
							}, 5000);
						}
						
						@Override
						public void onLeftApplication() {
							
						}
						
						@Override
						public void onReturnedToApplication() {
							
						}
					}
				);

			}
		});
	}

	public static void showRewarded() {
		if (failRewarded) {
			failRewarded = false;
			YandexAdsEx.loadRewardedAd();
			return;
		}

		if (!mRewardedAd.isLoaded()) return;
		
		Extension.mainActivity.runOnUiThread(new Runnable() {
			public void run() {
				mRewardedAd.show();
			}
		});
	}

}
