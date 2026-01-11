#!/bin/sh

# 変数を定義する
HISTORY_DIR="/tmp/history"
CURRENT_DATE=$(date +"%Y_%m_%d_%H_%M_%S")
TARGET_ZIP="async.zip"
TARGET_ZIP_PATH="/tmp/${TARGET_ZIP}"
TARGET_ZIP_HASH="$1"
BACKUP_DIR="backup"
RESOURCE_DIR="resource"
RELEASE_TARGET_DIR="/opt"
ASYNC_DIR=async
BIN_DIR="bin"
CONF_DIR="conf"
SHELL_DIR="shell"

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

# 引数のハッシュ値を表示する
echo "target zip hash is following."
echo "${TARGET_ZIP_HASH}"

# 履歴ディレクトリがない場合は作成する
echo "checking history dir exists."
if [ ! -d "${HISTORY_DIR}" ]; then
	echo "${HISTORY_DIR} not exists, going to create."
	run mkdir -p "${HISTORY_DIR}"
fi

# 日付ディレクトリを作成する
echo "create current date directory."
run mkdir -p "${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${BIN_DIR}"
run ls -la   "${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${BIN_DIR}"
run mkdir -p "${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${CONF_DIR}"
run ls -la   "${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${CONF_DIR}"
run mkdir -p "${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${SHELL_DIR}"
run ls -la   "${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${SHELL_DIR}"
run mkdir -p "${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}"
run ls -la   "${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}"

# リリース対象資材(zipファイル)がない場合はエラーとする
echo "checking target zip exists."
if [ ! -f "${TARGET_ZIP_PATH}" ]; then
	echo "${TARGET_ZIP_PATH} not exists, program will exit."
	run exit 1;	
fi

# リリース対象資材を履歴ディレクトリ配下にコピーする
echo "copy target zip to history dir."
run cp -p "${TARGET_ZIP_PATH}" "${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}/"
run ls -la "${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}"

# リリース資材のmd5ハッシュ値を取得する
echo "get md5 hash of target zip."
LOCAL_HASH=$(md5sum "${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}/${TARGET_ZIP}" | awk '{print $1}')
echo "${LOCAL_HASH}"

# 引数とハッシュ値が異なる場合はエラーとする
if [ "${TARGET_ZIP_HASH}" = "${LOCAL_HASH}" ]; then
	echo "md5 hash check OK."
else
	echo "md5 hash check NG, program will exit."
	run exit 1
fi

# リリース対象資材を解凍する
echo "unzip target zip."
run unzip "${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}/${TARGET_ZIP}" -d "${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}"
run ls -la "${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}"

# 現在の資源をバックアップディレクトリにコピーする
echo "backup current programs and setting files."
if find "${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${BIN_DIR}" -mindepth 1 -maxdepth 1 | read _; then
	run cp -p ${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${BIN_DIR}/* ${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${BIN_DIR}
	run ls -la ${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${BIN_DIR}
fi
if find "${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${CONF_DIR}" -mindepth 1 -maxdepth 1 | read _; then
	run cp -p ${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${CONF_DIR}/* ${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${CONF_DIR}
	run ls -la ${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${CONF_DIR}
fi
if find "${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${SHELL_DIR}" -mindepth 1 -maxdepth 1 | read _; then
	run cp -p ${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${SHELL_DIR}/* ${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${SHELL_DIR}
	run ls -la ${HISTORY_DIR}/${CURRENT_DATE}/${BACKUP_DIR}/${ASYNC_DIR}/${SHELL_DIR}
fi

# リリース資源を配置する
echo "release programs and setting files."
if find "${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}/${ASYNC_DIR}/${BIN_DIR}" -mindepth 1 -maxdepth 1 | read _; then
	run cp -pf ${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}/${ASYNC_DIR}/${BIN_DIR}/* ${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${BIN_DIR}
	run ls -la "${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${BIN_DIR}"
fi
if find "${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}/${ASYNC_DIR}/${CONF_DIR}" -mindepth 1 -maxdepth 1 | read _; then
	run cp -pf ${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}/${ASYNC_DIR}/${CONF_DIR}/* ${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${CONF_DIR}
	run ls -la "${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${CONF_DIR}"
fi
if find "${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}/${ASYNC_DIR}/${SHELL_DIR}" -mindepth 1 -maxdepth 1 | read _; then
	run cp -pf ${HISTORY_DIR}/${CURRENT_DATE}/${RESOURCE_DIR}/${ASYNC_DIR}/${SHELL_DIR}/* ${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${SHELL_DIR}
	run ls -la "${RELEASE_TARGET_DIR}/${ASYNC_DIR}/${SHELL_DIR}"
fi

# リリース成功の表示を行う
echo "all release sequence has completed."
echo "release success."
