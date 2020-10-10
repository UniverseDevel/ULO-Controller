#!/usr/bin/env bash
#set -x

host="${1}"
username="${2}"
password="${3}"
action="${4}"
arg1="${5}"
arg2="${6}"
arg3="${7}"
arg4="${8}"
arg5="${9}"
arg6="${10}"
arg7="${11}"
arg8="${12}"

usage() {
  echo "ULO Controller v1.0.0.0"
  echo
  echo "Usage:"
  echo "  ./ulo.sh <ulo_host> <ulo_user> <ulo_pass> <action> <arg 1> <arg N>"
  echo
  echo "Actions:"
  echo "  getmode - Get current ULO camera mode"
  echo "      Arguments:"
  echo "          None"
  echo
  echo "  setmode - Set ULO camera mode"
  echo "      Arguments:"
  echo "          1. mode - camera recording mode"
  echo "              a) standard - ULO awake and not recording"
  echo "              b) spy - ULO awake and recording"
  echo "              c) alert - ULO asleep and recording"
  echo
  echo "  ispowered - Get info if ULO is powered by electricity from plug"
  echo "      Arguments:"
  echo "          None"
  echo
  echo "  getbattery - Get battery capacity"
  echo "      Arguments:"
  echo "          None"
  echo
  echo "  iscard - Get info if SD card is inserted into ULO"
  echo "      Arguments:"
  echo "          None"
  echo
  echo "  getcardspace - Get SD card free capacity"
  echo "      Arguments:"
  echo "          None"
  echo
  echo "  getdiskspace - Get internal memory free capacity"
  echo "      Arguments:"
  echo "          None"
  echo
  echo "  movetocard - Move files from internal memory to SD card"
  echo "      Arguments:"
  echo "          None"
  echo "              NOTE: ULO cannot record during this activity."
  echo
  echo "  cleandiskspace - Clean files on internal memory"
  echo "      Arguments:"
  echo "          1. period - how old/new files should be deleted"
  echo "                      NOTE: This action requires admin account and ULO cannot"
  echo "                            record during this activity."
  echo "              a) oldestday - Oldest day"
  echo "              b) oldestweek - Oldest week"
  echo "              c) oldestyear - Oldest year"
  echo "              d) latestday - Latest day"
  echo "              e) latestweek - Latest week"
  echo "              f) latestyear - Latest year"
  echo "              g) all - All"
  echo
  echo "  downloadlog - Download ULO log into specified location"
  echo "      Arguments:"
  echo "          1. destination path - location where snapshot files should be moved"
  echo "                                NOTE: Alwayse use absolute paths! Destination"
  echo "                                      folder must already exist!"
  echo
  echo "  currentsnapshot - Download current snapshot seen by ULO into specified"
  echo "                    location, if snapshot with same name exists it"
  echo "                    is overwritten"
  echo "      Arguments:"
  echo "          1. destination path - location where snapshot files should be moved"
  echo "                                NOTE: Alwayse use absolute paths! Destination"
  echo "                                      folder must already exist!"
  echo
  echo "  downloadvideos - Download all available videos stored in ULO into specified"
  echo "                   location, if video with same name exists it is skipped"
  echo "      Arguments:"
  echo "          1. destination path - location where snapshot files should be moved"
  echo "                                NOTE: Alwayse use absolute paths! Destination"
  echo "                                      folder must already exist!"
  echo
  echo "  downloadsnapshots - Download all available snapshots stored in ULO into"
  echo "                      specified location, if snapshot with same name exists it"
  echo "                      is skipped"
  echo "      Arguments:"
  echo "          1. destination path - location where snapshot files should be moved"
  echo "                                NOTE: Alwayse use absolute paths! Destination"
  echo "                                      folder must already exist!"
  echo
  echo "  testavailability - Test for device availability"
  echo "      Arguments:"
  echo "          1. host - hostname of device you want to check if available"
  echo
  echo "  checkavailability - Check for device availability and set proper mode"
  echo "      Arguments:"
  echo "          1. mode if true - camera recording mode if conditions are met"
  echo "              a) standard - ULO awake and not recording"
  echo "              b) spy - ULO awake and recording"
  echo "              c) alert - ULO asleep and recording"
  echo "          2. mode if false - camera recording mode if conditions are not met"
  echo "              a) standard - ULO awake and not recording"
  echo "              b) spy - ULO awake and recording"
  echo "              c) alert - ULO asleep and recording"
  echo "          3. operation - operation to determine how to check devices"
  echo "              a) and - All devices available to be true"
  echo "              b) or - Any device available to be true"
  echo "          4. host1 - hostname of device you want to check if available"
  echo "          5. host2 - hostname of device you want to check if available"
  echo "                     (optional)"
  echo "          6. host3 - hostname of device you want to check if available"
  echo "                     (optional)"
  echo "          7. host4 - hostname of device you want to check if available"
  echo "                     (optional)"
  echo "          8. host5 - hostname of device you want to check if available"
  echo "                     (optional)"
  echo
  echo "  callapi - Call API with custom parameters"
  echo "      Arguments:"
  echo "          1. api path - path to API module"
  echo "          2. method - call method [GET|PUT|POST|DELETE|...]"
  echo "          3. body - body this might be needed by API but is undocumented"
  echo "          4. JQ JSON filter - JQ JSON filter or . for all"
  echo
  echo "Examples:"
  echo "  - Download video files"
  echo "      ./ulo.sh '192.168.0.10' 'test' '123!Abc' 'downloadvideos' '/tmp/ulovideo'"
  echo
  echo "Notes from working with ULO:"
  echo "    - When using this tool, ULO usualy wakes up unless it is in Alert mode."
  echo "    - Transfer speeds usualy depends on WiFi signal strength or ULOs"
  echo "      processing power. Due to way how we access files there is not much space"
  echo "      to make this process faster in this code."
  echo "    - Files from ULO memory can be emptied only in standard mode."
  echo "    - This tool properly logs in and logs out into ULO; because of this,"
  echo "      if you use same user for browser access this user will be logged"
  echo "      out along with this tool at the end of execution."
  echo "    - It is advised to create new user without admin privileges to use this"
  echo "      tool, unless you need to perform tasks that require them. For now"
  echo "      it seems that ULO can create mutiple users, but they sometimes have"
  echo "      problems to log in."
  echo "    - If mutiple activities are performed at a same time or their execution"
  echo "      might overlap, it is advised to create separate ULO users for such"
  echo "      activities."
  echo "    - ULO can perform unintended self reeboots which always reset current"
  echo "      camera mode to standard and therefore ULO will stop recodring."
  echo "    - In version 10.1308 and maybe earlier, there is a bug where anyone who"
  echo "      knows about ULO can access all ULO files even when not logged in to ULO,"
  echo "      when at least one user is logged in to ULO no matter where."
  echo "    - In version 10.1308 and maybe earlier, ULO stores WiFi passwords in"
  echo "      plain text inside its system log which is accessible if requested."
}

