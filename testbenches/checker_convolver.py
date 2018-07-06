import numpy as np 
from scipy import signal
import subprocess
import os
import math
NoT= 1
klist = [3,5,7,11]
def strideConv(arr, arr2, s):
    return signal.convolve2d(arr, arr2[::-1, ::-1], mode='valid')[::s, ::s]
file2 = open("cr_op.txt",'a')
file3 = open("parameters.txt",'a')
for i in range(NoT):
	file1 = open("ip_data.txt",'w')
	fsize = np.random.randint(28,29,size = 1)
	x = np.random.randint(0,4,size = 1)
	ksize = klist[x[0]]
	arr2 = np.random.randint(5,size = ksize**2).reshape(ksize,ksize)
	arr = np.random.randint(10,size = fsize[0]**2).reshape(fsize[0],fsize[0])
	conv = strideConv(arr,arr2,1)
	for output in conv.flatten():
		file2.write(format(output,'08x')+"\n")
	file2.write("EoT"+str(i)+"\n")
	for x in arr2.flatten():
		file1.write(format(x,'04x')+"\n")
	for y in arr.flatten():
		file1.write(format(y,'04x')+"\n")
	file1.close()
	print(fsize)
	print(ksize)
	print(conv)
	file3.write(str(i)+"."+str(format(fsize[0],'03x'))+" "+str(format(ksize,'03x'))+'\n')
	file4 = open("myproject.prj",'w')
	file4.write("verilog work \"G:\\Xilinx design files\\acclerator\\convolver.v\""+"\n")
	file4.write("verilog work \"G:\\Xilinx design files\\acclerator\\mac_manual.v\""+"\n")
	file4.write("verilog work \"G:\\Xilinx design files\\acclerator\\convolver_tb2.v\""+"\n")
	file4.write("verilog work \"C:\\Xilinx\\14.7\\ISE_DS\\ISE\\verilog\\src\\glbl.v\""+"\n")
	file4.write("verilog work \"G:\\Xilinx design files\\acclerator\\ipcore_dir\\shift.v\"")
	file4.close()
	subprocess.call(["vlogcomp","-prj","myproject.prj"])
	subprocess.call(["fuse","-L","unisims_ver","-L","unimacro_ver","-L","xilinxcorelib_ver","-L","secureip","-o","sim.exe","-prj","myproject.prj","work.glbl","work.convolver_tb2","-d","n=9'h"+str((format(fsize[0],'03x'))),"-d","k=9'h"+str((format(ksize,'03x'))),"-d","tn="+str(i),"-d","c_size="+str(math.ceil(math.log2(fsize[0]**2 + 20)))])
	os.system("C:\\Xilinx\\14.7\\ISE_DS\\settings64.bat /wait sim.exe -tclbatch commands.tcl -intstyle silent && exit(0)")
file2.close()
file3.close()
import difflib
import sys

with open('cr_op.txt', 'r') as hosts0:
    with open('tb_op.txt', 'r') as hosts1:
        diff = difflib.unified_diff(
            hosts0.readlines(),
            hosts1.readlines(),
            fromfile='op.txt',
            tofile='tb_op.txt',
        )
        for line in diff:
            sys.stdout.write(line)