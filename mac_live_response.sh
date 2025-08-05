#!/bin/bash

timestamp=$(date +"%Y%m%d_%H%M%S")
output_dir="mac_forensic_evidence_$timestamp"
mkdir -p "$output_dir/browser_history" "$output_dir/logs" "$output_dir/plists" "$output_dir/audit"

log() {
    echo "[*] $1"
}

log "Collecting system info..."
system_profiler -detailLevel full > "$output_dir/system_info.txt" 2>/dev/null

log "Collecting user accounts..."
dscl . -list /Users > "$output_dir/user_accounts.txt"

log "Collecting running processes..."
ps aux > "$output_dir/processes.txt"

log "Collecting login history..."
last > "$output_dir/login_history.txt"

log "Collecting network connections..."
netstat -an > "$output_dir/network_connections.txt"

log "Collecting open files..."
lsof > "$output_dir/open_files.txt" 2>/dev/null

log "Collecting memory information..."
top -l 1 -n 0 | grep PhysMem > "$output_dir/memory_info.txt"

log "Collecting disk information..."
diskutil list > "$output_dir/disk_info.txt"
df -h >> "$output_dir/disk_info.txt"

log "Collecting TCC.db (app permissions)..."
cp ~/Library/Application\ Support/com.apple.TCC/TCC.db "$output_dir/tcc_permissions.db" 2>/dev/null

log "Listing launch items (persistence)..."
{
    ls /Library/LaunchDaemons
    ls /Library/LaunchAgents
    ls ~/Library/LaunchAgents
} > "$output_dir/launch_items.txt" 2>/dev/null

log "Collecting logs..."
cp -R /var/log/* "$output_dir/logs/" 2>/dev/null
cp -R /private/var/log/* "$output_dir/logs/" 2>/dev/null

log "Collecting audit logs (if available)..."
cp -R /private/var/audit/* "$output_dir/audit/" 2>/dev/null

log "Collecting plist files (user/system config)..."
find /Library/Preferences -name "*.plist" -exec cp {} "$output_dir/plists/" \; 2>/dev/null

log "Locating Keychain files (not extracting)..."
find ~/Library/Keychains -type f > "$output_dir/keychain_paths.txt" 2>/dev/null

log "Collecting Safari browser history..."
cp ~/Library/Safari/History.db "$output_dir/browser_history/Safari_History.db" 2>/dev/null

log "Collecting Chrome browser history..."
cp ~/Library/Application\ Support/Google/Chrome/Default/History "$output_dir/browser_history/Chrome_History.db" 2>/dev/null

log "Copying Firefox history..."
cp ~/Library/Application\ Support/Firefox/Profiles/*/places.sqlite "$output_dir/browser_history/Firefox_places.sqlite" 2>/dev/null

log "Zipping the results..."
zip -r "$output_dir.zip" "$output_dir" > /dev/null

log "Done. Evidence saved in $output_dir and zipped in $output_dir.zip"
