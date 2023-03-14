import subprocess

# System Information
sys_info = subprocess.check_output(['system_profiler', '-detailLevel', 'full']).decode()

# User Accounts
users = subprocess.check_output(['dscl', '.', '-list', '/Users']).decode().split()
user_info = {}
for user in users:
    user_info[user] = subprocess.check_output(['dscl', '.', '-read', '/Users/'+user]).decode()

# Network Connections
netstat = subprocess.check_output(['netstat', '-an']).decode()

# Recent Logins
last = subprocess.check_output(['last']).decode()

# Device Enrollment Information
try:
    dev_enroll_config_file = subprocess.check_output(['sudo', 'profiles', 'list', '-type', 'enrollment']).decode().strip()
except subprocess.CalledProcessError:
    dev_enroll_config_file = 'Error: Device Enrollment Information not available or command failed'

# Memory Information
memory = subprocess.check_output(['system_profiler', '-detailLevel', 'full']).decode().split('Memory:\n')[1].split('\n\n')[0]

# Write data to files
with open('sys_info.txt', 'w') as f:
    f.write(sys_info)

with open('user_info.txt', 'w') as f:
    for user, info in user_info.items():
        f.write(f'{user}:\n{info}\n\n')

with open('netstat.txt', 'w') as f:
    f.write(netstat)

with open('last.txt', 'w') as f:
    f.write(last)

with open('dev_enroll_config_file.txt', 'w') as f:
    f.write(dev_enroll_config_file)

with open('memory.txt', 'w') as f:
    f.write(memory)