if [[ -z "${action}" ]]; then
  usage
  exit 0
fi

if ! command -v jq 1>/dev/null 2>&1; then
  echo "ERROR: JQ binary is not installed."
  exit 1
fi

if ! command -v wget 1>/dev/null 2>&1; then
  echo "ERROR: WGET binary is not installed."
  exit 1
fi

auth="Basic $(echo -n "${username}":"${password}" | base64)"
password="******" # We don't have to hold password anymore
output=""

# FUNCTIONS --------------------------------------------------------------------------------

# Usage:
# callapi "${path}" "${method}" "${body}" "${json_filter}"
# echo "${output}"
#
# json_filter - filter in JSON structure, dot (.) can be used to output everything
#               otherwise filter is constructed from element names connected via pipe (|).
#               Detailed documentation how to use syntax in json_filter is here:
#               https://stedolan.github.io/jq/manual/#Basicfilters
#               and online evaluator is here: https://jqplay.org/
callapi() {
  local path="${1}"
  local method="${2}"
  local body="${3}"
  local json_filter="${4}"
  local web_output=""

  web_output="$(curl -s "http://${host}${path}" -X "${method}" -d "${body}" -H "Content-Type: application/json" -H "Authorization: ${auth}")"

  # Check if returned value is valid JSON
  if ! jq -e . >/dev/null 2>&1 <<<"${web_output}"; then
    output="${web_output}"
  else
    output="$(echo "${web_output}" | jq -r "${json_filter}" | sed 's/^null$//')"
  fi
}

login() {
  callapi "/api/v1/login" "POST" "{ \"iOSAgent\": false }" ".token"

  auth="Bearer ${output}"
}

