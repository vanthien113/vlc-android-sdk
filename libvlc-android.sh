#!/bin/bash

cd $HOME

OUTPUT_DIR="$HOME/libvlc"
SOURCE_DIR="$OUTPUT_DIR/src/main"
JAVA_DIR="$SOURCE_DIR/java"
JNILIBS_DIR="$SOURCE_DIR/jniLibs"

rm -rf $OUTPUT_DIR
mkdir -p $SOURCE_DIR
mkdir -p $JAVA_DIR
mkdir -p $JNILIBS_DIR

git clone "https://code.videolan.org/videolan/vlc-android.git" -b "3.1.6" vlc-android
cd vlc-android
sh compile.sh --init
sed -i -e "s/4.10.1/5.4.1/g" gradle/wrapper/gradle-wrapper.properties
./gradlew wrapper
for ARCH in "armeabi-v7a arm64-v8a x86 x86_64"; do
    sh compile.sh -a $ARCH -l --release --no-ml
done

for filename in libvlc/build/outputs/aar/*.aar; do
    unzip $filename jni/* -d $JNILIBS_DIR
    mv $JNILIBS_DIR/jni/* $JNILIBS_DIR
done
rm -rf $JNILIBS_DIR/jni

cp -r libvlc/src/ $JAVA_DIR
mv $JAVA_DIR/src/* $JAVA_DIR
rm -rf $JAVA_DIR/src
cp libvlc/AndroidManifest.xml $SOURCE_DIR/AndroidManifest.xml

cd $HOME
zip -r libvlc-source.zip libvlc