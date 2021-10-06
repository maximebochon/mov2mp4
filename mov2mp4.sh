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

OK='\033[0;32m' # green color
KO='\033[0;31m' # red color
NC='\033[0m'    # no color

# Check presence of required commands
for cmd in ${REQUIRED_COMMANDS}; do
	command -v "${cmd}" >/dev/null 2>&1 \
	|| { echo -e >&2 "${KO}$0 requires command: "${cmd}"${NC}"; exit ${EXIT_CODE_MISSING_COMMAND}; }
done

# Process each QuickTime file
for movFile in "$@"; do

	# Check real file type
	realFileType=$(file --brief "${movFile}")
	echo "${realFileType}" | grep --quiet "${EXPECTED_FILE_TYPE_MARKER}" \
	|| { echo -e >&2 "${KO}${movFile}: not a valid Apple QuickTime movie file (${realFileType})${NC}"; continue; }
	
	# Convert MOV file to MP4 file losslessly using FFmpeg
	mp4File="${movFile%.*}.mp4"
	ffmpeg -loglevel error -i "${movFile}" -c:a copy -c:v copy "${mp4File}" \
	|| { echo -e "${KO}${movFile}: FFmpeg exited with error code $?${NC}"; continue; }
	
	# Display converted file name if successful
	echo -e "${OK}${movFile} -> ${mp4File}${NC}"
done

# TODO: try to find a way to keep FFmpeg error level for displayed logs, and another for a temporary log file (report) that could be useful on error
