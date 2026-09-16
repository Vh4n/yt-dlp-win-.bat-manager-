@echo off
setlocal EnableExtensions DisableDelayedExpansion

title YT-DLP Downloader
color 0B

:: ============================================================
:: PATHS
:: ============================================================

set "BASE_DIR=%~dp0"
set "BIN_DIR=%BASE_DIR%bin"
set "DOWNLOAD_DIR=%BASE_DIR%Downloads"

set "YTDLP=%BIN_DIR%\yt-dlp.exe"
set "FFMPEG=%BIN_DIR%\ffmpeg.exe"

set "PATH=%BIN_DIR%;%PATH%"

:: Create Downloads folder
if not exist "%DOWNLOAD_DIR%" mkdir "%DOWNLOAD_DIR%"

:: ============================================================
:: CHECK YT-DLP
:: ============================================================

if not exist "%YTDLP%" (
color 0C
cls
echo.
echo ============================================================
echo ERROR
echo ============================================================
echo.
echo yt-dlp.exe was not found.
echo.
echo Expected:
echo %YTDLP%
echo.
echo Make sure yt-dlp.exe is inside the "bin" folder.
echo.
pause
exit /b 1
)

:: Only hand yt-dlp an ffmpeg path if ffmpeg is actually there
set "FFMPEG_OPT="
if exist "%FFMPEG%" set "FFMPEG_OPT=--ffmpeg-location "%BIN_DIR%""

:: ============================================================
:: MAIN MENU
:: ============================================================

:MAIN_MENU

cls
color 0B

echo.
echo ============================================================
echo YT-DLP DOWNLOADER
echo ============================================================
echo.
echo [1] Download Video
echo [2] Download Audio
echo.
echo [0] Exit
echo.
echo ------------------------------------------------------------
echo.

set "choice="
set /p "choice= Select an option: "

if "%choice%"=="1" goto VIDEO
if "%choice%"=="2" goto AUDIO
if "%choice%"=="0" goto QUIT

echo.
echo Invalid choice.
timeout /t 2 >nul
goto MAIN_MENU

:: ============================================================
:: VIDEO
:: ============================================================

:VIDEO

cls
color 0B

echo.
echo ============================================================
echo VIDEO DOWNLOAD
echo ============================================================
echo.

set "url="
set /p "url= Enter video URL: "

if not defined url (
echo.
echo No URL provided.
timeout /t 2 >nul
goto MAIN_MENU
)

:: Remove accidental quotation marks
set "url=%url:"=%"

echo.
echo ------------------------------------------------------------
echo VIDEO RESOLUTION
echo ------------------------------------------------------------
echo.
echo [1] Best available
echo [2] 2160p (4K)
echo [3] 1440p
echo [4] 1080p
echo [5] 720p
echo [6] 480p
echo [7] 360p
echo.
echo ------------------------------------------------------------
echo.

set "resolution="
set /p "resolution= Select resolution: "

set "MAX_HEIGHT="
set "RES_LABEL="

if "%resolution%"=="1" set "RES_LABEL=Best available"

if "%resolution%"=="2" (
set "MAX_HEIGHT=2160"
set "RES_LABEL=2160p"
)

if "%resolution%"=="3" (
set "MAX_HEIGHT=1440"
set "RES_LABEL=1440p"
)

if "%resolution%"=="4" (
set "MAX_HEIGHT=1080"
set "RES_LABEL=1080p"
)

if "%resolution%"=="5" (
set "MAX_HEIGHT=720"
set "RES_LABEL=720p"
)

if "%resolution%"=="6" (
set "MAX_HEIGHT=480"
set "RES_LABEL=480p"
)

if "%resolution%"=="7" (
set "MAX_HEIGHT=360"
set "RES_LABEL=360p"
)

if not defined RES_LABEL (
echo.
echo Invalid resolution.
timeout /t 2 >nul
goto VIDEO
)

echo.
echo ------------------------------------------------------------
echo TRIM
echo ------------------------------------------------------------
echo.
echo Download only part of the video?
echo.
echo [Y] Yes - pick a start/end time (requires ffmpeg)
echo [N] No  - download the whole video
echo.

set "trim="
set /p "trim= Choice: "

set "SECTION_OPT="

if /I "%trim%"=="Y" goto VIDEO_TRIM
if /I "%trim%"=="N" goto VIDEO_MP4_PROMPT

echo.
echo Invalid choice.
timeout /t 2 >nul
goto VIDEO

:VIDEO_TRIM

if not exist "%FFMPEG%" (
color 0C
cls
echo.
echo ============================================================
echo FFMPEG NOT FOUND
echo ============================================================
echo.
echo Trimming requires ffmpeg, but it wasn't found at:
echo %FFMPEG%
echo.
echo Put ffmpeg.exe inside the "bin" folder, or choose "No" to
echo download the whole video.
echo.
pause
goto VIDEO
)

