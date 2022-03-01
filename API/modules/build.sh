#!/bin/bash

dir=$(mktemp -d)

python3 -m build -o $dir -w

pushd $dir
mkdir python
unzip bank_manager_helper-*.whl -d python
zip -r bank_manager_helper.zip python

popd
mv $dir/bank_manager_helper.zip ../build
rm -rf $dir
