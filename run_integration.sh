#!/bin/bash

if [ -f ${HOME}/.bash_profile ]; then
	. ${HOME}/.bash_profile
fi

# set the desired version of Xcode
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

if [ -z "${WORKSPACE}" ]; then
	echo "[*] workspace nil, setting to working copy"
	REALPATH=$([[ -L $0 ]] && echo $(dirname $0)/$(readlink $0) || echo $0)
	WORKSPACE=$(cd $(dirname $REALPATH); pwd)
fi

cd "${WORKSPACE}"

echo "[*] Cleaning workspace"
if [ -f xcodebuild.log ]; then
	rm xcodebuild.log
fi

if [ -f compile_commands.json ]; then
    rm compile_commands.json
fi

if [ -f oclint.xml ]; then
	rm oclint.xml
fi

if [ -f coverage.xml ]; then
	rm coverage.xml
fi

if [ -f test-reports ]; then
	rm -rf test-reports
fi

echo "[*] Perform tests"
/usr/local/bin/xctool -workspace MMFlowViewDemo.xcworkspace \
-scheme MMFlowViewDemo_CI \
-reporter junit:test-reports/junit-report.xml \
DSTROOT=${WORKSPACE}/build/Products \
OBJROOT=${WORKSPACE}/build/Intermediates \
SYMROOT=${WORKSPACE}/build \
SHARED_PRECOMPS_DIR=${WORKSPACE}/build/Intermediates/PrecompiledHeaders \
clean test

echo "[*] Generating code-coverage results"
/usr/local/bin/gcovr -x -o coverage.xml --root=. --exclude='(.*./Developer/SDKs/.*)|(.*Spec\.m)'

echo "[*] Performing code quality analysis"
xcodebuild -project MMFlowViewDemo.xcodeproj \
-scheme MMFlowViewDemo_CI \
clean 1> /dev/null

/usr/local/bin/xctool -project MMFlowViewDemo.xcodeproj \
-scheme MMFlowViewDemo_CI \
-reporter json-compilation-database:compile_commands.json \
build

${OCLINT_HOME}/bin/oclint-json-compilation-database -- \
-report-type=pmd \
-o oclint.xml \
-rc LONG_LINE=250 \
-rc LONG_VARIABLE_NAME=50 \
-max-priority-2=15 \
-max-priority-3=220
echo "[*] Done"
