#!/usr/bin/env bash
#
# Author: Maxime BOCHON
# Created: 2021-09-20
# Updated: 2021-09-20
#
# Description:
#   Convert QuickTime movie files to MPEG-4 files losslessly, using FFmpeg.
#   The script takes as arguments a list of paths to movie files of such type.
#   A checking of the actual file type is done before calling FFmpeg on the file.
#   If an error occurs on one file, the script keeps running.
#
# Keywords: Apple QuickTime movie file, MOV, MPEG-4, MP4, lossless video conversion, FFmpeg
#

REQUIRED_COMMANDS="file grep ffmpeg"

EXIT_CODE_MISSING_COMMAND=255

EXPECTED_FILE_TYPE_MARKER="Apple QuickTime movie"

LOG_FILE="/tmp/mov2mp4.$$.log"


# Check presence of required commands
for cmd in ${REQUIRED_COMMANDS}; do
	command -v "${cmd}" >/dev/null 2>&1 \
	|| { echo >&2 "$0 requires command: "${cmd}; exit ${EXIT_CODE_MISSING_COMMAND}; }
done

# Process each QuickTime file
for movFile in "$@"; do

	# Check real file type
	realFileType=$(file --brief "${movFile}")
	echo "${realFileType}" | grep --quiet "${EXPECTED_FILE_TYPE_MARKER}" \
	|| { echo >&2 "${movFile}: not a valid Apple QuickTime movie file (${realFileType})"; continue; }
	
	# Convert MOV file to MP4 file losslessly using FFmpeg
	mp4File="${movFile%.*}.mp4"
	ffmpeg -loglevel warning -i "${movFile}" -c:a copy -c:v copy "${mp4File}" >>"${LOG_FILE}" 2>&1 \
	|| { echo "${movFile}: FFmpeg exited with error code $? (see log file: ${LOG_FILE})"; continue; }
	
	# Display converted file name if successful
	echo "${movFile} -> ${mp4File}"
done

# TODO: display error messages in red, success messages in green.
