#!/usr/bin/env bash

# Exit script as soon as a command fails.
set -o errexit

# Executes cleanup function at script exit.
trap cleanup EXIT

cleanup() {
  # Kill the testrpc instance that we started (if we started one and if it's still running).
  if [ -n "$testrpc_pid" ] && ps -p $testrpc_pid > /dev/null; then
    kill -9 $testrpc_pid
  fi
}

if [ "$SOLIDITY_COVERAGE" = true ]; then
  testrpc_port=8555
else
  testrpc_port=8545
fi

testrpc_running() {
  nc -z localhost "$testrpc_port"
}

start_testrpc() {
  # We define 10 accounts with balance 1M ether, needed for high-value tests.
  local accounts=(
    --account="0xfc1c1950dd286aada1962a0ca98ccda81c9ed3dd8d67a29c5fa60f159714b088, 50000000000000000000000"  \
    --account="0x219f3db4d4a8d416673af055bc04fb5825988f247e009968ccf62dc0f74585e0, 50000000000000000000000"  \
    --account="0x267628673945f998241917e4663fefa0b86c6fe2f7e931a0f2043d30c828cf7d, 50000000000000000000000"  \
    --account="0x27e7e979a3f5a070e56e234eb73211fd915c401da5f9983453126618fa9b90e6, 50000000000000000000000"  \
    --account="0xd7f5971e4b77b3694794470e0de6834f068837baf1e2385512b90f3afa1290a0, 50000000000000000000000"  \
    --account="0x5bc53e27586efef6bd94325dfb65f1c7511d95f4a9a4e6d818203325f0cefdd4, 50000000000000000000000"  \
    --account="0xabc00c2d9695657bcd00e555446cc958a064e0bd7f3beca17ae7298fdf1f3382, 50000000000000000000000"  \
    --account="0xbf2807aa1acb7a21304aff70db4fd31f10892c456ca653fcdc5d7ff30647101e, 50000000000000000000000"  \
    --account="0x61781fbf1695df9a17a1f88e37f019af7ed15aacab89de83e1480dc90acdd2a3, 50000000000000000000000"  \
    --account="0xced6465425c26c685730c16eb8260f4bdca708d6e9a62cccc3e956dd5ccdb36d, 50000000000000000000000"  \
    --account="0x702a50db7d4f0d6f6e78785811fb01fce1b80857b76e050af8edc62da1babe77, 50000000000000000000000"  \
    --account="0xd231e21c6f48651aa90380809ce01bc6cfa26b5d0b29d3b6a2a94ba2c2ad9af8, 50000000000000000000000"  \
    --account="0x59c35c2cba8db746fcd8776c7559a6be40f4393bb055dcffe3dbc031d6d804e7, 50000000000000000000000"  \
    --account="0xe51170af373826e0a8097da962f84297af3067df72afb45767e8cf01394206b1, 50000000000000000000000"  \
    --account="0xd1d469a053a2089f7e205afd4349f1a6e7e3ef2dd34eb9cc67e6c82f3d95e17a, 50000000000000000000000"  \
    --account="0x994cd89153a6fc5e548fa302cc1c47f33c1e9150c9c27ee840de9158033846a8, 50000000000000000000000"  \
    --account="0x98221ace6d204eb7cbaf6654ecea3ad84ad3c1383f5f33c24d8fb394717f5d53, 50000000000000000000000"  \
    --account="0x8cf3dab50a66709b23cb37e8b6676d6a4114e0dfc59371cfa402cef173b75ea8, 50000000000000000000000"  \
    --account="0x46b586c81d65666a2b5a1fd6b87967b360ba4799a1a6a8ed2073e791e3e7eaac, 50000000000000000000000"  \
    --account="0xc0e17c8be47f3dff98e330667f6009a8aeb10d23d98c14cbce5061e05aad16ce, 50000000000000000000000"
  )

  if [ "$SOLIDITY_COVERAGE" = true ]; then
    node_modules/.bin/testrpc-sc --gasLimit 0xfffffffffff --port "$testrpc_port" "${accounts[@]}" > /dev/null &
  else
    node_modules/.bin/testrpc --gasLimit 0xfffffffffff "${accounts[@]}" > /dev/null &
  fi

  testrpc_pid=$!
}

if testrpc_running; then
  echo "Using existing testrpc instance"
else
  echo "Starting our own testrpc instance"
  start_testrpc
fi

if [ "$SOLIDITY_COVERAGE" = true ]; then
  node_modules/.bin/solidity-coverage

  if [ "$CONTINUOUS_INTEGRATION" = true ]; then
    cat coverage/lcov.info | node_modules/.bin/coveralls
  fi
else
  node_modules/.bin/truffle test "$@"
fi
