#/bin/sh

# set the desired version of Xcode
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

cd "${WORKSPACE}"

/usr/local/bin/xctool \
   -workspace MMFlowViewDemo.xcworkspace \
   -scheme MMFlowViewDemo_CI \
   DSTROOT=$WORKSPACE/build.dst \
   OBJROOT=$WORKSPACE/build.obj \
   SYMROOT=$WORKSPACE/build.sym \
   SHARED_PRECOMPS_DIR=$WORKSPACE/build.pch \
   -reporter junit:test-reports/junit-report.xml \
   clean test

# generate the coverage report
cd "${WORKSPACE}"
/usr/local/bin/gcovr --root="${WORKSPACE}" --exclude='(.*./Developer/SDKs/.*)|(.*Spec\.m)' -x > ./coverage.xml