logout() {
  callapi "/api/v1/logout" "POST" "{}" "."

  auth=""
}

getmode() {
  callapi "/api/v1/mode" "GET" "" ".mode"

  echo "${output}"
}

setmode() {
  local mode="${1}"

  callapi "/api/v1/mode" "PUT" "{ \"mode\": \"${mode}\" }" ".mode"

  if [[ "${output}" != "${mode}" ]]; then
    throw "Mode change failed."
  else
    echo "Success."
  fi
}

ispowered() {
  callapi "/api/v1/state" "GET" "" ".plugged"

  echo "${output}"
}

getbattery() {
  callapi "/api/v1/state" "GET" "" ".batteryLevel"

  echo "${output}"
}

iscard() {
  callapi "/api/v1/files/stats" "GET" "" ".sdcard.inserted"

  echo "${output}"
}

getcardspace() {
  callapi "/api/v1/files/stats" "GET" "" ".sdcard.freeMB"

  echo "${output}"
}

getdiskspace() {
  callapi "/api/v1/files/stats" "GET" "" ".internal.freeMB"

  echo "${output}"
}

movetocard() {
  local callapi_output=""
  local mode=""
  local error=""

  mode="$(getmode)"
  setmode "standard" >/dev/null

  callapi "/api/v1/files/backup?filename=all" "PUT" "{\"running\": true}" "."
  callapi_output="${output}"

  setmode "${mode}" >/dev/null

  error="$(echo "${callapi_output}" | jq -r ".error" | sed 's/^null$//')"
  if [[ -n "${error}" ]]; then
    throw "${error}"
  else
    echo "${callapi_output}" | jq -r ".status" | sed 's/^null$//'
  fi
}

cleandiskspace() {
  local period="${1}"

  local callapi_output=""
  local mode=""
  local error=""

  case "${period}" in
    oldestday)
      period="0"
      ;;
    oldestweek)
      period="1"
      ;;
    oldestyear)
      period="2"
      ;;
    latestday)
      period="3"
      ;;
    latestweek)
      period="4"
      ;;
    latestyear)
      period="5"
      ;;
    all)
      period="6"
      ;;
    *)
      throw "Period '${action_name}' is not supported."
      ;;
  esac

  mode="$(getmode)"
  setmode "standard" >/dev/null

  callapi "/api/v1/files/delete?removeType=${period}" "DELETE" "" "."
  callapi_output="${output}"

  setmode "${mode}" >/dev/null

  error="$(echo "${callapi_output}" | jq -r ".error" | sed 's/^null$//')"
  if [[ -n "${error}" ]]; then
    throw "${error}"
  else
    echo "${callapi_output}" | jq -r ".status" | sed 's/^null$//'
  fi
}

downloadmedia() {
  local action_name="${1}"
  local extension="${2}"
  local path_to="${3}"
  local init="none"

  local media_path=""
  local media_url_path=""

  if [[ ! -d "${path_to}" ]]; then
    throw "Path '${path_to}' does not exist."
  fi

  case "${action_name}" in
    downloadlog)
      callapi "/api/v1/system/log" "POST" "/system/log" ".fileName"
      media_url_path="logs/"
      ;;
    currentsnapshot)
      callapi "/api/v1/backgroundImage" "POST" "{}" ".filename"
      media_url_path=""
      ;;
    downloadvideos)
      callapi "/api/v1/files/media" "GET" "" ".files | .[].files | .[]"
      media_url_path=""
      ;;
    downloadsnapshots)
      callapi "/api/v1/files/media" "GET" "" ".files | .[].files | .[]"
      media_url_path=""
      ;;
    *)
      throw "Action '${action_name}' is not supported."
      ;;
  esac

  echo "${output}" | grep "${extension}" | while read -r media; do
    media_path="$(realpath "$(realpath "${path_to}")/$(dirname "${media}" | sed 's/media//')")"
    if [[ "${init}" != "${media_path}" ]]; then
      echo "Storing media files to: ${media_path}"
      local init="${media_path}"
    fi
    wget -c -N -P "${media_path}" "https://${host}/${media_url_path}${media}" --header="Authorization: ${auth}" --no-check-certificate -q --show-progress
    case "${action_name}" in
      currentsnapshot)
        mv "${media_path}/loginPicture.jpg" "${media_path}/snapshot.jpg"
        ;;
    esac
  done
}

