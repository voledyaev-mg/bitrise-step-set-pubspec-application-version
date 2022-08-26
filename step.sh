#!/bin/bash
set -e

get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

PUBSPEC_YAML_PATH=$(get_abs_filename "${project_location}/pubspec.yaml")
if [[ ! -f ${PUBSPEC_YAML_PATH} ]]
then
	echo "No pubspec file found at path: ${PUBSPEC_YAML_PATH}"
	exit 1
fi

BITRISE_BUILD_NUMBER="${bitrise_buildnumber}"
if [[ -z ${BITRISE_BUILD_NUMBER} ]]
then
	echo "Bitrise build number has zero length"
	exit 1
fi

# Optional
APP_VERSION="${application_version}"

DART=`which dart`

# install dart packages for tool
$DART pub get

STDOUT=$($DART run main.dart $PUBSPEC_YAML_PATH $BITRISE_BUILD_NUMBER $APP_VERSION)

echo $STDOUT

while IFS= read -r line; do
    TYP=$(echo $line | cut -d ":" -f 1)
    VAL=$(echo $line | cut -d ":" -f 2)
    if [[ "${TYP}" == "APP_VERSION" ]]; then
        envman add --key DART_PUBSPEC_APP_VERSION --value ${VAL}
    fi
    if [[ "${TYP}" == "APP_BUILD_NUMBER" ]]; then
        envman add --key DART_PUBSPEC_APP_BUILD_NUMBER --value ${VAL}
    fi
    if [[ "${TYP}" == "APP_VERSION_STRING" ]]; then
        envman add --key DART_PUBSPEC_APP_VERSION_STRING --value ${VAL}
    fi
done <<< "$STDOUT"
