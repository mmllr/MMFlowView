#!/bin/bash -ex

set -o pipefail

# set the desired version of Xcode
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

XCWORKSPACE="Example/MMFlowViewDemo.xcworkspace"
XCSCHEME="MMFlowViewDemo"

if [ -z "${OCLINT}" ]; then
	OCLINT=`which oclint`
fi

if [ -z "${OCLINT_XCODEBUILD}" ]; then
	OCLINT_XCODEBUILD=`which oclint-xcodebuild`
fi

if [ -z "${OCLINT_JSON_COMPILATION_DATABASE}" ]; then
	OCLINT_JSON_COMPILATION_DATABASE=`which oclint-json-compilation-database`
fi

if [ -z "${XCTOOL}" ]; then
	XCTOOL=`which xctool`
fi

if [ -z "${XCODEBUILD}" ]; then
	XCODEBUILD=`which xcodebuild`
fi

if [ -z "${DOT}" ]; then
     DOT=`which dot`
fi

if [ -z "${WORKSPACE}" ]; then
	echo "[*] workspace nil, setting to working copy"
	REALPATH=$([[ -L $0 ]] && echo $(dirname $0)/$(readlink $0) || echo $0)
	WORKSPACE=$(cd $(dirname $REALPATH); pwd)
fi

echo "[*] Cleaning workspace"

if [ -f compile_commands.json ]; then
	rm compile_commands.json
fi

if [ -d build ]; then
	rm -Rf build
fi

echo "[*] Perform tests"
${XCTOOL} -workspace ${XCWORKSPACE} \
-scheme ${XCSCHEME} \
-reporter junit:${WORKSPACE}/build/test-reports/junit-report.xml \
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
scripts/gcovr -x -o ${WORKSPACE}/build/test-reports/coverage.xml --root=. --exclude='(.*Spec\.m)|(Pods/*)|(.*Test\.m)|(.*.h)|Example/*'

echo "[*] Performing code quality analysis"

mkdir -p ${WORKSPACE}/build/reports

scripts/objc_dep.py Classes/ -i Specs osx/Specs Example > ${WORKSPACE}/build/reports/dependency.dot
${DOT} -Tpng -o${WORKSPACE}/build/reports/dependency.png ${WORKSPACE}/build/reports/dependency.dot
echo "<html><body><img src=\"dependency.png\"></body></html>" > build/reports/index.html

mkdir -p ${WORKSPACE}/build/oclint

${XCODEBUILD} -workspace ${XCWORKSPACE} \
-scheme ${XCSCHEME} \
-configuration Release \
DSTROOT=${WORKSPACE}/build/Products \
OBJROOT=${WORKSPACE}/build/Intermediates \
SYMROOT=${WORKSPACE}/build \
SHARED_PRECOMPS_DIR=${WORKSPACE}/build/Intermediates/PrecompiledHeaders \
CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
clean

${XCODEBUILD} -workspace ${XCWORKSPACE} \
-scheme ${XCSCHEME} \
-configuration Release \
CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
DSTROOT=${WORKSPACE}/build/Products \
OBJROOT=${WORKSPACE}/build/Intermediates \
SYMROOT=${WORKSPACE}/build \
SHARED_PRECOMPS_DIR=${WORKSPACE}/build/Intermediates/PrecompiledHeaders \
build > ${WORKSPACE}/build/oclint/xcodebuild.log

${OCLINT_XCODEBUILD} ${WORKSPACE}/build/oclint/xcodebuild.log -o ${WORKSPACE}/compile_commands.json

${OCLINT_JSON_COMPILATION_DATABASE} -- \
-report-type=pmd \
-o ${WORKSPACE}/build/oclint/lint.xml \
-rc LONG_LINE=250 \
-rc LONG_VARIABLE_NAME=50 \
-max-priority-2=15 \
-max-priority-3=200

if [ "$?" -ne "0" ]; then
echo "[ ] ERROR! Integration failed!"
else
echo "[*] Integration successful!"
fi