testavailability() {
  local host="${1}"

  ping_host "${host}"
}

checkavailability() {
  local if_true="${1}"
  local if_false="${2}"
  local operation="${3}"
  local host1="${4}"
  local host2="${5}"
  local host3="${6}"
  local host4="${7}"
  local host5="${8}"

  local hosts=()
  local result=""
  local result_step="false"

  case "${operation}" in
      and)
        result_step="true"
        ;;
      or)
        result_step="false"
        ;;
      *)
        setmode "${if_false}"
        throw "Operation '${operation}' is not supported."
        ;;
  esac

  if [[ -n "${host1}" ]]; then
    hosts+=(host1)
  fi
  if [[ -n "${host2}" ]]; then
    hosts+=(host2)
  fi
  if [[ -n "${host3}" ]]; then
    hosts+=(host3)
  fi
  if [[ -n "${host4}" ]]; then
    hosts+=(host4)
  fi
  if [[ -n "${host5}" ]]; then
    hosts+=(host5)
  fi

  if [[ "${#hosts[@]}" == "0" ]]; then
    throw "At least one host has to be provided."
  fi

  for host in "${hosts[@]}"
  do
    result="$(ping_host "${host}")"

    case "${operation}" in
      and)
        if [[ "${result}" == "true" ]] && [[ "${result_step}" == "true" ]]; then
          result_step="true"
        else
          result_step="false"
        fi
        ;;
      or)
        if [[ "${result}" == "true" ]] || [[ "${result_step}" == "true" ]]; then
          result_step="true"
        else
          result_step="false"
        fi
        ;;
      *)
        setmode "${if_false}"
        throw "Operation '${operation}' is not supported."
        ;;
    esac
  done

  if [[ "${result_step}" == "true" ]]; then
    case "${operation}" in
      and)
        echo "All devices are available."
        ;;
      or)
        echo "At least one device is available."
        ;;
      *)
        setmode "${if_false}"
        throw "Operation '${operation}' is not supported."
        ;;
    esac
    echo "Setting camera to '${if_true}' mode."
    setmode "${if_true}"
  else
    case "${operation}" in
      and)
        echo "At least one device is not available."
        ;;
      or)
        echo "All devices are not available."
        ;;
      *)
        setmode "${if_false}"
        throw "Operation '${operation}' is not supported."
        ;;
    esac
    echo "Setting camera to '${if_false}' mode."
    setmode "${if_false}"
  fi
}

throw() {
  local error="${1}"

  if [[ -z "${error}" ]]; then
    error="No error message provided."
  fi

  echo -e "ERROR: ${error}"
  exit 1
}

ping_host() {
  local host="${1}"

  if timeout 5 ping -c 1 "${host}"; then
    echo "true"
  else
    echo "false"
  fi
}

# MAIN CODE --------------------------------------------------------------------------------

login

case "${action}" in
  callapi)
    callapi "${arg1}" "${arg2}" "${arg3}" "${arg4}" "${arg5}" "${arg6}" "${arg7}" "${arg8}"
    echo "${output}"
    ;;
  getmode)
    getmode
    ;;
  setmode)
    setmode "${arg1}"
    ;;
  ispowered)
    ispowered
    ;;
  getbattery)
    getbattery
    ;;
  iscard)
    iscard
    ;;
  getcardspace)
    getcardspace
    ;;
  getdiskspace)
    getdiskspace
    ;;
  movetocard)
    movetocard
    ;;
  cleandiskspace)
    cleandiskspace "${arg1}"
    ;;
  downloadlog)
    downloadmedia "${action}" ".zip" "${arg1}"
    ;;
  currentsnapshot)
    downloadmedia "${action}" ".jpg" "${arg1}"
    ;;
  downloadvideos)
    downloadmedia "${action}" ".mp4" "${arg1}"
    ;;
  downloadsnapshots)
    downloadmedia "${action}" ".jpg" "${arg1}"
    ;;
  testavailability)
    testavailability "${arg1}"
    ;;
  checkavailability)
    checkavailability "${arg1}" "${arg2}" "${arg3}" "${arg4}" "${arg5}" "${arg6}" "${arg7}" "${arg8}"
    ;;
  *)
    # Unknown action
    echo "ERROR: Action \"${action}\" is unknown."
    logout
    exit 1
    ;;
esac

logout