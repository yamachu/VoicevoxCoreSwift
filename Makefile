all: Sources/VoicevoxCoreSwiftIOS/include/voicevox_core.h Sources/VoicevoxCoreSwiftMAC/include/voicevox_core.h

tmp:
	@mkdir -p $@

tmp/voicevox_core.h: TAG=
tmp/voicevox_core.h:
	gh api "repos/VOICEVOX/voicevox_core/contents/crates/voicevox_core_c_api/include/voicevox_core.h?ref=$(TAG)" --jq .content | base64 -d > $@

Sources/VoicevoxCoreSwiftIOS/include/voicevox_core.h: tmp/voicevox_core.h
	cp $< $@
	sed -i '' "s!//#define VOICEVOX_LINK_ONNXRUNTIME!#define VOICEVOX_LINK_ONNXRUNTIME!" $@

Sources/VoicevoxCoreSwiftMAC/include/voicevox_core.h: tmp/voicevox_core.h
	cp $< $@
	sed -i '' "s!//#define VOICEVOX_LOAD_ONNXRUNTIME!#define VOICEVOX_LOAD_ONNXRUNTIME!" $@
