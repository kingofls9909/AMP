#!/bin/bash
set -e

LICENSE_KEY="${AMP_LICENCE:-$AMP_LICENSE}"
AMP_USER="${AMP_USERNAME:-admin}"
AMP_PASS="${AMP_PASSWORD:-ChangeMe123!}"
AMP_PORT="${AMP_PORT:-8080}"

if [ "$(uname -m)" = "aarch64" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-arm64"
else
    export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
fi

shutdown_handler() {
    echo ">> [SYS] Stopping container. Safely shutting down AMP instances..."
    runuser -u amp -- ampinstmgr StopAll || true
    exit 0
}
trap 'shutdown_handler' SIGTERM SIGINT SIGQUIT

if [ -z "$LICENSE_KEY" ]; then
    echo ">> [ERR] AMP_LICENCE environment variable is missing!" >&2
    exit 1
fi

echo ">> [INIT] License Key detected: ${LICENSE_KEY:0:8}-****"
echo ">> [INIT] Target configuration: User='${AMP_USER}' Port='${AMP_PORT}'"

chown -R amp:amp /home/amp

if runuser -u amp -- ampinstmgr status | grep -i -q "ADS01"; then
    echo ">> [INFO] Existing instance 'ADS01' found."
    
    # Query instance info directly via ampinstmgr to check current port
    INSTANCE_INFO=$(runuser -u amp -- ampinstmgr ShowInstanceInfo ADS01 2>&1 || true)
    CURRENT_PORT=$(echo "$INSTANCE_INFO" | grep -i "URL" | awk -F'│' '{print $2}' | sed -E 's/.*:([0-9]+)\/?.*/\1/' | tr -d ' ')

    if [ -n "$CURRENT_PORT" ] && [ "$CURRENT_PORT" != "$AMP_PORT" ]; then
        echo ">> [NET] Port change detected (Current: $CURRENT_PORT, Target: $AMP_PORT). Rebinding ADS01..."
        echo "Y" | runuser -u amp -- ampinstmgr --RebindInstance ADS01 0.0.0.0 "$AMP_PORT" || true
    fi
else
    echo ">> [INIT] ADS01 instance not found. Provisioning new ADS controller..."

    runuser -u amp -- bash -c "export DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp; ampinstmgr --CreateInstance ADS ADS01 0.0.0.0 \"$AMP_PORT\" \"$LICENSE_KEY\" \"$AMP_USER\" \"$AMP_PASS\" +Networking.UPnPEnabled=False"

    if [ $? -eq 0 ]; then
        echo ">> [INIT] ADS01 created successfully."
        echo ">> [AUTH] Setting credentials..."
        runuser -u amp -- ampinstmgr ResetLogin ADS01 "$AMP_USER" "$AMP_PASS" || true
        
        touch /home/amp/init_done
        chown amp:amp /home/amp/init_done
    else
        echo ">> [ERR] ampinstmgr failed to create instance." >&2
        exit 1
    fi
fi

echo ">> [SYS] Starting ADS01 instance..."
runuser -u amp -- ampinstmgr --StartInstance ADS01 || true

(
  while true; do
    sleep 60
    runuser -u amp -- ampinstmgr --silent ProcessPendingTasks >/dev/null 2>&1 || true
  done
) &

echo ">> [INFO] ADS01 online. Access via web panel or inspect logs in .ampdata/instances/ADS01/AMP_Logs"
tail -f /dev/null &
wait $!
