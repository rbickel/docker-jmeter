#!/bin/bash
# Inspired from https://github.com/hhcordero/docker-jmeter-client
# Basically runs jmeter, assuming the PATH is set to point to JMeter bin-dir (see Dockerfile)
#
# This script expects the standdard JMeter command parameters.
#
echo "entrypoint.sh"

set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "jmeter args=$@"

export TEST_DIR="/tests"
export OUTPUT_DIR=`date +"%Y%m%d%H%M%S"`

mkdir ${OUTPUT_DIR}
# Keep entrypoint simple: we must pass the standard JMeter arguments
for i in ${TEST_DIR}/*.jmx
do
  jmeter -n -t $i -l ${TEST_DIR}/${OUTPUT_DIR}/$i.jtl -j ${TEST_DIR}/${OUTPUT_DIR}/jmeter.log
done

echo "END Running Jmeter on `date`"