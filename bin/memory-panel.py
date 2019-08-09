#!/bin/env python

import os
import subprocess

# variables
GB_VAL = 1048576.0
MEM_TOTAL = 0
MEM_TOTAL_GB = 0.0
MEM_USED = 0
MEM_USED_GB = 0.0
MEM_FREE = 0
MEM_FREE_GB = 0.0
MEM_SHARED = 0
MEM_SHARED_GB = 0.0
MEM_CACHE = 0
MEM_CACHE_GB = 0.0
MEM_AVAIL = 0
MEM_AVAIL_GB = 0.0
SWP_TOTAL = 0
SWP_TOTAL_GB = 0.0
SWP_USED = 0
SWP_USED_GB = 0.0
SWP_FREE = 0
SWP_FREE_GB = 0.0
MEM_USED_PERCENT = 0.0

# run 'free' command to get memory info
free_output = ''
try:
    free_cmd = 'free -bk'
    p = subprocess.Popen(free_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    p.wait()
    stdout, stderr = p.communicate()
    stdout = stdout.decode('UTF-8')
    free_output = stdout
except:
    free_output = ''

# parse 'free' output
lines = free_output.split('\n')
del free_output
for line in lines:
    if line.startswith('Mem:'):
        line = line.replace('Mem:', '')
        # parse mem line
        mem_parts = line.split()
        if len(mem_parts) == 6:
            MEM_TOTAL = int(mem_parts[0])
            MEM_USED = int(mem_parts[1])
            MEM_FREE = int(mem_parts[2])
            MEM_SHARED = int(mem_parts[3])
            MEM_CACHE = int(mem_parts[4])
            MEM_AVAIL = int(mem_parts[5])
        del mem_parts
    elif line.startswith('Swap:'):
        line = line.replace('Swap:', '')
        swp_parts = line.split()
        if len(swp_parts) == 3:
            SWP_TOTAL = int(swp_parts[0])
            SWP_USED = int(swp_parts[1])
            SWP_FREE = int(swp_parts[2])
        del swp_parts


# calculate values
if MEM_TOTAL > 0:
    MEM_USED_PERCENT = (float(MEM_USED) / float(MEM_TOTAL)) * 100.00
MEM_TOTAL_GB = MEM_TOTAL / GB_VAL
MEM_USED_GB = MEM_USED / GB_VAL
MEM_FREE_GB = MEM_FREE / GB_VAL
MEM_SHARED_GB = MEM_SHARED / GB_VAL
MEM_CACHE_GB = MEM_CACHE / GB_VAL
MEM_AVAIL_GB = MEM_AVAIL / GB_VAL
SWP_TOTAL_GB = SWP_TOTAL / GB_VAL
SWP_USED_GB = SWP_USED / GB_VAL
SWP_FREE_GB = SWP_FREE / GB_VAL


output_buf = ""

output_buf += "<txt>{0:.0f}%</txt>\n".format(MEM_USED_PERCENT)
output_buf += "<bar>{0:.0f}%</bar>\n".format(MEM_USED_PERCENT)
output_buf += "<tool>\n"
output_buf += "RAM Used {0:.2f} %\n".format(MEM_USED_PERCENT)
output_buf += "RAM\n"
output_buf += "  Used\t{0:.2f} GB\n".format(MEM_USED_GB)
output_buf += "  Free\t{0:.2f} GB\n".format(MEM_FREE_GB)
output_buf += "  Shared\t{0:.2f} GB\n".format(MEM_SHARED_GB)
output_buf += "  Cache\t{0:.2f} GB\n".format(MEM_CACHE_GB)
output_buf += "  Total\t{0:.2f} GB\n".format(MEM_TOTAL_GB)
output_buf += "\n"
output_buf += "SWAP\n"
output_buf += "  Used\t{0:.2f} GB\n".format(SWP_USED_GB)
output_buf += "  Free\t{0:.2f} GB\n".format(SWP_FREE_GB)
output_buf += "  Total\t{0:.2f} GB\n".format(SWP_TOTAL_GB)
output_buf += "</tool>"

print(output_buf)
