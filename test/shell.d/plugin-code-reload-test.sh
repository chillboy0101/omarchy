#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

shell_qml="$ROOT/shell/shell.qml"
source_text=$(cat "$shell_qml")

# QML caches compiled components by URL and Qt 6 has no
# Qt.clearComponentCache, so rebuilding a changed plugin in place keeps its
# old code. A local plugin change must come back through a soft Quickshell
# reload, which waits while the session is locked.
[[ $source_text == *"onTriggered: shell.reloadChangedPlugins()"* ]] ||
  fail "local plugin changes go through reloadChangedPlugins"
[[ $source_text == *"function reloadChangedPlugins()"* && $source_text == *"Quickshell.reload(false)"* ]] ||
  fail "a changed plugin reloads the engine so its new code runs"
[[ $source_text == *'firstPartyServiceFor("omarchy.lock")'* && $source_text == *"lock.locked"* ]] ||
  fail "plugin code reloads wait while the session is locked"
[[ $source_text != *"Qt.clearComponentCache()"* ]] ||
  fail "shell does not rely on Qt.clearComponentCache, which Qt 6 does not provide"
pass "changed plugins reload with their new code"
