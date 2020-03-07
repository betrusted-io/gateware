/*
 * Security Level: Macronix Proprietary
 * COPYRIGHT (c) 2019 MACRONIX INTERNATIONAL CO., LTD
 * MX66-series verilog behavioral model
 *
 * This README file introduces the verilog of MX66-series behavioral model.
 *
 * Filename: README.txt
 * Issued Date: August 1, 2019
 *
 * Any questions or suggestions, please send emails to:
 *
 *     flash_model@mxic.com.tw
 */

 * Notice: All source files are saved as UNIX text format.

This README file describes MXIC MX66-series verilog behavioral
model. It consists of several sections as follows:

1. Overview
2. Files
3. Usage

1. Overview
---------------------------------
The MX66-series verilog behavioral model is able to assist you to integrate
MX66-series flash product at early simulation stage. There are helpful tips
and notes in this READEME file. Please read this file before applying this
behavioral model.

2. Files
---------------------------------
The following files will be available after extracting the zipped file
(or other compression format):

  MX66XXXX\
    |- README.txt
    |- MX66XXXX.v


The naming rule of MX66-series verilog behavioral model is as follows:

  MX66XXXX.v:
      ---- -
       |   |--> v. Verilog source code.
       |
       |------> Flash's part name. Ex: MX66U1G45G.

3. Usage
---------------------------------
The MX66-series behavioral model can be applied directly at the simulation
stage. Please connect correct wires to top module of this model according to
flash datasheet. This is not a synthesizable verilog code but for functional
simulation only. Please be aware of the followings:

a. The model can load initial flash data from a file by parameter definition.
   Users can change File_Name, File_Name_Secu or File_Name_SFDP definition with
   initial data's file name.
   Default file name is "none" and initial flash data is "FF".

   for normal array, initial data:
   `define  File_Name = "xxx";

   for Security array, initial data:
   `define  File_Name_Secu = "xxx";

   for SFDP array, initial data:
   `define  File_Name_SFDP = "xxx";

   where xxx: initial flash data file name, default is "none".

   For example: `define File_Name_SFDP	"MX66U1G45GXDI0A_V2.sfdp"
   to initial the SFDP data from file MX66U1G45XDI0A_V2.sfdp.

b. Note that the behavioral model needs to wait for power setup time, tVSL.
   After tVSL time, chip can be fully accessible. If tPUW has defined, read
   instruction and write instruction can be accepted by flash after tVSL and
   tPUW time. The tPUW is longer than tVSL.

   tPUW is not defined:

      |     |---------tVSL---------|
      |____________________________|
      |                            |
   Power on              Read/Write enable


   tPUW is defined:

      |  |----------tPUW------------|
      |     |--tVSL--|              |
      |_____________________________|
      |              |              |
   Power on     Read enable    Write enable

c. More than one value (min. typ. max. value) is defined for some AC parameters
   in the datasheet. But only one of them is selected in the behavioral model,
   e.g. program and erase cycle time is the typical value. For detailed
   information of the parameters, please refer to the datasheet and feel free
   to contact Macronix.

d. For ECC failure would never occured in model, ECC_ONE_BIT_FRATE, 
   ECC_TWO_BIT_FRATE, ECC_ONE_BIT_FRATE_SOTP, ECC_TWO_BIT_FRATE_SOTP,
   ECC_ONE_BIT_FRATE_SFDP and ECC_TWO_BIT_FRATE_SFDP is defined in model.
   Users can change defined value of ECC_ONE_BIT_FRATE and
   ECC_TWO_BIT_FRATE to change the ECC 1-bit and 2-bit faillure rate,
   (or ECC_ONE_BIT_FRATE_SOTP, ECC_TWO_BIT_FRATE_SOTP for security OTP region,
   and ECC_ONE_BIT_FRATE_SFDP, ECC_TWO_BIT_FRATE_SFDP for SFDP region,)
   and the model would generate the ECC 1-bit/2-bit error randomly
   according to the defined failure rate.
   Default faliure rate is "0" for all the failure rate parameters.

   `define ECC_ONE_BIT_FRATE value1
   `define ECC_TWO_BIT_FRATE value2
   `define ECC_ONE_BIT_FRATE_SOTP value3
   `define ECC_TWO_BIT_FRATE_SOTP value4
   `define ECC_ONE_BIT_FRATE_SFDP value5
   `define ECC_TWO_BIT_FRATE_SFDP value6

   where value1: ECC 1-bit error failure probability in normal array;
   0 - means no 1-bit ECC failure occured;
   1 - means 1-bit ECC failure occured 100%;
   Other integers - means 1-bit ECC failure rate is 1/value1 * 100%.

   where value2: ECC 2-bit error failure probability in normal array;
   0 - means no 2-bit ECC failure occured;
   1 - means 2-bit ECC failure occured 100%;
   Other integers - means 2-bit ECC failure rate is 1/value2 * 100%.

   where value3: ECC 1-bit error failure probability in security OTP region;
   0 - means no 1-bit ECC failure occured;
   1 - means 1-bit ECC failure occured 100%;
   Other integers - means 1-bit ECC failure rate is 1/value1 * 100%.

   where value4: ECC 2-bit error failure probability in security OTP region;
   0 - means no 2-bit ECC failure occured;
   1 - means 2-bit ECC failure occured 100%;
   Other integers - means 2-bit ECC failure rate is 1/value2 * 100%.

   where value5: ECC 1-bit error failure probability in SFDP region;
   0 - means no 1-bit ECC failure occured;
   1 - means 1-bit ECC failure occured 100%;
   Other integers - means 1-bit ECC failure rate is 1/value1 * 100%.

   where value6: ECC 2-bit error failure probability in SFDP region;
   0 - means no 2-bit ECC failure occured;
   1 - means 2-bit ECC failure occured 100%;
   Other integers - means 2-bit ECC failure rate is 1/value2 * 100%.

   Please note that if both ECC_ONE_BIT_FRATE and ECC_TWO_BIT_FRATE
   (or ECC_ONE_BIT_FRATE_SOTP and ECC_TWO_BIT_FRATE_SOTP,
   ECC_ONE_BIT_FRATE_SFDP and ECC_TWO_BIT_FRATE_SFDP) are set to 1,
   only 2-bit ECC failure occured 100%, and without 1-bit ECC failure.

e. If there is a preloading data for the flash initialization of normal array,
   It is necessary to initialize all the ECC data for the corresponding memory data.
   Because of the calculation of all the ECC data for the initial data of normal array,
   it might cost a few minute in the initial step of simulation.
