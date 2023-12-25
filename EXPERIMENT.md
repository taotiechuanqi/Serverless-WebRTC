# EXPERIMENT

## Build

1. Install [depot_tools](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)
2. `sudo apt install python-is-python3` if don't have executable `python`
3. `make docker-sync` and wait tens of minutes
4. `make docker-peerconnection`

Artifacts are in `target/bin/` directory. We can use `peerconnection_gcc` to run with gcc.

## Run

`mkdir run` and `cp target/bin/peerconnection_gcc run/ && cd run`

### Prepare media

#### Related tools

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - Download video from Youtube
- [ffmpeg](https://ffmpeg.org/) - Convert video to raw format

**Attention:** [YUView](https://github.com/IENT/YUView) cannot properly play YUV videos in experiments. It is recommended to use a player based on ffmpeg instead.

#### Example Steps

``` bash
# Download video from Youtube
yt-dlp -f "bv[height<=?720]" https://www.youtube.com/watch?v=LXb3EKWsInQ -o "720p.%(ext)s"

# Cut video to 20 seconds
ffmpeg -i 720p.webm -t 20 -map 0 -c copy 720p-20s.webm

# Convert video to YUV format with 10fps frame rate
ffmpeg -i 720p-20s.webm -filter:v fps=10 -f yuv4mpegpipe -pix_fmt yuv420p 720p-20s.yuv

# Download audio
yt-dlp -f "ba" https://www.youtube.com/watch?v=LXb3EKWsInQ -o "sound.%(ext)s"

# Cut audio to 20 seconds
ffmpeg -i sound.webm -t 20 -map 0 -c copy sound-20s.webm

# Convert audio to wav format
ffmpeg -i sound-20s.webm sound-20s.wav

```

**Attention:**

1. When converting the video to YUV format, the video format should be **yuv4mpegpipe**, and the pixel format should be **yuv420p**.
2. The configuration file below only supports **integer** FPS.

### Configure

Refer to [README](./README.md) for more details.

In our experiment, we use `receiver_gcc.json` and `sender_gcc.json` as configuration files.

`receiver_gcc.json`

``` json
{
    "serverless_connection": {
        "autoclose": 20,
        "sender": {
            "enabled": false
        },
        "receiver": {
            "enabled": true,
            "listening_ip": "0.0.0.0",
            "listening_port": 8000
        }
    },
    "bwe_feedback_duration": 200,
    "video_source": {
        "video_disabled": {
            "enabled": true
        },
        "webcam": {
            "enabled": false
        },
        "video_file": {
            "enabled": false
        }
    },
    "audio_source": {
        "audio_disabled": {
            "enabled": false
        },
        "microphone": {
            "enabled": false
        },
        "audio_file": {
            "enabled": true,
            "file_path": "sound-20s.wav"
        }
    },
    "save_to_file": {
        "enabled": true,
        "audio": {
            "file_path": "outaudio.wav"
        },
        "video": {
            "width": 1280,
            "height": 720,
            "fps": 10,
            "file_path": "outvideo.yuv"
        }
    },
    "logging": {
        "enabled": true,
        "log_output_path": "receiver.log"
    }
}
```

`sender_gcc.json`

Please change `dest_ip` to the IP address of the receiver.

``` json
{
    "serverless_connection": {
        "autoclose": 20,
        "sender": {
            "enabled": true,
            "dest_ip": "100.64.0.1",
            "dest_port": 8000
        },
        "receiver": {
            "enabled": false
        }
    },
    "bwe_feedback_duration": 200,
    "video_source": {
        "video_disabled": {
            "enabled": false
        },
        "webcam": {
            "enabled": false
        },
        "video_file": {
            "enabled": true,
            "width": 1280,
            "height": 720,
            "fps": 10,
            "file_path": "720p-20s.yuv"
        }
    },
    "audio_source": {
        "microphone": {
            "enabled": false
        },
        "audio_file": {
            "enabled": true,
            "file_path": "sound-20s.wav"
        }
    },
    "save_to_file": {
        "enabled": false
    },
    "logging": {
        "enabled": true,
        "log_output_path": "sender.log"
    }
}
```

### Run experiment

Run receiver first, then run sender.

Receiver: `./peerconnection_gcc receiver_gcc.json`

Sender: `./peerconnection_gcc sender_gcc.json`

After 20 seconds, the program will exit automatically.

`outvideo.yuv` and `outaudio.wav` are the output files.

`receiver.log` and `sender.log` are the log files.

## Evaluate

TODO

## Current Problems

NONE
