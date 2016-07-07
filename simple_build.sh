#! /bin/bash

rm -f build
mkdir build
cd src
zip -r kanelbullick.love ./
mv kanelbullick.love ../build
cd ../build
cp ~/dev/love-0.10.1-win32/*.dll ./
cat ~/dev/love-0.10.1-win32/love.exe kanelbullick.love > kanelbullick.exe
mv kanelbullick.love ../
zip -r kanelbullick-win32.zip ./
mv ../kanelbullick.love ./