echo.
echo Enter times as HH:MM:SS or MM:SS.
echo.

set "starttime="
set /p "starttime= Start time (blank = 00:00): "

if not defined starttime set "starttime=00:00:00"

set "endtime="
set /p "endtime= End time (blank = end of video): "

if not defined endtime (
set "endtime=inf"
) 

set "SECTION_OPT=--download-sections "*%starttime%-%endtime%" --force-keyframes-at-cuts"

:VIDEO_MP4_PROMPT

echo.
echo ------------------------------------------------------------
echo MP4 CONVERSION
echo ------------------------------------------------------------
echo.
echo Convert/merge video to MP4?
echo.
echo [Y] Yes - highest quality, needs ffmpeg
echo [N] No  - single pre-merged file, no ffmpeg needed
echo.

set "mp4="
set /p "mp4= Choice: "

if /I "%mp4%"=="Y" goto VIDEO_MP4
if /I "%mp4%"=="N" goto VIDEO_NORMAL

echo.
echo Invalid choice.
timeout /t 2 >nul
goto VIDEO

:: ============================================================
:: VIDEO MP4
:: ============================================================

:VIDEO_MP4

if not exist "%FFMPEG%" (
color 0C
cls
echo.
echo ============================================================
echo FFMPEG NOT FOUND
echo ============================================================
echo.
echo Expected:
echo %FFMPEG%
echo.
echo Put ffmpeg.exe inside the "bin" folder.
echo.
pause
goto MAIN_MENU
)

:: Separate video + audio streams, merged by ffmpeg
if defined MAX_HEIGHT (
set "FORMAT=bestvideo[height<=%MAX_HEIGHT%]+bestaudio/best[height<=%MAX_HEIGHT%]/best"
) else (
set "FORMAT=bestvideo+bestaudio/best"
)

cls
color 0B

echo.
echo ============================================================
echo DOWNLOADING VIDEO
echo ============================================================
echo.
echo Selected: %RES_LABEL%
echo Format: MP4
if defined SECTION_OPT echo Trim: %starttime% to %endtime%
echo.
echo Destination:
echo %DOWNLOAD_DIR%
echo.
echo ------------------------------------------------------------
echo DOWNLOAD STATUS
echo ------------------------------------------------------------
echo.

"%YTDLP%" ^
%FFMPEG_OPT% ^
--no-playlist ^
-f "%FORMAT%" ^
--merge-output-format mp4 ^
%SECTION_OPT% ^
--paths "%DOWNLOAD_DIR%" ^
-o "%%(title)s [%%(height)sp].%%(ext)s" ^
-- "%url%"

set "RESULT=%ERRORLEVEL%"
goto DONE

:: ============================================================
:: VIDEO NORMAL
:: ============================================================

:VIDEO_NORMAL

:: Single pre-merged file only - nothing to merge, so no ffmpeg required
if defined MAX_HEIGHT (
set "FORMAT=best[height<=%MAX_HEIGHT%]/best"
) else (
set "FORMAT=best"
)

cls
color 0B

echo.
echo ============================================================
echo DOWNLOADING VIDEO
echo ============================================================
echo.
echo Selected: %RES_LABEL%
if defined SECTION_OPT echo Trim: %starttime% to %endtime%
echo.
echo Destination:
echo %DOWNLOAD_DIR%
echo.
echo ------------------------------------------------------------
echo DOWNLOAD STATUS
echo ------------------------------------------------------------
echo.

"%YTDLP%" ^
%FFMPEG_OPT% ^
--no-playlist ^
-f "%FORMAT%" ^
%SECTION_OPT% ^
--paths "%DOWNLOAD_DIR%" ^
-o "%%(title)s [%%(height)sp].%%(ext)s" ^
-- "%url%"

set "RESULT=%ERRORLEVEL%"
goto DONE

:: ============================================================
:: AUDIO
:: ============================================================

:AUDIO

cls
color 0B

echo.
echo ============================================================
echo AUDIO DOWNLOAD
echo ============================================================
echo.

set "url="
set /p "url= Enter video/audio URL: "

if not defined url (
echo.
echo No URL provided.
timeout /t 2 >nul
goto MAIN_MENU
)

:: Remove accidental quotation marks
set "url=%url:"=%"

echo.
echo ------------------------------------------------------------
echo AUDIO BITRATE
echo ------------------------------------------------------------
echo.
echo [1] Best available
echo [2] 320 kbps
echo [3] 256 kbps
echo [4] 192 kbps
echo [5] 128 kbps
echo.
echo ------------------------------------------------------------
echo.

set "bitrate="
set /p "bitrate= Select bitrate: "

set "AUDIO_ABR="
set "AUDIO_QUALITY="
set "AUDIO_LABEL="
set "AUDIO_TAG="

