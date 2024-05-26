# Whisper

[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

Personal Makefile that provides a set of commands to manage the transcription and conversion process of audio files using [whisper.cpp](https://github.com/ggerganov/whisper.cpp). It supports both Docker-based and native execution.

## Requirements

- [Make](https://www.gnu.org/software/make/)
- [Docker](https://docs.docker.com/get-docker/)
- [FFmpeg](https://www.ffmpeg.org/download.html)

## Usage

Clone the repository and initialize the required dependencies:

```shell
make setup
```

**Optionally**, if you want AMD ROCm support to use your AMD GPU* just run:

```shell
WHISPER_HIPBLAS=1 make setup
```

*If your GPU is not officially supported don't forget to set the `HSA_OVERRIDE_GFX_VERSION` environment variable. More info [here](https://github.com/ollama/ollama/blob/main/docs/gpu.md#overrides).

### Download models

Downloads the necessary models for transcription:

```shell
make download
```

Download specific model (available model [here](https://github.com/ggerganov/whisper.cpp/tree/master/models#available-models)):

```shell
make download model=tiny
```

By default, it uses Docker. To disable Docker:

```shell
DOCKER_ENABLED=no make download model=tiny
```

### Convert to .wav (optional)

Converts an input audio file to WAV format (currently `whisper.cpp` runs only with 16-bit WAV files, so make sure to convert your input before running the tool):

```shell
make convert-to-wav input=audios/jfk.mp3 output=audios/jfk.wav
```

### Transcribe audio

Transcribes the `.wav` audio file under `audios` directory using the specified model and language:

```shell
make transcribe model=small.en lang=en file=audios/jfk.wav
```

By default, it utilizes Docker for transcription. To opt for native execution:

```shell
DOCKER_ENABLED=no make transcribe model=small.en lang=en file=audios/jfk.wav
```

To run in your unsupported AMD GPU, just override the LLVM target. Example:

```shell
HSA_OVERRIDE_GFX_VERSION=10.3.0 DOCKER_ENABLED=no make transcribe model=small.en lang=en file=audios/jfk.wav
```

All methods generate `.srt`, `.lrt` and `.txt` transcription files.

### Convert to video

Converts the transcribed text into a video file with subtitles:

```shell
make convert-to-video input=audios/jfk.wav
```

## Useful Links

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp)

## License

This project is licensed under the [MIT license](LICENSE).
