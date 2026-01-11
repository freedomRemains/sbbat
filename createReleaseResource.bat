@echo off

chcp 65001
set SEVEN_ZIP_DIR="C:\Program Files\7-Zip"

rem リリース資材のディレクトリを作成する
mkdir async
mkdir async\bin
mkdir async\conf
mkdir async\shell

rem リリース資材をコピーする
copy build\libs\sbbat-0.0.1-SNAPSHOT.jar async\bin\app.jar
xcopy src\main\resources\shell\*.sh async\shell\

rem 7zipを使ってリリース資材を圧縮する
%SEVEN_ZIP_DIR%\7z a async.zip async

rem MD5のハッシュ値を取得する
certutil -hashfile async.zip MD5

rem リリース資材のディレクトリを削除する
rd /S /Q async

rem 結果が分かるよう一時停止する
pause
