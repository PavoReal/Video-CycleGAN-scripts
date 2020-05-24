set STYLE=%1
set INPUT_FILE=%2

set WIDTH=1920
set HEIGHT=1080
set ASPECT=1920/1080

mkdir %INPUT_FILE%_frames\ 2>NUL
mkdir %INPUT_FILE%_frames_%STYLE%\ 2>NUL

del %INPUT_FILE%_frames\*.png 2>NUL

ffmpeg -i %INPUT_FILE% -r 24 -vf "scale = min(1\,gt(iw\,%WIDTH%)+gt(ih\,%HEIGHT%)) * (gte(a\,%ASPECT%)*%WIDTH% + lt(a\,%ASPECT%)*((%HEIGHT%*iw)/ih)) + not(min(1\,gt(iw\,%WIDTH%)+gt(ih\,%HEIGHT%)))*iw : min(1\,gt(iw\,%WIDTH%)+gt(ih\,%HEIGHT%)) * (lte(a\,%ASPECT%)*%HEIGHT% + gt(a\,%ASPECT%)*((%WIDTH%*ih)/iw)) + not(min(1\,gt(iw\,%WIDTH%)+gt(ih\,%HEIGHT%)))*ih" %INPUT_FILE%_resized.mp4
ffmpeg -i %INPUT_FILE%_resized.mp4 -r 24 %INPUT_FILE%.mp3
ffmpeg -i %INPUT_FILE%_resized.mp4 -r 24 %INPUT_FILE%_frames\frame_%%d.png

del %INPUT_FILE%_frames_%STYLE%\%STYLE%\test_latest\images\*.png

for /f %%A in ('dir %INPUT_FILE%_frames\ ^| find "File(s)"') do set cnt=%%A
python test.py --dataroot %INPUT_FILE%_frames\ --results_dir %INPUT_FILE%_frames_%STYLE%\ --name %STYLE% --model test --direction BtoA --no_dropout --preprocess none --num_test %cnt%

del %INPUT_FILE%_frames_%STYLE%\%STYLE%\test_latest\images\*_real.png

ffmpeg -r 24 -f image2 -i %INPUT_FILE%_frames_%STYLE%\%STYLE%\test_latest\images\frame_%%d_fake.png -vcodec libx264 %INPUT_FILE%_%STYLE%_silent.mp4
ffmpeg -i %INPUT_FILE%_%STYLE%_silent.mp4 -i %INPUT_FILE%.mp3 %INPUT_FILE%_%STYLE%.mp4

rem del %INPUT_FILE%_resized.mp4
rem del %INPUT_FILE%_%STYLE%_silent.mp4
rem del %INPUT_FILE%.mp3

rem RD /S /Q %INPUT_FILE%_frames\
rem RD /S /Q %INPUT_FILE%_frames_%STYLE%\
