package extension.yandexads;

import nme.JNI;
import nme.Lib;

class YandexAds {

#if ios
	private static var __YAads_set_event_handle = Lib.load("yandexadsex","YAads_set_event_handle", 1);
#elseif android
	private static var instance:YandexAds = new YandexAds();
#end

	private static var initialized:Bool = false;
	public static var __init:YandexAds->String->Void = JNI.createStaticMethod("org/haxe/extension/yandexads/YandexAdsEx", "init", "(Lorg/haxe/lime/HaxeObject;Ljava/lang/String;)V");
	public static var __showRewarded:Void->Void = JNI.createStaticMethod("org/haxe/extension/yandexads/YandexAdsEx", "showRewarded", "()V");
	private static var completeCB:Void->Void;
	private static var skipCB:Void->Void;
	private static var viewCB:Void->Void;
	private static var clickCB:Void->Void;
	private static var canshow:Bool = false;
	public static var onRewardedEvent:String->Void = null;


	public static function init(appkey:String) {
		if (initialized) return;
		initialized = true;
#if android
		try {
			__init(instance, appkey);
		} catch(e:Dynamic) {
			trace("YandexAds REWARDED Error: "+e);
		}
#elseif ios
		try{
			var __init:String->Void = cpp.Lib.load("YandexAdsEx","yandexadsex_init",1);
			__showRewarded = cpp.Lib.load("YandexAdsEx","yandexadsex_show_rewarded",0);
			__init(appkey);

			__YAads_set_event_handle(ISnotifyListeners);
		}catch(e:Dynamic){
			trace("YandexAds REWARDED iOS INIT Exception: "+e);
		}
#end
	}

	public static function canShowAds():Bool {
		trace("YandexAds canShowAds", canshow);
		return canshow;
	}

	public static function showRewarded(cb, skip, displaying, click) {
		
		canshow = false;

		trace("YandexAds try showRewarded ");

		completeCB = cb;
		skipCB = skip;
		viewCB = displaying;
		clickCB = click;

		try {
			__showRewarded();
		} catch(e:Dynamic) {
			trace("YandexAds ShowRewarded Exception: " + e);
		}
	}

#if ios
	private static function ISnotifyListeners(inEvent:Dynamic)
	{
		var event:String = Std.string(Reflect.field(inEvent, "type"));

		if (event == "yandex_rewardedcanshow")
		{
			canshow = true;
			trace("YandexAds REWARDED CAN SHOW");
			return;
		}

		if (event == "yandex_rewardedcompleted")
		{
			trace("YandexAds REWARDED COMPLETED");
			dispatchEventIfPossibleIS("CLOSED");
			if (completeCB != null) completeCB();
		}
		else if (event == "yandex_rewardedskip")
		{
			trace("YandexAds REWARDED VIDEO IS SKIPPED");
			dispatchEventIfPossibleIS("CLOSED");
			if (skipCB != null) skipCB();
		}
		else if (event == "yandex_rewarded_displaying")
		{
			trace("YandexAds REWARDED VIDEO Displaying");
			dispatchEventIfPossibleIS("DISPLAY");
			if (viewCB != null) viewCB();
		}
		else if (event == "yandex_rewarded_click")
		{
			trace("YandexAds REWARDED VIDEO clicked");
			dispatchEventIfPossibleIS("CLICK");
			if (clickCB != null) clickCB();
		}
		
	}
#elseif android

	private function new() {}

	public function onRewardedCanShow()
	{
		canshow = true;
		trace("YandexAds REWARDED CAN SHOW");
	}

	public function onRewardedDisplaying()
	{
		trace("YandexAds REWARDED Displaying");
		dispatchEventIfPossibleIS("DISPLAY");
		if (viewCB != null) viewCB();
	}

	public function onRewardedClick()
	{
		trace("YandexAds REWARDED click");
		dispatchEventIfPossibleIS("CLICK");
		if (clickCB != null) clickCB();
	}

	public function onRewardedCompleted()
	{
		trace("YandexAds REWARDED COMPLETED");
		dispatchEventIfPossibleIS("CLOSED");
		if (completeCB != null) completeCB();
	}
	public function onVideoSkipped()
	{
		trace("YandexAds REWARDED VIDEO IS SKIPPED");
		dispatchEventIfPossibleIS("CLOSED");
		if (skipCB != null) skipCB();
	}
	
#end

	private static function dispatchEventIfPossibleIS(e:String):Void
	{
		if (onRewardedEvent != null) {
			onRewardedEvent(e);
		}
		else {
			trace('no event handler');
		}
	}
	
}
