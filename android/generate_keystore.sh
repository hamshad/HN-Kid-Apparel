#!/bin/bash

KEYSTORE="android/upload-keystore.jks"
STOREPASS="India0091#"
KEYPASS="India0091#"
ALIAS="upload"
DNAME="CN=Hamshad Shaikh, OU=Moksha Solutions, O=Moksha Solutions, L=Chhatrapati Sambhajinagar, S=Maharashtra, C=IN"

if [ -f "$KEYSTORE" ]; then
  echo "Keystore already exists at $KEYSTORE. Aborting to prevent overwrite."
  exit 1
fi

keytool -genkeypair -v \
  -keystore "$KEYSTORE" \
  -storepass "$STOREPASS" \
  -alias "$ALIAS" \
  -keypass "$KEYPASS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -dname "$DNAME"
