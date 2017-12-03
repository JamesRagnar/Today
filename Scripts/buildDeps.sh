#!/bin/sh

if ! cmp -s Cartfile.resolved Carthage/Cartfile.resolved; then
    bundle exec carthage update --platform iOS
    cp Cartfile.resolved Carthage
fi

echo "Carthage Dependencies Satisfied"
