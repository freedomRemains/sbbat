#!/bin/sh

# リリースシェルのように途中でエラーが起きたら即時終了しなければならない厳密な処理用のオプションを指定する。
# set -e コマンドが0以外の終了ステータスを返したら、スクリプト全体を終了する。
# set -u 未定義の変数を使ったら、即時終了する。
# set -o pipefail パイプでつないだコマンドのどこか1つでも失敗したら、パイプ全体を失敗扱いとする。
#                 ※ 通常のシェルではパイプでつないだ最後のコマンドが成功すれば成功扱いとなる。
# "#!/bin/sh"指定だと、"set -o pipefail"は効かないことが多い。
# そのため実コードでは"set -eu"とし、パイプは原則使わない方針とする。(使う場合は個別実装) 
set -eu

# 実行するコマンドを表示した上で、コマンドを実行する関数
run() {
    echo "[command] $*"
    "$@"
}

JAVA_CMD="/usr/bin/java"
JAVA_OPTS="-Dfile.encoding=UTF-8"
JAR_FILE="/opt/async/bin/app.jar"

COMMAND="${JAVA_CMD} -jar ${JAR_FILE} jobA"
run ${COMMAND}

COMMAND="${JAVA_CMD} -jar ${JAR_FILE} jobB"
run ${COMMAND}