if "%bitrate%"=="1" (
set "AUDIO_QUALITY=0"
set "AUDIO_LABEL=Best available"
set "AUDIO_TAG=%%(abr)skbps"
)

if "%bitrate%"=="2" (
set "AUDIO_ABR=320"
set "AUDIO_QUALITY=320K"
set "AUDIO_LABEL=320kbps"
set "AUDIO_TAG=320kbps"
)

if "%bitrate%"=="3" (
set "AUDIO_ABR=256"
set "AUDIO_QUALITY=256K"
set "AUDIO_LABEL=256kbps"
set "AUDIO_TAG=256kbps"
)

if "%bitrate%"=="4" (
set "AUDIO_ABR=192"
set "AUDIO_QUALITY=192K"
set "AUDIO_LABEL=192kbps"
set "AUDIO_TAG=192kbps"
)

if "%bitrate%"=="5" (
set "AUDIO_ABR=128"
set "AUDIO_QUALITY=128K"
set "AUDIO_LABEL=128kbps"
set "AUDIO_TAG=128kbps"
)

if not defined AUDIO_LABEL (
echo.
echo Invalid bitrate.
timeout /t 2 >nul
goto AUDIO
)

echo.
echo ------------------------------------------------------------
echo MP3 CONVERSION
echo ------------------------------------------------------------
echo.
echo Convert audio to MP3?
echo.
echo [Y] Yes - needs ffmpeg
echo [N] No  - keep original format (m4a/opus/webm)
echo.

set "mp3="
set /p "mp3= Choice: "

if /I "%mp3%"=="Y" goto AUDIO_MP3
if /I "%mp3%"=="N" goto AUDIO_NORMAL

echo.
echo Invalid choice.
timeout /t 2 >nul
goto AUDIO

:: ============================================================
:: AUDIO MP3
:: ============================================================

:AUDIO_MP3

if not exist "%FFMPEG%" (
color 0C
cls
echo.
echo ============================================================
echo FFMPEG NOT FOUND
echo ============================================================
echo.
echo Expected:
echo %FFMPEG%
echo.
echo Put ffmpeg.exe inside the "bin" folder.
echo.
pause
goto MAIN_MENU
)

cls
color 0B

echo.
echo ============================================================
echo DOWNLOADING AUDIO
echo ============================================================
echo.
echo Bitrate: %AUDIO_LABEL%
echo Format: MP3
echo.
echo Destination:
echo %DOWNLOAD_DIR%
echo.
echo ------------------------------------------------------------
echo DOWNLOAD STATUS
echo ------------------------------------------------------------
echo.

"%YTDLP%" ^
%FFMPEG_OPT% ^
--no-playlist ^
-f "bestaudio/best" ^
-x ^
--audio-format mp3 ^
--audio-quality "%AUDIO_QUALITY%" ^
--paths "%DOWNLOAD_DIR%" ^
-o "%%(title)s [%AUDIO_TAG%].mp3" ^
-- "%url%"

set "RESULT=%ERRORLEVEL%"
goto DONE

:: ============================================================
:: AUDIO NORMAL
:: ============================================================

:AUDIO_NORMAL

:: No conversion happens here, so the bitrate choice has to be
:: applied during format selection instead of by ffmpeg
if defined AUDIO_ABR (
set "AFORMAT=bestaudio[abr<=%AUDIO_ABR%]/bestaudio/best"
) else (
set "AFORMAT=bestaudio/best"
)

cls
color 0B

echo.
echo ============================================================
echo DOWNLOADING AUDIO
echo ============================================================
echo.
echo Bitrate: %AUDIO_LABEL%
echo.
echo Destination:
echo %DOWNLOAD_DIR%
echo.
echo ------------------------------------------------------------
echo DOWNLOAD STATUS
echo ------------------------------------------------------------
echo.

"%YTDLP%" ^
%FFMPEG_OPT% ^
--no-playlist ^
-f "%AFORMAT%" ^
--paths "%DOWNLOAD_DIR%" ^
-o "%%(title)s [%%(abr)skbps].%%(ext)s" ^
-- "%url%"

set "RESULT=%ERRORLEVEL%"
goto DONE

:: ============================================================
:: RESULT
:: ============================================================

:DONE

echo.
echo ------------------------------------------------------------

if "%RESULT%"=="0" (
color 0A
echo.
echo ==========================================
echo DOWNLOAD COMPLETE
echo ==========================================
echo.
echo Saved to:
echo %DOWNLOAD_DIR%
echo.
) else (
color 0C
echo.
echo ==========================================
echo DOWNLOAD FAILED
echo ==========================================
echo.
echo yt-dlp returned:
echo %RESULT%
echo.
)

pause
goto MAIN_MENU

:: ============================================================
:: EXIT
:: ============================================================

:QUIT

cls
color 0B
echo.
echo Goodbye.
echo.
timeout /t 1 >nul
exit /b 0
