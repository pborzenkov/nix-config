usage() {
  echo >&2 "whisper-subtitles [-b|--base-path PATH] [-m|--model MODEL] [-l|--lang LANG] <audio>"
  exit 1
}

BASE_PATH="/home/pbor/models/whisper"
MODEL="ggml-large-v3"
LANG="Dutch"
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -b|--base-path)
      BASE_PATH="$2"
      shift
      shift
      ;;
    -m|--model)
      MODEL="$2"
      shift
      shift
      ;;
    -l|--lang)
      LANG="$2"
      shift
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      usage
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}"

if [ $# -ne 1 ]; then
  usage
fi

TMP_WAV=$(mktemp /tmp/XXXXXXXXXX.wav)
ffmpeg -y -i "${1}" -ar 16000 -ac 1 -c:a pcm_s16le "${TMP_WAV}"
whisper-cpp -m "${BASE_PATH}/${MODEL}.bin" -pp -ml 84 -osrt -l "${LANG}" -t 1 --max-context 8 -et 2.8 "${TMP_WAV}"
mv "${TMP_WAV}".srt "${1%.*}.srt"
rm "${TMP_WAV}"
