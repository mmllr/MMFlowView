set -e

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
DSTROOT=${WORKSPACE}/tmp \
OBJROOT=${WORKSPACE}/Build/Intermediates \
SYMROOT=${WORKSPACE}/Build/Products \
SHARED_PRECOMPS_DIR=${WORKSPACE}/build/Intermediates/PrecompiledHeaders \
clean test

echo "[*] Generating code-coverage results"
/usr/local/bin/gcovr -x -o coverage.xml --root=. --exclude='(.*./Developer/SDKs/.*)|(.*Spec\.m)'

echo "[*] Code quality analysis"
 xcodebuild -project MMFlowViewDemo.xcodeproj \
 -scheme MMFlowViewDemo_CI \
DSTROOT=${WORKSPACE}/tmp \
OBJROOT=${WORKSPACE}/Build/Intermediates \
SYMROOT=${WORKSPACE}/Build/Products \
SHARED_PRECOMPS_DIR=${WORKSPACE}/build/Intermediates/PrecompiledHeaders \
clean build > xcodebuild.log

oclint-xcodebuild
oclint-json-compilation-database -- -report-type pmd -o oclint.xml
echo "[*] Done"
