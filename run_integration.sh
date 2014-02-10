#!/bin/bash

if [ -f $HOME/.bash_profile ]; then
	source $HOME/.bash_profile
fi

set +x
set -e
set -o pipefail

OCLINT=`which oclint`
XCTOOL=`which xctool`
OCLINT_JSON_COMPILATION_DATABASE=`which oclint-json-compilation-database`

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

if [ -f cpd-output.xml ]; then
	rm -rf cpd-output.xml
fi

echo "[*] Perform tests"
${XCTOOL} -workspace MMFlowViewDemo.xcworkspace \
-scheme MMFlowViewDemo_CI \
-reporter junit:${WORKSPACE}/test-reports/junit-report.xml \
-reporter plain \
DSTROOT=${WORKSPACE}/build/Products \
OBJROOT=${WORKSPACE}/build/Intermediates \
SYMROOT=${WORKSPACE}/build \
SHARED_PRECOMPS_DIR=${WORKSPACE}/build/Intermediates/PrecompiledHeaders \
MM_IS_COVERAGE_BUILD=YES \
CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
GCC_GENERATE_TEST_COVERAGE_FILES=YES GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
clean test

echo "[*] Generating code-coverage results"
scripts/gcovr -x -o coverage.xml --root=. --exclude='(.*Spec\.m)|(Pods/*)|(.*Test\.m)|(.*.h)'
