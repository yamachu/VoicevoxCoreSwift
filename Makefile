all: Sources/VoicevoxCoreSwiftIOS/include/voicevox_core.h Sources/VoicevoxCoreSwiftMAC/include/voicevox_core.h

tmp:
	@mkdir -p $@

FORCE:

tmp/voicevox_core.h: TAG=
tmp/voicevox_core.h: FORCE
	@mkdir -p tmp
	@if [ ! -f tmp/.tag ] || [ "$$(cat tmp/.tag)" != "$(TAG)" ]; then \
		gh api "repos/VOICEVOX/voicevox_core/contents/crates/voicevox_core_c_api/include/voicevox_core.h?ref=$(TAG)" --jq .content | base64 -d > $@; \
		echo "$(TAG)" > tmp/.tag; \
	fi

Sources/VoicevoxCoreSwiftIOS/include/voicevox_core.h: tmp/voicevox_core.h
	cp $< $@
	sed -i '' "s!//#define VOICEVOX_LINK_ONNXRUNTIME!#define VOICEVOX_LINK_ONNXRUNTIME!" $@

Sources/VoicevoxCoreSwiftMAC/include/voicevox_core.h: tmp/voicevox_core.h
	cp $< $@
	sed -i '' "s!//#define VOICEVOX_LOAD_ONNXRUNTIME!#define VOICEVOX_LOAD_ONNXRUNTIME!" $@
