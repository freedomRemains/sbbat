@echo off

chcp 65001
set JAVA_CMD="C:\Program Files\Eclipse Adoptium\jdk-21.0.6.7-hotspot\bin\java.exe"
set JAVA_OPTS=-Dfile.encoding=UTF-8
set JAR_FILE=build\libs\sbbat-0.0.1-SNAPSHOT.jar

%JAVA_CMD% -jar %JAR_FILE% jobB

rem 結果が分かるよう一時停止する
pause
