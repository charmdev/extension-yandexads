#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "YandexAdsEx.h"

using namespace yandexadsex;

AutoGCRoot* ya_adsEventHandle = 0;

#ifdef IPHONE

static void YAads_set_event_handle(value onEvent)
{
	ya_adsEventHandle = new AutoGCRoot(onEvent);
}
DEFINE_PRIM(YAads_set_event_handle, 1);

static value yandexadsex_init(value appkey){
	init(val_string(appkey));
	return alloc_null();
}
DEFINE_PRIM(yandexadsex_init,1);

static value yandexadsex_show_rewarded(){
	showRewarded();
	return alloc_null();
}
DEFINE_PRIM(yandexadsex_show_rewarded,0);

#endif

extern "C" void yandexadsex_main () {	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (yandexadsex_main);

extern "C" int yandexadsex_register_prims () { return 0; }

extern "C" void YAsendAdsEvent(const char* type)
{
	printf("Yandex Send Event: %s\n", type);
	value o = alloc_empty_object();
	alloc_field(o,val_id("type"),alloc_string(type));
	val_call1(ya_adsEventHandle->get(), o);
}
