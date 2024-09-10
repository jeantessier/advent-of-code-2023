#!/bin/bash

for d in $(find . -name Gemfile -exec dirname \{\} \+)
do
    echo "==========" $d "=========="
    (
        cd $d
        bundle update --bundler
        bundle update --all
    )
done
