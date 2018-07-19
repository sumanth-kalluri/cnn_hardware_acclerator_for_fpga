# cnn_hardware_acclerator_for_fpga
This is a fully parameterized verilog implementation of computation kernels for accleration of the Inference of Convolutional Neural Networks on FPGAs

## Target device: Xilinx Virtex 7 FPGA
## Software Tools : 
Design - Xilinx Vivado 2017

Verification - Python 3.6 for scripting and Xilinx ISE 14.7 command line tools.

### Introduction to the Hardware Accelerator

1.	The idea of the project was to design Verilog templates corresponding to the hardware implementation of the most important mathematical operations that take place in the inference (forward pass) in a convolutional neural network.
2.	In the limited time available only the convolution and the max pooling operations which constitute majority of the computational workload in a CNN were implemented.
3.	Fully parameterized Verilog templates were made for these layers so that custom layers could be synthesized for the CNN architecture of our choice by scaling these templates.

**CONVOLVER:**
This is the convolution unit of the design that computes the sliding window convolution in traditional CNNs given a particular kernel (weights matrix) and an input matrix.

This unit is designed based on the streaming architecture wherein the input matrix (eg. an image in a vision based CNN task) is streamed pixel by pixel in succession into the unit with the kernel weights in place and after a few clock cycles the convolution output appears at the output.

-	Let the size of the kernel be **K * K** and the input feature map be **N * N** (we assume only square matrices for the input and the kernel as is the case in convolutional neural networks).

-	The output becomes valid after **N(K-1)+K** clock cycles. After which the **(k-1)** outputs after every **(N-K+1)** output would be invalid because they correspond to the cases where the weights kernel reaches the end of the row and wraps around to the next row which is not a valid kernel. The valid_conv signal indicates if the present output is a valid one or an invalid one.
 
-	The size of the output feature map is **(N-K+1)*(N-K+1)** and after all the valid outputs are done the end_conv signal is raised indicating the end of convolution for that input.

![convolver](https://user-images.githubusercontent.com/25367201/42937416-91ca9b4e-8b6c-11e8-99e7-0d1ebb9f06f4.jpg)

**ADVANTAGES OF THIS ARCHITECTURE:**

-	The input feature map has to be sent in only once (i.e the stored activations have to be accessed from the memory only once) thus greatly reducing the memory access time and the storage requirement.

-	The convolution for any sized input can be calculated with this architecture without having to break the input or temporarily store it elsewhere due to low compute capability.

**KNOWN LIMITATIONS OF THE CONVOLVER:**

-	This design assumes the value of the ‘Stride’ (the distance by which the convolution kernel moves during each sliding operation) to be equal to ‘One’. This is the case in the vast majority of CNN architectures and extremely few architectures exist with larger strides as it leads to aggressive downsampling.

**POOLER**
 
The pooler is the unit that computes max pooling operation on the output of the convolver. Since to output of the convolver is fed as input to the pooler, it follows a very similar architecture to the streaming architecture of the convolver.
-	The dimensions of the input to the pooler are **M * M** (where **M = N-K+1**).
-	The dimensions of the pooling window are **P * P** where P = 2 in majority of the cases in literature and P = 3 in a very few cases.
-	The dimensions of the output after the pooling operation are **(M/P) * (M/P)**.

![pooler](https://user-images.githubusercontent.com/25367201/42937525-db3c845e-8b6c-11e8-937b-351a52e2056f.jpg)

**ADVANTAGES OF THIS DESIGN:**
-	The pooler follows the same streaming architecture of the convolver and does not require any modification of the convolver outputs. 
-	Even this unit can be easily scaled for any input size and any pooling window size.
-	Contributes to the overall pipelining architecture thus improving throughput.

**KNOWN LIMITATIONS OF THE POOLER:**
1.	The design in its current state has not been made to handle the cases where M is not perfectly divisible by P since it would require zero padding of the input at the borders in order to make the pooling window fit perfectly on the input.
2.	The functionality of the pooler has been formally verified only for the pooling window sizes  P = 2 and P = 3 (since they constitute virtually all of the pooling window sizes used in most of the neural networks) but the unit is expected to function fine for any value of P.
3.	The current design assumes that the ‘stride’ of the pooling window (the distance the window moves horizontally during each sliding operation) is equal to the size of the window (this ensures that there is no overlap between two pooling neighbourhoods). This design currently cannot handle overlapping neighbourhoods.

### Several Incremental Improvements can be made to the current design to make it even more robust and capable of handling real world inputs. Some of them are-
-	Additional functionality can be added to the convolver to handle stride values greater than one. This is very straightforward as for stride greater than one the outputs would be a subset of the current outputs.
-	Since zero padding is conventionally used to modify input sizes, it can be handled directly in hardware for cases where M is not a multiple of P.
-	The pooler can be modified to handle the few cases where there is overlapping between adjacent pooling neighbourhoods.
-	Functionality can be added to handle fixed point and floating point datatypes for practical inputs.
-	A look up table to compute the non-linearity function can be implemented.  

