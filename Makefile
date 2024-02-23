.PHONY: all setup download convert-to-wav transcribe convert-to-video

# Default settings
DOCKER_ENABLED ?= yes
WHISPER_VERSION ?= 0b9af32a8b3fa7e2ae5f15a9a08f5b10394993f5
model ?= medium.en
lang ?= en
video_out = $(patsubst %.wav,%.mp4,$(input))

all: setup

setup:
	mkdir -p audios models
ifeq ($(DOCKER_ENABLED),no)
	[ ! -d "whisper.cpp" ] && git clone https://github.com/ggerganov/whisper.cpp.git && cd whisper.cpp && git checkout $(WHISPER_VERSION) ||:
	[ ! -f "whisper.cpp/main" ] && (cd whisper.cpp && make -j) ||:
endif

### Whisper in action

# Download available models. More info: https://github.com/ggerganov/whisper.cpp/tree/master/models#available-models
download:
ifeq ($(DOCKER_ENABLED),yes)
	docker run --rm -it -v $(CURDIR)/models:/models ghcr.io/ggerganov/whisper.cpp:main-$(WHISPER_VERSION) "./models/download-ggml-model.sh $(model) /models"
else
	./whisper.cpp/models/download-ggml-model.sh $(model) ./models
endif

transcribe:
ifeq ($(DOCKER_ENABLED),yes)
	docker run -it --rm -v $(CURDIR)/models:/models -v $(CURDIR)/audios:/audios ghcr.io/ggerganov/whisper.cpp:main-$(WHISPER_VERSION) "./main -m /models/ggml-$(model).bin -l $(lang) -f /$(file) -osrt -olrc -pc -pp" && mv -f $(file).lrc $(file).txt
else
	./whisper.cpp/main -m ./models/ggml-$(model).bin -l $(lang) -f $(CURDIR)/$(file) -osrt -olrc -pc -pp && mv -f $(file).lrc $(file).txt
endif

### FFmpeg utilities

# Ensure to convert input audio to .wav
convert-to-wav:
	ffmpeg -y -i $(input) -acodec pcm_s16le -ac 1 -ar 16000 $(output)

# Export transcription to video with subtitles
convert-to-video:
	ffmpeg -y -f lavfi -i color=c=black:s=1280x720:r=30 -i $(input) -vf subtitles=$(input).srt -c:a aac -shortest $(video_out) && rm -f $(input).srt
