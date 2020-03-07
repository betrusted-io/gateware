// Retrieved from https://www.macronix.com/en-us/support/technical-documentation/Pages/Serial-NOR-Flash.aspx#!Verilog-Models
// on January 25, 2020. Public website, no login or click-through agreement.
// *============================================================================================== 
// *
// *   MX66UM1G45G.v - 1G-BIT CMOS Serial Flash Memory
// *
// *           COPYRIGHT 2019 Macronix International Co., Ltd.
// *
// * Security Level: Macronix Proprietary
// *----------------------------------------------------------------------------------------------
// * Environment  : Cadence NC-Verilog
// * Reference Doc: MX66UM1G45G REV.1.0,DEC.24,2018
// * Creation Date: @(#)$Date: 2019/07/30 03:37:28 $
// * Version      : @(#)$Revision: 1.6 $
// * Description  : There is only one module in this file
// *                module MX66UM1G45G->behavior model for the 1G-Bit flash
// *----------------------------------------------------------------------------------------------
// * Note 1:model can load initial flash data from file when parameter Init_File = "xxx" was defined; 
// *        xxx: initial flash data file name;default value xxx = "none", initial flash data is "FF".
// * Note 2:power setup time is tVSL = 1_500_000 ns, so after power up, chip can be enable.
// * Note 3:because it is not checked during the Board system simulation the tCLQX timing is not
// *        inserted to the read function flow temporarily. And thus tQH is not used, too.
// * Note 4:more than one values (min. typ. max. value) are defined for some AC parameters in the
// *        datasheet, but only one of them is selected in the behavior model, e.g. program and
// *        erase cycle time is typical value. For the detailed information of the parameters,
// *        please refer to datasheet and contact with Macronix.
// * Note 5:If you have any question and suggestion, please send your mail to following email address :
// *                                    flash_model@mxic.com.tw
// *============================================================================================== 
// * timescale define
// *============================================================================================== 
`timescale 1ns / 10ps

// *============================================================================================== 
// * product parameter define
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* all the parameters users may need to change                          */
    /*----------------------------------------------------------------------*/
        `define MODEL_CODE_00               //Default STR, X1 IO enable, Support password protection feature
//      `define LOADING_30PF                //Loading: 30pF
//      `define LOADING_20PF                //Loading: 20pF
//      `define LOADING_15PF                //Loading: 15pF
        `define LOADING_12PF                //Loading: 12pF


        `define ECC_ONE_BIT_FRATE       0   //ECC 1-bit fail rate for normal array
        `define ECC_TWO_BIT_FRATE       0   //ECC 2-bit fail rate for normal array
        `define ECC_ONE_BIT_FRATE_SOTP  0   //ECC 1-bit fail rate for security OTP region
        `define ECC_TWO_BIT_FRATE_SOTP  0   //ECC 2-bit fail rate for security OTP region
        `define ECC_ONE_BIT_FRATE_SFDP  0   //ECC 1-bit fail rate for SFDP region
        `define ECC_TWO_BIT_FRATE_SFDP  0   //ECC 2-bit fail rate for SFDP region
        `ifdef LOADING_30PF
                `define Vtclqv 5.5    //30pF: 5.5ns, 20pF:5.5ns, 15pF:5.5ns, 12pf:5ns
                `define Vtdqsq 1.2    //30pF: 1.2ns, 20pF: 0.8ns, 15pF: 0.65ns, 12pF: 0.55ns
                `define Vtqhs  1.4     //30pF: 1.4ns, 20pF: 1ns, 15pF: 0.85ns, 12pF: 0.75ns
        `elsif LOADING_20PF
                `define Vtclqv 5.5    //30pF: 5.5ns, 20pF:5.5ns, 15pF:5.5ns, 12pf:5ns
                `define Vtdqsq 0.8    //30pF: 1.2ns, 20pF: 0.8ns, 15pF: 0.65ns, 12pF: 0.55ns
                `define Vtqhs  1     //30pF: 1.4ns, 20pF: 1ns, 15pF: 0.85ns, 12pF: 0.75ns
        `elsif LOADING_15PF
                `define Vtclqv 5.5    //30pF: 5.5ns, 20pF:5.5ns, 15pF:5.5ns, 12pf:5ns
                `define Vtdqsq 0.65    //30pF: 1.2ns, 20pF: 0.8ns, 15pF: 0.65ns, 12pF: 0.55ns
                `define Vtqhs  0.85     //30pF: 1.4ns, 20pF: 1ns, 15pF: 0.85ns, 12pF: 0.75ns
        `elsif LOADING_12PF
                `define Vtclqv 5    //30pF: 5.5ns, 20pF:5.5ns, 15pF:5.5ns, 12pf:5ns
                `define Vtdqsq 0.55    //30pF: 1.2ns, 20pF: 0.8ns, 15pF: 0.65ns, 12pF: 0.55ns
                `define Vtqhs  0.75     //30pF: 1.4ns, 20pF: 1ns, 15pF: 0.85ns, 12pF: 0.75ns
        `endif


        `define File_Name                "../run/simspi.init" // Flash data file name for normal array
        `define File_Name_Secu           "none"         // Flash data file name for security region
        `define File_Name_SFDP           "none"         // Flash data file name for SFDP region
        `define VSecur_Reg1_0            2'b00          // security register[1:0]
        `define VStatus_Reg7_2           6'b000000      // status register[7:2] are non-volatile bits
        `define CR_Default4_0            5'b00111       // configuration register default value
        `ifdef MODEL_CODE_0A
            `define CR2_0x40000000_Default   8'hff      // configuration register 2 of 0x4000_0000 default value
        `elsif MODEL_CODE_00
            `define CR2_0x40000000_Default   8'hff      // configuration register 2 of 0x4000_0000 default value
        `endif
        `define VLock_Reg                8'hff          // lock register
        `define VPwd_Reg                 64'hffff_ffff_ffff_ffff   // password register
        `define VFB_Reg                  32'hffff_ffff  // fast boot register
        


    /*----------------------------------------------------------------------*/
    /* Define controller STATE                                              */
    /*----------------------------------------------------------------------*/
        `define         STANDBY_STATE           0
        `define         CMD_STATE               1
        `define         BAD_CMD_STATE           2
        `define         FAST_BOOT_STATE         3

module MX66UM1G45G( SCLK, 
                    CS, 
                    SIO, 
                    DQS,
                    ECSB,
                    RESET );

// *============================================================================================== 
// * Declaration of ports (input, output, inout)
// *============================================================================================== 
    input        SCLK;    // Signal of Clock Input
    input        CS;      // Chip select (Low active)
    inout [7:0]  SIO;     // Serial Input/Output Bus
    output       DQS;     // Data Strobe Signal
    output       ECSB;    // ECC error detect, Active Low 
    input        RESET;   // Hardware Reset Pin, Active Low

// *============================================================================================== 
// * Declaration of parameter (parameter)
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* Density STATE parameter                                              */                  
    /*----------------------------------------------------------------------*/
    parameter   A_MSB           = 26,            
                TOP_Add         = 20'hfffff, //27'h7ffffff,  // CHANGED TO SPEED UP SIMULATION
                A_MSB_OTP       = 9,                
                Secur_TOP_Add   = 10'h3ff,
                Sector_MSB      = 14,
                A_MSB_SFDP       = 8,
                SFDP_TOP_Add     = 9'h1ff,
                ECC_TOP_Add      = 23'h7fffff,
                SOTP_ECC_TOP_Add = 6'h3f,
                SFDP_ECC_TOP_Add = 5'h1f,
                Buffer_Num      = 256,
                Block_MSB       = 10,
                Block_NUM       = 2048;
  
    /*----------------------------------------------------------------------*/
    /* Define ID Parameter                                                  */
    /*----------------------------------------------------------------------*/
    parameter   ID_MXIC         = 8'hc2,
                ID_Device       = 8'h16,
                Memory_Type     = 8'h80,
                Memory_Density  = 8'h3b;

    /*----------------------------------------------------------------------*/
    /* Define Initial Memory File Name                                      */
    /*----------------------------------------------------------------------*/
    parameter   Init_File       = `File_Name;      // initial flash data
    parameter   Init_File_Secu  = `File_Name_Secu; // initial flash data for security
    parameter   Init_File_SFDP  = `File_Name_SFDP; // initial flash data for SFDP

    /*----------------------------------------------------------------------*/
    /* AC Characters Parameter                                              */
    /*----------------------------------------------------------------------*/
    parameter   tSHQZ           = 8,        // CS High to SO Float Time
                tCLQV           = `Vtclqv,          // Clock Low to Output Valid
                tCHQV           = `Vtclqv,          // Clock High to Output Valid
                tCLQX           = 1,        // Output hold time
                tQSLZ           = 5.5,       // DQ pre-drive active time
                tECSV           = 10,        // ECS# pin go low delay time
                tCEH            = 20,         // CS# high time after program
                tBP             = 150_000,      //  Byte program time
                tSE             = 25_000_000,      // Sector erase time  
                tBE             = 250_000_000,      // Block erase time
                tCE             = 150_000,      // unit is ms instead of ns  
                tPP             = 150_000,      // Program time
                tWR_END         = 2_000,          // the time of write operation going to end, suspend not work 
                tW              = 40_000_000,       // Write Status/Configuration Register Cycle Time
                tW2V            = 40,     // Write Configuration Register 2 volatile bit
                tW2N            = 60_000,     // Write Configuration Register 2 non-volatile bit
                tWRFBR          = 150_000,   // Write fast boot register time
                tWRPASS         = 150_000,  // Write password register time
                tPASSULK        = 2_000, // Right password check time
                tPASSULK_FAIL   = 150_000,    // Password check fail waiting time
                tREADY2_P       = 310_000,  // hardware reset recovery time for pgm
                tREADY2_SE      = 12_000_000,  // hardware reset recovery time for sector ers
                tREADY2_BE      = 25_000_000,  // hardware reset recovery time for block ers
                tREADY2_CE      = 100_000_000,  // hardware reset recovery time for chip ers
                tREADY2_R       = 40_000,  // hardware reset recovery time for read
                tREADY2_D       = 40_000,  // hardware reset recovery time for instruction decoding phase
                tREADY2_W       = 40_000_000,  // hardware reset recovery time for WRSR
                tVSL            = 10_000; //1_500_000;     // Time delay to chip select allowed; shorten for simulation expedience

    parameter   tPGM_CHK        = 2_000, // 2 us
                tERS_CHK        = 100_000; // 100 us

    parameter   tESL            = 25_000,       // delay after sector erase suspend command
                tPSL            = 25_000,       // delay after sector erase suspend command
                tPRS            = 100_000,      // latency between program resume and next suspend
                tERS            = 400_000;      // latency between erase resume and next suspend

    parameter   tDQSQ           = `Vtdqsq;   // SIO valid skew related to DQS
    parameter   tQHS            = `Vtqhs;// SIO hold time related to DQS

    /*----------------------------------------------------------------------*/
    /* Internal counter parameter                                           */
    /*----------------------------------------------------------------------*/
    parameter  Clock             = 50,      // Internal clock cycle = 100ns
               ERS_Count_SE      = tSE / (Clock*2) / 20,     // Internal clock cycle = 2us
               ERS_Count_BE      = tBE / (Clock*2) / 20,     // Internal clock cycle = 2us
               Echip_Count       = tCE  / (Clock*2) * 2000;

    specify
        specparam   tSCLK   = 7.5,    // Clock Cycle Time [ns]
                    fSCLK   = 133,    // Clock Frequence except READ instruction

                    tRSCLK  = 15.2,   // Clock Cycle Time for READ instruction [ns]
                    fRSCLK  = 66,   // Clock Frequence for READ instruction

                    tOSCLK  = 5,   // Clock Cycle Time for 8XI/O [ns]
                    fOSCLK  = 200,   // Clock Cycle Time for 8XI/O 

                    tOSTRSCLK1 = 5,   // Clock Cycle Time for 8XI/O STR READ instruction
                    tOSTRSCLK2 = 6,   // Clock Cycle Time for 8XI/O STR READ instruction
                    tOSTRSCLK3 = 6,   // Clock Cycle Time for 8XI/O STR READ instruction
                    tOSTRSCLK4 = 7.5,   // Clock Cycle Time for 8XI/O STR READ instruction
                    tOSTRSCLK5 = 9.6,   // Clock Cycle Time for 8XI/O STR READ instruction
                    tOSTRSCLK6 = 9.6,   // Clock Cycle Time for 8XI/O STR READ instruction
                    tOSTRSCLK7 = 11.9,   // Clock Cycle Time for 8XI/O STR READ instruction
                    tOSTRSCLK8 = 15.1,   // Clock Cycle Time for 8XI/O STR READ instruction
                    fOSTRSCLK1 = 200,   // Clock Frequence for 8XI/O STR READ instruction
                    fOSTRSCLK2 = 166,   // Clock Frequence for 8XI/O STR READ instruction
                    fOSTRSCLK3 = 166,   // Clock Frequence for 8XI/O STR READ instruction
                    fOSTRSCLK4 = 133,   // Clock Frequence for 8XI/O STR READ instruction
                    fOSTRSCLK5 = 104,   // Clock Frequence for 8XI/O STR READ instruction
                    fOSTRSCLK6 = 104,   // Clock Frequence for 8XI/O STR READ instruction
                    fOSTRSCLK7 = 84,   // Clock Frequence for 8XI/O STR READ instruction
                    fOSTRSCLK8 = 66,   // Clock Frequence for 8XI/O STR READ instruction

                    tODTRSCLK1 = 5,   // Clock Cycle Time for 8XI/O DTR READ instruction
                    tODTRSCLK2 = 6,   // Clock Cycle Time for 8XI/O DTR READ instruction
                    tODTRSCLK3 = 6,   // Clock Cycle Time for 8XI/O DTR READ instruction
                    tODTRSCLK4 = 7.5,   // Clock Cycle Time for 8XI/O DTR READ instruction
                    tODTRSCLK5 = 9.6,   // Clock Cycle Time for 8XI/O DTR READ instruction
                    tODTRSCLK6 = 9.6,   // Clock Cycle Time for 8XI/O DTR READ instruction
                    tODTRSCLK7 = 11.9,   // Clock Cycle Time for 8XI/O DTR READ instruction
                    tODTRSCLK8 = 15.1,   // Clock Cycle Time for 8XI/O DTR READ instruction
                    fODTRSCLK1 = 200,   // Clock Frequence for 8XI/O DTR READ instruction
                    fODTRSCLK2 = 166,   // Clock Frequence for 8XI/O DTR READ instruction
                    fODTRSCLK3 = 166,   // Clock Frequence for 8XI/O DTR READ instruction
                    fODTRSCLK4 = 133,   // Clock Frequence for 8XI/O DTR READ instruction
                    fODTRSCLK5 = 104,   // Clock Frequence for 8XI/O DTR READ instruction
                    fODTRSCLK6 = 104,   // Clock Frequence for 8XI/O DTR READ instruction
                    fODTRSCLK7 = 84,   // Clock Frequence for 8XI/O DTR READ instruction
                    fODTRSCLK8 = 66,   // Clock Frequence for 8XI/O DTR READ instruction

                    tCH_SPI = 3.38,    // Clock High Time (min) for SPI mode [ns]
                    tCL_SPI = 3.38,    // Clock Low  Time (min) for SPI mode [ns]
                    tCH_OPI = 2.25,    // Clock High Time (min) for OPI mode [ns]
                    tCL_OPI = 2.25,    // Clock Low  Time (min) for OPI mode [ns]
                    tCH_R   = 6.8,    // Clock High Time (min) for Normal Read [ns] 
                    tCL_R   = 6.8,    // Clock Low  Time (min) for Normal Read [ns]
                    tSLCH   = 4.5,    // CS# Active Setup Time (relative to SCLK) (min) [ns]
                    tCHSL   = 3,    // CS# Not Active Hold Time (relative to SCLK)(min) [ns]
                    tSHSL_R = 10,    // CS High Time for read instruction (min) [ns]
                    tSHSL_W = 40,    // CS High Time for write instruction (min) [ns]
                    tDV     = 1.5,      // Data Valid Time, tDVCH + tCHDX, or tDVCL + tCLDX, (min) [ns]

                    tDVCH_STR_133L   = 2,    // Data In Setup Time STR <= 133MHz (min) [ns]
                    tDVCH_STR_133R   = 1,    // Data In Setup Time STR > 133MHz (min) [ns]

                    tDVCH_DTR_100L   = 1,    // Data Setup Time DTR <= 100MHz (min) [ns]
                    tDVCH_DTR_133L   = 0.8,    // Data Setup Time DTR <= 133MHz (min) [ns]
                    tDVCH_DTR_166L   = 0.6,    // Data Setup Time DTR <= 166MHz (min) [ns]
                    tDVCH_DTR_166R   = 0.5,    // Data Setup Time DTR > 166MHz (min) [ns]

                    tDVCL_DTR_100L   = 1,    // Data Setup Time DTR <= 100MHz (min) [ns]
                    tDVCL_DTR_133L   = 0.8,    // Data Setup Time DTR <= 133MHz (min) [ns]
                    tDVCL_DTR_166L   = 0.6,    // Data Setup Time DTR <= 166MHz (min) [ns]
                    tDVCL_DTR_166R   = 0.5,    // Data Setup Time DTR > 166MHz (min) [ns]

                    tCHDX_STR_133L   = 2,    // Data In Hold Time STR <= 133MHz (min) [ns]
                    tCHDX_STR_133R   = 1,    // Data In Hold Time STR > 133MHz (min) [ns]

                    tCHDX_DTR_100L   = 1,    // Data Hold Time DTR <= 100MHz (min) [ns]
                    tCHDX_DTR_133L   = 0.8,    // Data Hold Time DTR <= 133MHz (min) [ns]
                    tCHDX_DTR_166L   = 0.6,    // Data Hold Time DTR <= 166MHz (min) [ns]
                    tCHDX_DTR_166R   = 0.5,    // Data Hold Time DTR > 166MHz (min) [ns]

                    tCLDX_DTR_100L   = 1,    // Data Hold Time DTR <= 100MHz (min) [ns]
                    tCLDX_DTR_133L   = 0.8,    // Data Hold Time DTR <= 133MHz (min) [ns]
                    tCLDX_DTR_166L   = 0.6,    // Data Hold Time DTR <= 166MHz (min) [ns]
                    tCLDX_DTR_166R   = 0.5,    // Data Hold Time DTR > 166MHz (min) [ns]

                    tCHSH   = 3,    // CS# Active Hold Time STR (relative to SCLK) (min) [ns]
                    tCLSH   = 3,    // CS# Active Hold Time DTR (relative to SCLK) (min) [ns]
                    tSHCH_STR   = 3,    // CS# Not Active Setup Time STR (relative to SCLK) (min) [ns]
                    tSHCH_DTR   = 3,    // CS# Not Active Setup Time DTR (relative to SCLK) (min) [ns]

                    tFBSCLK   = 9.6,    // Clock Cycle Time for Fast Boot Read 
                    tFBSCLK2  = 7.5,   // Clock Cycle Time for Fast Boot Read 
                    tFBSCLK3  = 6.0,   // Clock Cycle Time for Fast Boot Read 
                    tFBSCLK4  = 5.0,   // Clock Cycle Time for Fast Boot Read
                    fFBSCLK   = 104,    // Clock Frequence for Fast Boot Read 
                    fFBSCLK2  = 133,   // Clock Frequence for Fast Boot Read 
                    fFBSCLK3  = 166,   // Clock Frequence for Fast Boot Read 
                    fFBSCLK4  = 200,   // Clock Frequence for Fast Boot Read 

                    tRLRH   = 10_000,   // hardware reset pulse (min) [ns]
                    tRS     = 15,     // reset setup time (min) [ns]
                    tRH     = 15,     // reset hold time (min) [ns]
                    tRHSL   = 10_000,     // RESET# high before CS# low (min) [ns]
                    tDP     = 10_000,     //CS# High to Deep Power-down Mode (max) [ns]
                    tRES1   = 30_000;    //CS# High to Standby Mode without Electronic Signature Read (max) [ns]
     endspecify


    /*----------------------------------------------------------------------*/
    /* Define Command Parameter                                             */
    /*----------------------------------------------------------------------*/
    parameter   WREN        = 8'h06, // WriteEnable   
                WRDI        = 8'h04, // WriteDisable  
                RDID        = 8'h9F, // ReadID    
                RDSR        = 8'h05, // ReadStatus        
                WRSR        = 8'h01, // WriteStatus
                RDCR        = 8'h15, // read configuration register   
                RDCR2       = 8'h71, // read configuration register2      
                WRCR2       = 8'h72, // write configuration register2
                READ1X3B    = 8'h03, // ReadData by 3 byte address
                READ1X4B    = 8'h13, // ReadData by 4 byte address         
                FASTREAD1X3B= 8'h0b, // FastReadData by 3 byte address 
                FASTREAD1X4B= 8'h0c, // FastReadData by 4 byte address  
                SE3B        = 8'h20, // SectorErase by 3 byte address   
                SE4B        = 8'h21, // SectorErase by 4 byte address   
                CE1         = 8'h60, // ChipErase         
                CE2         = 8'hc7, // ChipErase         
                PP3B        = 8'h02, // PageProgram by 3 byte address
                PP4B        = 8'h12, // PageProgram by 4 byte address
                DP          = 8'hb9, // DeepPowerDown
                RDP         = 8'hab, // ReleaseFromDeepPowerDown
                BE3B        = 8'hd8, // BlockErase by 3 byte address
                BE4B        = 8'hdc, // BlockErase by 4 byte address        
                ENSO        = 8'hb1, // Enter secured OTP;
                EXSO        = 8'hc1, // Exit  secured OTP;
                SBL         = 8'hc0, // set burst length
                RDSCUR      = 8'h2b, // Read  security  register;
                WRSCUR      = 8'h2f, // Write security  register;
                READ8X      = 8'hec, // 8XI/O Read
                DDRREAD8X   = 8'hee, // 8XI/O Read
                SFDP_READ   = 8'h5a, // enter SFDP read mode
                NOP         = 8'h00, // no operation
                RSTEN       = 8'h66, // reset enable
                RST         = 8'h99, // reset memory
                WPSEL       = 8'h68, // write protection selection
                WRLR        = 8'h2c, // write lock register
                RDLR        = 8'h2d, // read lock register
                WRPASS      = 8'h28, // Write password register
                PASSULK     = 8'h29, // Password unlock;
                RDPASS      = 8'h27, // Read password register
                WRSPB       = 8'he3, // SPB bit program
                ESSPB       = 8'he4, // SPB bit erase
                RDSPB       = 8'he2, // SPB bit read
                WRDPB       = 8'he1, // DPB bit write
                RDDPB       = 8'he0, // DPB bit read
                GBLK        = 8'h7e, // gang block lock
                GBULK       = 8'h98, // gang block unlock         
                RDFBR       = 8'h16, // read fast boot register
                WRFBR       = 8'h17, // write fast boot register
                ESFBR       = 8'h18, // erase fast boot register
                SUSP        = 8'hb0, // Suspend Program/Erase
                RESU        = 8'h30; // Resume Program/Erase

    /*----------------------------------------------------------------------*/
    /* Declaration of internal-signal                                       */
    /*----------------------------------------------------------------------*/
    reg  [7:0]           ARRAY[0:TOP_Add];  // memory array
    reg  [7:0]           Status_Reg;        // Status Register
    reg  [7:0]           Status_Tmp_Reg;    // Status Temp Register
    reg  [7:0]           CR2_Reg0;          // Configuration Register2 0x000
    reg  [7:0]           CR2_Reg1;          // Configuration Register2 0x200
    reg  [7:0]           CR2_Reg2;          // Configuration Register2 0x300
    reg  [7:0]           CR2_CRC0_Reg;      // Configuration Register2 0x500
    reg  [7:0]           CR2_CRC1_Reg;      // Configuration Register2 0x4000_0000
    reg  [7:0]           CR2_CRC2_Reg;      // Configuration Register2 0x8000_0000
    reg  [7:0]           CR2_ECS_Reg;       // Configuration Register2 0x400
    reg  [7:0]           CR2_ECC_Reg;       // Configuration Register2 0x800
    reg  [7:0]           CR2_ECCA0_Reg;     // Configuration Register2 0xc00
    reg  [7:0]           CR2_ECCA1_Reg;     // Configuration Register2 0xd00
    reg  [7:0]           CR2_ECCA2_Reg;     // Configuration Register2 0xe00
    reg  [7:0]           CR2_ECCA3_Reg;     // Configuration Register2 0xf00
    reg  [7:0]           CR2_ECC_Reg1;       // Configuration Register2 0x04000800
    reg  [7:0]           CR2_ECCA0_Reg1;     // Configuration Register2 0x04000c00
    reg  [7:0]           CR2_ECCA1_Reg1;     // Configuration Register2 0x04000d00
    reg  [7:0]           CR2_ECCA2_Reg1;     // Configuration Register2 0x04000e00
    reg  [7:0]           CR2_ECCA3_Reg1;     // Configuration Register2 0x04000f00
    reg  [7:0]           CMD_BUS;
    reg  [7:0]           CMD_BUS2;
    reg  [31:0]          SI_Reg;            // temp reg to store serial in
    reg  [7:0]           Dummy_A[0:255];    // page size
    reg  [A_MSB:0]       Address;           
    reg  [31:0]          Address_CR2;       
    reg  [Sector_MSB:0]  Sector;          
    reg  [Block_MSB:0]   Block;    
    reg  [Block_MSB+1:0] Block2;           
    reg  [2:0]           STATE;
    reg  [7:0]           SFDP_ARRAY[0:SFDP_TOP_Add];
    reg  [7:0]           CR;
    reg  [31:0]          FB_Reg;            // Fast Boot register
    reg  [31:0]          FB_Tmp_Reg;        // temp reg to store Fast Boot register
    reg  [15:0]          Prea_Reg;
    reg  [15:0]          Prea_Reg_DQ3;
    reg  [63:0]          Pwd_Reg;
    reg  [63:0]          Pwd_Tmp_Reg;

    
    reg     Chip_EN;
    reg     DP_Mode;        // deep power down mode
    reg     Read_Mode;
    reg     RD_Mode;
    reg     Read_1XIO_Mode;
    reg     Read_1XIO_Chk;

    reg     FAST_BOOT_Mode;
    reg     FAST_BOOT_Chk;

    reg     tDP_Chk;
    reg     tRES1_Chk;

    reg     RDID_Mode;
    reg     RDSR_Mode;
    reg     RDCR2_Mode;
    reg     RDSCUR_Mode;
    reg     RDFBR_Mode;
    reg     RDPASS_Mode;
    reg     FastRD_1XIO_Mode;   
    reg     PP_Mode;
    reg     SE_4K_Mode;
    reg     BE_Mode;
    reg     BE64K_Mode;
    reg     CE_Mode;
    reg     WRSR_Mode;
    reg     WRSR2_Mode;
    reg     WRCR2_Mode;
    reg     WRSR_OPI_Mode;
    reg     WRFBR_Mode;
    reg     WRPASS_Mode;
    reg     PASSULK_Mode;
    reg     ESFBR_Mode;
    reg     RDCR_Mode;
    reg     SCLK_EN;
    reg     SO_OUT_EN;   // for SO
    reg     SI_IN_EN;    // for SIO[0]
    reg     SFDP_Mode;
    reg     RST_CMD_EN;
    reg     WRSCUR_Mode;
    reg     EN_Burst;
    reg     Susp_Ready;
    reg     Susp_Trig;
    reg     Resume_Trig;
    reg     During_Susp_Wait;
    reg     ERS_CLK;                  // internal clock register for erase timer
    reg     PGM_CLK;                  // internal clock register for program timer
    reg     WR2Susp;
    reg     EN_Boot;
    reg     ADD_3B_Mode;
    reg     Prea_OUT_EN1;
    reg     Prea_OUT_EN8;
    reg     WR_WPSEL_Mode;
    reg     RDLR_Mode;
    reg     RDSPB_Mode;
    reg     RDDPB_Mode;
    reg     WRLR_Mode;
    reg     WRSPB_Mode;
    reg     WRDPB_Mode;
    reg     ESSPB_Mode;

    reg  [7:0]           Lock_Reg;          // lock register

    reg  [15:0]          SPB_Reg_TOP; 
    reg  [15:0]          SPB_Reg_BOT; 
    reg  [Block_NUM - 2:1] SPB_Reg; 
    reg  [15:0]           DPB_Reg_TOP; 
    reg  [15:0]           DPB_Reg_BOT;
    reg  [Block_NUM - 2:1] DPB_Reg;

    wire [15:0] SEC_Pro_Reg_TOP;
    wire [15:0] SEC_Pro_Reg_BOT;
    wire [Block_NUM - 2:1] SEC_Pro_Reg;

    wire    SPBLKDN;
    wire    PWDMLB;


    wire    CS_INT;
    wire    RESETB_INT;
    wire    SCLK; 
    wire    WIP;
    wire    ESB;
    wire    PSB;
    wire    EPSUSP;
    wire    WEL;
    wire    FBE;
    wire    Dis_CE;  
    wire    WPSEL_Mode;
    wire    Norm_Array_Mode;
    wire    Pgm_Mode;
    wire    Ers_Mode;

    event   Resume_Event; 
    event   Susp_Event; 
    event   WRSR_Event; 
    event   WRCR2_Event; 
    event   WRSR_OPI_Event; 
    event   WRFBR_Event; 
    event   ESFBR_Event; 
    event   BE_Event;
    event   SE_4K_Event;
    event   CE_Event;
    event   PP_Event;
    event   RST_Event;
    event   RST_EN_Event;
    event   HDRST_Event;
    event   WRSCUR_Event;
    event   WPSEL_Event;
    event   WRLR_Event;
    event   WRSPB_Event; 
    event   WRDPB_Event; 
    event   WRPASS_Event;
    event   PASSULK_Event;
    event   ESSPB_Event; 
    event   GBLK_Event;
    event   GBULK_Event;
    event   ECC_1b_correct_Event;
    event   ECC_2b_detect_Event;
    event   ECC_double_pgm_Event;

    integer i;
    integer j;
    integer Bit; 
    integer Bit_Tmp; 
    integer Start_Add;
    integer End_Add;
    integer tWRSR;
    integer Burst_Length;
//    time    tRES;
    time    ERS_Time;
    time    tPP_Real;   //program time according to programmed byte number
    reg Read_SHSL;
    wire Write_SHSL;

    reg  Not_Mode0;

    reg  [7:0]           Secur_ARRAY[0:Secur_TOP_Add]; // Secured OTP 
    reg  [7:0]           Secur_Reg;         // security register

    reg                  Secur_Mode;        // enter secured mode
    reg                  Byte_PGM_Mode;     
    reg                  SI_OUT_EN;   // for SIO[0]
    reg                  SO_IN_EN;    // for SO
    reg  [7:0]           SIO_Reg;
    reg  [7:0]           SIO_Out_Reg;
    reg                  DQS_Reg;
    reg                  ECSB_Reg;

    reg  [7:0]           CRC;

    reg  [9:0]           ECC[0:ECC_TOP_Add];
    reg                  ECC_DBPGM[0:ECC_TOP_Add];
    reg                  ECC_1BERR[0:ECC_TOP_Add];
    reg                  ECC_2BERR[0:ECC_TOP_Add];
    reg  [3:0]           ECC_FADDR_BYTE[0:ECC_TOP_Add];
    reg  [2:0]           ECC_FADDR_BIT[0:ECC_TOP_Add];

    reg  [9:0]           SOTP_ECC[0:SOTP_ECC_TOP_Add];
    reg                  SOTP_ECC_DBPGM[0:SOTP_ECC_TOP_Add];
    reg                  SOTP_ECC_1BERR[0:SOTP_ECC_TOP_Add];
    reg                  SOTP_ECC_2BERR[0:SOTP_ECC_TOP_Add];
    reg  [3:0]           SOTP_ECC_FADDR_BYTE[0:SOTP_ECC_TOP_Add];
    reg  [2:0]           SOTP_ECC_FADDR_BIT[0:SOTP_ECC_TOP_Add];

    reg  [9:0]           SFDP_ECC[0:SFDP_ECC_TOP_Add];
    reg                  SFDP_ECC_DBPGM[0:SFDP_ECC_TOP_Add];
    reg                  SFDP_ECC_1BERR[0:SFDP_ECC_TOP_Add];
    reg                  SFDP_ECC_2BERR[0:SFDP_ECC_TOP_Add];
    reg  [3:0]           SFDP_ECC_FADDR_BYTE[0:SFDP_ECC_TOP_Add];
    reg  [2:0]           SFDP_ECC_FADDR_BIT[0:SFDP_ECC_TOP_Add];

    reg                  ECC_1b_correct;
    reg                  ECC_2b_detect;
    reg                  ECC_double_pgm;
    reg                  Read_start;

    reg                  Read_8XIO_Mode;
    reg                  Read_8XIO_Chk;
    reg                  DDRRead_8XIO_Mode;
    reg                  DDRRead_8XIO_Chk;

    reg     DQS_OUT_EN;  // for DQS pin
    reg     DQS_TOGGLE_EN;  // for DQS pin
    reg     OPI_OUT_EN;  // for SIO2-SIO7 pin
    reg     OPI_IN_EN;   // for SIO2-SIO7 pin
    reg     During_RST_REC;

    wire       DOPI;
    wire       SOPI;
    wire       OPI_EN;
    wire [2:0] DMCYC;
    wire       STRDQS;
    wire       DDQSPRC;
    wire       ECSNODIS;
    wire       ECS1BCOR;
    wire [1:0] CRC_CYC;
    wire       CRCBEN;
    reg        CRC_EN;
    reg        CRC_ERR;

    /*----------------------------------------------------------------------*/
    /* initial variable value                                               */
    /*----------------------------------------------------------------------*/
    initial begin
        
        Chip_EN         = 1'b0;
        Secur_Reg       = {6'b00_0000,`VSecur_Reg1_0};
        Status_Reg      = {`VStatus_Reg7_2,2'b00};
        CR              = {3'b000,`CR_Default4_0};
        CR2_CRC1_Reg    = `CR2_0x40000000_Default;   //The reg is OTP, non-volatile
        `ifdef MODEL_CODE_1A
            CR2_CRC1_Reg[1:0] = 2'b01;   //Default DTR, x8 IO enable
        `endif
        FB_Reg          = `VFB_Reg;
        Pwd_Reg         = `VPwd_Reg;
        FB_Tmp_Reg      = 32'hffff_ffff;
        Lock_Reg        = `VLock_Reg;
        Pwd_Tmp_Reg     = 64'hffff_ffff_ffff_ffff;
        SPB_Reg_TOP[15:0] = 16'h0000;
        SPB_Reg_BOT[15:0] = 16'h0000;
        SPB_Reg = 1'b0;
        reset_sm;
    end

    task reset_sm; 
        begin
           
            CR2_Reg0        = {6'b0000_00,~CR2_CRC1_Reg[1:0]};
            CR2_Reg1        = 8'b0000_0000;
            CR2_Reg2        = 8'b0000_0000;
            CR2_CRC0_Reg    = 8'b0000_0000;
            CR2_CRC2_Reg    = 8'b0000_0000;
            CR2_ECS_Reg     = 8'b0000_0000;
            CR2_ECC_Reg     = 8'b0000_0000;
            CR2_ECCA0_Reg   = 8'b0000_0000;
            CR2_ECCA1_Reg   = 8'b0000_0000;
            CR2_ECCA2_Reg   = 8'b0000_0000;
            CR2_ECCA3_Reg   = 8'b0000_0000;
            CRC_EN          = ~CR2_CRC1_Reg[3];
            CRC_ERR         = 0;
            crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
            ECC_1b_correct  = 1'b0;
            ECC_2b_detect   = 1'b0;
            ECC_double_pgm  = 1'b0;
            Read_start      = 1'b0;

            CR2_ECC_Reg1     = 8'b0000_0000;
            CR2_ECCA0_Reg1   = 8'b0000_0000;
            CR2_ECCA1_Reg1   = 8'b0000_0000;
            CR2_ECCA2_Reg1   = 8'b0000_0000;
            CR2_ECCA3_Reg1   = 8'b0000_0000;
           
            Not_Mode0       = 1'b0;
            During_RST_REC  = 1'b0;
            WRSCUR_Mode     = 1'b0;
            SIO_Reg         = 8'b1111_1111;
            SIO_Out_Reg     = SIO_Reg;
            DQS_Reg         = 1'bz;
            Prea_Reg        = 16'b0011_0100_1001_1010;
            Prea_Reg_DQ3    = 16'b0011_0101_0001_0100;
            ECSB_Reg        = 1'bz;
            RST_CMD_EN      = 1'b0;
            SO_OUT_EN       = 1'b0; // SO output enable
            SI_IN_EN        = 1'b0; // SIO[0] input enable
            CMD_BUS         = 8'b0000_0000;
            CMD_BUS2        = 8'b0000_0000;
            Address         = 0;
            Address_CR2     = 31'b0;        
            i               = 0;
            j               = 0;
            Bit             = 0;
            Bit_Tmp         = 0;
            Start_Add       = 0;
            End_Add         = 0;
            DP_Mode         = 1'b0;
            SCLK_EN         = 1'b1;
            Read_Mode       = 1'b0;
            RD_Mode         = 1'b0;
            Read_1XIO_Mode  = 1'b0;
            Read_1XIO_Chk   = 1'b0;
            tDP_Chk         = 1'b0;
            tRES1_Chk       = 1'b0;

            FAST_BOOT_Mode  = 1'b0;
            FAST_BOOT_Chk  = 1'b0;

            RDID_Mode       = 1'b0;
            RDSR_Mode       = 1'b0;
            RDCR2_Mode      = 1'b0;
            RDSCUR_Mode     = 1'b0;
            RDCR_Mode       = 1'b0;
            RDFBR_Mode      = 1'b0;
            RDPASS_Mode     = 1'b0;
            PP_Mode    = 1'b0;
            SE_4K_Mode      = 1'b0;
            BE_Mode         = 1'b0;
            BE64K_Mode      = 1'b0;
            CE_Mode         = 1'b0;
            WRSR_Mode       = 1'b0;
            WRCR2_Mode      = 1'b0;
            WRSR2_Mode      = 1'b0;
            WRSR_OPI_Mode   = 1'b0;
            WRFBR_Mode      = 1'b0;
            WRPASS_Mode     = 1'b0;
            PASSULK_Mode    = 1'b0;
            ESFBR_Mode      = 1'b0;
            Read_SHSL       = 1'b0;
            FastRD_1XIO_Mode  = 1'b0;
            SI_OUT_EN       = 1'b0; // SIO[0] output enable
            SO_IN_EN        = 1'b0; // SO input enable
            Secur_Mode      = 1'b0;
            Prea_OUT_EN1    = 1'b0;
            Prea_OUT_EN8    = 1'b0;
            WR_WPSEL_Mode   = 1'b0;
            RDLR_Mode       = 1'b0;
            RDSPB_Mode     = 1'b0;
            RDDPB_Mode     = 1'b0;
            WRLR_Mode       = 1'b0;
            WRSPB_Mode      = 1'b0;
            WRDPB_Mode      = 1'b0;
            ESSPB_Mode      = 1'b0;
            DPB_Reg_TOP[15:0] = 16'hffff;
            DPB_Reg_BOT[15:0] = 16'hffff;
            DPB_Reg     = ~1'b0;

            Byte_PGM_Mode   = 1'b0;
            DQS_OUT_EN      = 1'b0; // for DQS pin output enable
            DQS_TOGGLE_EN   = 1'b0; // for DQS pin output toggle
            OPI_OUT_EN      = 1'b0; // for SIO2-SIO7 pin output enable
            OPI_IN_EN       = 1'b0; // for SIO2-SIO7 pin input enable
            Read_8XIO_Mode  = 1'b0;
            Read_8XIO_Chk   = 1'b0;
            DDRRead_8XIO_Mode = 1'b0;
            DDRRead_8XIO_Chk  = 1'b0;
            SFDP_Mode = 1'b0;
            EN_Burst          = 1'b0;
            Burst_Length      = 16;
            Susp_Ready        = 1'b1;
            Susp_Trig         = 1'b0;
            Resume_Trig       = 1'b0;
            During_Susp_Wait  = 1'b0;            
            ERS_CLK           = 1'b0;
            PGM_CLK           = 1'b0;
            WR2Susp           = 1'b0;
            EN_Boot           = 1'b1;
            ADD_3B_Mode       = 1'b0;
            RDFBR_Mode        = 1'b0;
            Status_Tmp_Reg[5:2]  = 4'hf;
            if (!Lock_Reg[2]) begin
                Lock_Reg[6] = 0;
            end
        end
    endtask // reset_sm
    
    /*----------------------------------------------------------------------*/
    /* initial flash data                                                   */
    /*----------------------------------------------------------------------*/
    initial 
    begin : memory_initialize
        for ( i = 0; i <=  TOP_Add; i = i + 1 )
            ARRAY[i] = 8'hff; 
        if ( Init_File != "none" )
            $readmemh(Init_File,ARRAY) ;
        for( i = 0; i <=  Secur_TOP_Add; i = i + 1 ) begin
            Secur_ARRAY[i]=8'hff;
        end
        if ( Init_File_Secu != "none" )
            $readmemh(Init_File_Secu,Secur_ARRAY) ;
        for( i = 0; i <=  SFDP_TOP_Add; i = i + 1 ) begin
            SFDP_ARRAY[i] = 8'hff;
        end
        if ( Init_File_SFDP != "none" )
            $readmemh(Init_File_SFDP,SFDP_ARRAY) ;
        // define SFDP code

        for ( i = 0; i <=  ECC_TOP_Add; i = i + 1 ) begin
            ECC_DBPGM[i]      = 0; 
            ECC_1BERR[i]      = 0;
            ECC_2BERR[i]      = 0;
            ECC_FADDR_BYTE[i] = 0;
            ECC_FADDR_BIT[i]  = 0;
        end

        for ( i = 0; i <=  SOTP_ECC_TOP_Add; i = i + 1 ) begin
            SOTP_ECC_DBPGM[i]      = 0; 
            SOTP_ECC_1BERR[i]      = 0;
            SOTP_ECC_2BERR[i]      = 0;
            SOTP_ECC_FADDR_BYTE[i] = 0;
            SOTP_ECC_FADDR_BIT[i]  = 0;
        end

        for ( i = 0; i <=  SFDP_ECC_TOP_Add; i = i + 1 ) begin
            SFDP_ECC_DBPGM[i]      = 0; 
            SFDP_ECC_1BERR[i]      = 0;
            SFDP_ECC_2BERR[i]      = 0;
            SFDP_ECC_FADDR_BYTE[i] = 0;
            SFDP_ECC_FADDR_BIT[i]  = 0;
        end

        for ( i = 0; i <=  ECC_TOP_Add; i = i + 1 )
            ECC[i] = 10'h3ff; 
        if ( Init_File != "none" ) begin
            for ( i = 0; i <= TOP_Add; i = i + Buffer_Num ) begin
                    update_ecc(i);
            end
        end

        for ( i = 0; i <=  SOTP_ECC_TOP_Add; i = i + 1 )
            SOTP_ECC[i] = 10'h3ff; 
        if ( Init_File_Secu != "none" ) begin
            for ( i = 0; i <= Secur_TOP_Add; i = i + Buffer_Num ) begin
                Secur_Mode = 1;
                update_ecc(i);
                Secur_Mode = 0;
            end
        end

        for ( i = 0; i <=  SFDP_ECC_TOP_Add; i = i + 1 )
            SFDP_ECC[i] = 10'h3ff; 
        if ( Init_File_SFDP != "none" ) begin
            for ( i = 0; i <= SFDP_TOP_Add; i = i + Buffer_Num ) begin
                SFDP_Mode = 1;
                update_ecc(i);
                SFDP_Mode = 0;
            end
        end
    end

// *============================================================================================== 
// * Input/Output bus operation 
// *==============================================================================================
    assign   CS_INT     = ( During_RST_REC == 1'b0 && RESETB_INT == 1'b1 && Chip_EN ) ? CS : 1'b1;
    assign   SIO[0]     = SI_OUT_EN ? SIO_Out_Reg[0] : 1'bz ;
    assign   SIO[1]     = SO_OUT_EN ? SIO_Out_Reg[1] : 1'bz ;
    assign   SIO[7:2]   = OPI_OUT_EN ? SIO_Out_Reg[7:2] : 6'bzzzzzz ;
    assign   DQS        = DQS_OUT_EN ? DQS_Reg : 1'bz;
    assign   ECSB       = SO_OUT_EN ? ECSB_Reg : 1'bz;
    assign   RESETB_INT = (RESET === 1'b1 || RESET === 1'b0) ? RESET : 1'b1;

    /*----------------------------------------------------------------------*/
    /* output buffer                                                        */
    /*----------------------------------------------------------------------*/
    always @( posedge DQS_OUT_EN ) begin
        if( !CS_INT && ( DOPI || (SOPI && STRDQS) ) ) begin
            DQS_Reg <= #tQSLZ 0;
        end
    end

    always @( SCLK ) begin
        if( DOPI || (SOPI && STRDQS) ) begin
            #0.1;
            if ( DQS_TOGGLE_EN ) begin
                DQS_Reg <= #(tCLQV-tDQSQ-0.1) SCLK;
            end
        end
    end

    always @( SIO_Reg[7:0] ) begin
        if ( OPI_OUT_EN && SO_OUT_EN && SI_OUT_EN ) begin
            SIO_Out_Reg[7:0] <= #tCLQV SIO_Reg[7:0];
        end
        else if ( SO_OUT_EN ) begin
            SIO_Out_Reg[1]   <= #tCLQV SIO_Reg[1];
        end
    end

    always @ ( SCLK ) begin
        #0.1;
        if ( Read_Mode && !DOPI && SCLK == 0 ) begin 
            if( ECC_2b_detect )
                ECSB_Reg     <= #(tECSV-0.1) 1'b0;
            else if( !ECSNODIS && ECC_double_pgm )
                ECSB_Reg     <= #(tECSV-0.1) 1'b0;
            else if( ECS1BCOR && ECC_1b_correct ) 
                ECSB_Reg     <= #(tECSV-0.1) 1'b0;
            else
                ECSB_Reg     <= #(tECSV-0.1) 1'bz;
        end
        else if ( Read_Mode && DOPI ) begin
            if( ECC_2b_detect )
                ECSB_Reg     <= #(tECSV-0.1) 1'b0;
            else if( !ECSNODIS && ECC_double_pgm )
                ECSB_Reg     <= #(tECSV-0.1) 1'b0;
            else if( ECS1BCOR && ECC_1b_correct ) 
                ECSB_Reg     <= #(tECSV-0.1) 1'b0;
            else
                ECSB_Reg     <= #(tECSV-0.1) 1'bz;
        end
    end

// *============================================================================================== 
// * Finite State machine to control Flash operation
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* power on                                                             */
    /*----------------------------------------------------------------------*/
    initial begin 
        Chip_EN   <= #tVSL 1'b1;// Time delay to chip select allowed 
    end

    
    /*----------------------------------------------------------------------*/
    /* Command Decode                                                       */
    /*----------------------------------------------------------------------*/
    assign DOPI     = CR2_Reg0[1];
    assign SOPI     = CR2_Reg0[0];
    assign OPI_EN   = CR2_Reg0[0] || CR2_Reg0[1];
    assign DDQSPRC  = CR2_Reg1[0];
    assign STRDQS   = CR2_Reg1[1];
    assign DMCYC    = CR2_Reg2[2:0];
    assign ECSNODIS   = CR2_ECS_Reg[1];
    assign ECS1BCOR   = CR2_ECS_Reg[0];
    assign CRC_CYC[1:0] = CR2_CRC0_Reg[6:5];
    assign CRCBEN   = CR2_CRC0_Reg[4];
    assign ESB      = Secur_Reg[3] ;
    assign PSB      = Secur_Reg[2] ;
    assign EPSUSP   = ESB | PSB ;
    assign WIP      = Status_Reg[0] ;
    assign WEL      = Status_Reg[1] ;
    assign Dis_CE   = Status_Reg[5] == 1'b1 || Status_Reg[4] == 1'b1 ||
                      Status_Reg[3] == 1'b1 || Status_Reg[2] == 1'b1;
    assign Norm_Array_Mode = ~Secur_Mode;
    assign WPSEL_Mode = Secur_Reg[7];
    assign SPBLKDN    = Lock_Reg[6] ;
    assign PWDMLB     = Lock_Reg[2];

    assign SEC_Pro_Reg_TOP = SPB_Reg_TOP | DPB_Reg_TOP;
    assign SEC_Pro_Reg_BOT = SPB_Reg_BOT | DPB_Reg_BOT;
    assign SEC_Pro_Reg = SPB_Reg | DPB_Reg;
     
    assign FBE       = FB_Reg[0];
    assign Pgm_Mode  = PP_Mode;
    assign Ers_Mode  = SE_4K_Mode || BE_Mode;

    always @ ( posedge CRC_ERR ) begin 
        CR2_CRC2_Reg[4] = 1'b1;
    end

    always @ ( ECC_1b_correct_Event or ECC_2b_detect_Event or ECC_double_pgm_Event ) begin
      if ( Address[26] == 0 ) begin
        if ( ECC_1b_correct ) begin 
            CR2_ECC_Reg[4] = 1'b1;
        end
        if ( ECC_2b_detect ) begin
            CR2_ECC_Reg[5] = 1'b1;
        end
        if ( ECC_double_pgm ) begin
            CR2_ECC_Reg[6] = 1'b1;
        end
     end
     else begin
        if ( ECC_1b_correct ) begin 
            CR2_ECC_Reg1[4] = 1'b1;
        end
        if ( ECC_2b_detect ) begin
            CR2_ECC_Reg1[5] = 1'b1;
        end
        if ( ECC_double_pgm ) begin
            CR2_ECC_Reg1[6] = 1'b1;
        end
     end
    end

    always @ ( ECC_1b_correct_Event or ECC_2b_detect_Event ) begin
      if ( Address[26] == 0 ) begin
        if ( CR2_ECC_Reg[7] == 1'b0 ) begin
            CR2_ECC_Reg[7]     = 1'b1;
            CR2_ECCA0_Reg[7:4] = Address[7:4];
            CR2_ECCA1_Reg[7:0] = Address[15:8];
            CR2_ECCA2_Reg[7:0] = Address[23:16];
            CR2_ECCA3_Reg[1:0] = Address[25:24];
        end
      end
      else begin
        if ( CR2_ECC_Reg1[7] == 1'b0 ) begin
            CR2_ECC_Reg1[7]     = 1'b1;
            CR2_ECCA0_Reg1[7:4] = Address[7:4];
            CR2_ECCA1_Reg1[7:0] = Address[15:8];
            CR2_ECCA2_Reg1[7:0] = Address[23:16];
            CR2_ECCA3_Reg1[1:0] = Address[25:24];
        end
      end
    end

    always @ ( ECC_1b_correct_Event or ECC_2b_detect_Event ) begin
      if ( Address[26] == 0 ) begin
        if ( CR2_ECC_Reg[3:0] < 15 ) begin
            CR2_ECC_Reg[3:0] = CR2_ECC_Reg[3:0] + 1;
        end
       end
      else begin
        if ( CR2_ECC_Reg1[3:0] < 15 ) begin
            CR2_ECC_Reg1[3:0] = CR2_ECC_Reg1[3:0] + 1;
        end
       end
    end

    always @ ( negedge CS_INT ) begin
        if ( !EN_Boot || FBE ) begin
            SI_IN_EN = 1'b1;
        end 
        if ( OPI_EN ) begin
            SO_IN_EN    = 1'b1;
            SI_IN_EN    = 1'b1;
            OPI_IN_EN   = 1'b1;
        end
        #1;
        Read_SHSL = 1'b0;
        tDP_Chk = 1'b0;
    end

    always @ ( posedge tRES1_Chk ) begin : tRES1_Chk_Pro
        #tRES1;
        tRES1_Chk = 0;
    end

    always @ ( posedge SCLK ) begin
        if ( CS_INT == 1'b0 ) begin
            if ( OPI_EN ) begin
                Bit_Tmp = Bit_Tmp + 8;
                Bit     = Bit_Tmp - 1;
            end
            else begin
                Bit_Tmp = Bit_Tmp + 1;
                Bit     = Bit_Tmp - 1;
            end
            if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 && OPI_IN_EN == 1'b1 ) begin
                SI_Reg[31:0] = {SI_Reg[23:0], SIO[7:0]};
            end 
            else  if ( SI_IN_EN == 1'b1 ) begin
                SI_Reg[31:0] = ADD_3B_Mode ? {8'b0, SI_Reg[22:0], SIO[0]} : {SI_Reg[30:0], SIO[0]};
            end

        end     
    end 
  
    always @ ( negedge SCLK ) begin
        if ( CS_INT == 1'b0 && DOPI ) begin
            if ( Bit == 0 ) begin
                Not_Mode0 = 1;
                $display( $time, " chip only supports Mode 0 " );
            end


            if ( OPI_EN ) begin
                Bit_Tmp = Bit_Tmp + 8;
                Bit     = Bit_Tmp - 1;
            end
            else begin
                Bit_Tmp = Bit_Tmp + 1;
                Bit     = Bit_Tmp - 1;
            end
            if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 && OPI_IN_EN == 1'b1 ) begin
                SI_Reg[31:0] = {SI_Reg[23:0], SIO[7:0]};
            end 
            else  if ( SI_IN_EN == 1'b1 ) begin
                SI_Reg[31:0] = {SI_Reg[30:0], SIO[0]};
            end

        end     
    end 
        
    always @ (  posedge CS_INT ) begin
            if ( SCLK == 1'b1 && DOPI && !Read_Mode ) begin
                STATE <= `BAD_CMD_STATE;
            end

    end

    always @ ( STATE ) begin
        if ( STATE == `BAD_CMD_STATE ) begin 
            if( DOPI && CRC_EN ) CRC_ERR = 1;
        end
    end

    always @ (  SCLK or posedge CS_INT ) begin
        #0;  
        if ( !Not_Mode0 ) begin
            if ( Bit == 7 && CS_INT == 1'b0 && (!EN_Boot || FBE)  ) begin
                CMD_BUS = SI_Reg[7:0];
                if( !OPI_EN ) begin
                        STATE = `CMD_STATE;
                end
            end

            if ( Bit == 15 && CS_INT == 1'b0 && OPI_EN && (!EN_Boot || FBE) ) begin
                CMD_BUS2 = SI_Reg[7:0];
                if( CMD_BUS2 === ~CMD_BUS ) begin
                        STATE = `CMD_STATE;
                end
                else begin
                        STATE <= `BAD_CMD_STATE;
                end
            end

            if ( CS_INT == 1'b0 && SCLK == 1'b1 && ( EN_Boot && !FBE ) ) begin
                STATE = `FAST_BOOT_STATE;
            end

            if ( CS_INT == 1'b1 && RST_CMD_EN && (Bit+1)%8 == 0 ) begin
                RST_CMD_EN <= #1 1'b0;
            end

            case ( STATE )
                `STANDBY_STATE: 
                    begin
                    end
            
                `FAST_BOOT_STATE:
                    begin
                        Read_SHSL = 1'b1;
                        FAST_BOOT_Mode = 1'b1;
                    end

                `CMD_STATE: 
                    begin
                        case ( CMD_BUS ) 

                        WREN: 
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin  
                                        // $display( $time, " Enter Write Enable Function ..." );
                                        write_enable;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin     
                                        // $display( $time, " Enter Write Enable Function ..." );
                                        write_enable;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) ) begin
                                        STATE <= `BAD_CMD_STATE; 
                                    end
                                end 
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) ) begin
                                    STATE <= `BAD_CMD_STATE; 
                                end
                            end
                     
                        WRDI:   
                            begin
                                if ( !DP_Mode && (!WIP || During_Susp_Wait) && Chip_EN  ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin  
                                        // $display( $time, " Enter Write Disable Function ..." );
                                        write_disable;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin     
                                        // $display( $time, " Enter Write Disable Function ..." );
                                        write_disable;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) ) begin
                                        STATE <= `BAD_CMD_STATE; 
                                    end 
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) ) begin
                                    STATE <= `BAD_CMD_STATE; 
                                end
                            end 

                        RDID:
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN ) begin
                                    //$display( $time, " Enter Read ID Function ..." );
                                    Read_SHSL = 1'b1;
                                    RDID_Mode = 1'b1;
                                    if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0];
                                        load_address(Address);

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) ) begin
                                    STATE <= `BAD_CMD_STATE;    
                                end
                            end
                          
                        RDCR2:
                            begin 
                                if ( !DP_Mode && Chip_EN ) begin 
                                    //$display( $time, " Enter Read Status Function ..." );
                                    Read_SHSL = 1'b1;
                                    RDCR2_Mode = 1'b1;
                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address_CR2 = SI_Reg [31:0];
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address_CR2 = SI_Reg [31:0];

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) ) begin
                                    STATE <= `BAD_CMD_STATE;    
                                end
                            end

                        RDSR:
                            begin 
                                if ( !DP_Mode && Chip_EN ) begin 
                                    //$display( $time, " Enter Read CR2 Function ..." );
                                    Read_SHSL = 1'b1;
                                    RDSR_Mode = 1'b1;
                                    if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) ) begin
                                    STATE <= `BAD_CMD_STATE;    
                                end
                            end

                        RDCR:
                            begin
                                if ( !DP_Mode && Chip_EN ) begin
                                    //$display( $time, " Enter Read Status Function ..." );
                                    Read_SHSL = 1'b1;
                                    RDCR_Mode = 1'b1 ;
                                    if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) ) begin
                                    STATE <= `BAD_CMD_STATE;    
                                end
                            end

                        WRSR:
                            begin
                                if ( !DP_Mode && !WIP && WEL && Chip_EN && !EPSUSP && !Secur_Mode ) begin
                                    if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end

                                    if ( CS_INT == 1'b1 && Bit == 15 && !OPI_EN ) begin
                                        //$display( $time, " Enter Write Status Function ..." );
                                        ->WRSR_Event;
                                        WRSR_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 23 && !OPI_EN ) begin                     
                                        //$display( $time, " Enter Write Status Function ..." ); 
                                        ->WRSR_Event;
                                        WRSR2_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 55 && SOPI ) begin
                                        //$display( $time, " Enter Write Status Function ..." );
                                        ->WRSR_OPI_Event;
                                        WRSR_OPI_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 63 && DOPI && !CRC_EN ) begin
                                        //$display( $time, " Enter Write Status Function ..." ); 
                                        ->WRSR_OPI_Event;
                                        WRSR_OPI_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 95 && DOPI && CRC_EN ) begin
                                        if ( SI_Reg[31:24] == ~SI_Reg[15:8]) begin
                                            //$display( $time, " Enter Write Status Function ..." ); 
                                            ->WRSR_OPI_Event;
                                            WRSR_OPI_Mode = 1'b1;
                                        end
                                        else begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                    end
                                    else if ( CS_INT == 1'b1 && (Bit != 15 || Bit !=23) && !OPI_EN )
                                            STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 &&  Bit != 55 && SOPI )
                                            STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 &&  Bit != 63 && DOPI && !CRC_EN )
                                            STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 &&  Bit != 95 && DOPI && CRC_EN ) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) ) begin
                                    STATE <= `BAD_CMD_STATE;
                                end
                            end

                        WRCR2:
                            begin
                                if ( !DP_Mode && Chip_EN ) begin
                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address_CR2 = SI_Reg [31:0];
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address_CR2 = SI_Reg [31:0];

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end

                                    if ( CS_INT == 1'b1 && Address_CR2 == 32'h4000_0000 && (EPSUSP || Secur_Mode) ) begin
                                        STATE <= `BAD_CMD_STATE;
                                    end
                                    else if ( CS_INT == 1'b1 && Address_CR2 !== 32'h8000_0000 && (WIP || !WEL) ) begin
                                        STATE <= `BAD_CMD_STATE;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 47 && !OPI_EN ) begin
                                        //$display( $time, " Enter Write Status Function ..." );
                                        ->WRCR2_Event;
                                        WRCR2_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 55 && SOPI ) begin
                                        //$display( $time, " Enter Write Status Function ..." );
                                        ->WRCR2_Event;
                                        WRCR2_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 63 && DOPI && !CRC_EN ) begin
                                        //$display( $time, " Enter Write Status Function ..." ); 
                                        ->WRCR2_Event;
                                        WRCR2_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 95 && DOPI && CRC_EN ) begin
                                        if ( SI_Reg[31:24] == ~SI_Reg[15:8]) begin
                                            //$display( $time, " Enter Write Status Function ..." ); 
                                            ->WRCR2_Event;
                                            WRCR2_Mode = 1'b1;
                                        end
                                        else begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                    end
                                    else if ( CS_INT == 1'b1 &&  Bit != 47 && !OPI_EN )
                                            STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 &&  Bit != 55 && SOPI )
                                            STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 &&  Bit != 63 && DOPI && !CRC_EN )
                                            STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 &&  Bit != 95 && DOPI && CRC_EN ) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) ) begin
                                    STATE <= `BAD_CMD_STATE;
                                end
                            end

                        SBL:
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN ) begin  // no WEL
                                    if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end

                                    if ( CS_INT == 1'b1 && ((Bit == 55 && SOPI && Address==0) || (Bit == 15 && !OPI_EN))) begin
                                        //$display( $time, " Enter Set Burst Length Function ..." );
                                        EN_Burst = !SI_Reg[4];
                                        if ( SI_Reg[7:5]==3'b000 && SI_Reg[3:2]==2'b00 ) begin
                                            if ( SI_Reg[1:0]==2'b00 )
                                                EN_Burst     = 0;
                                            else if ( SI_Reg[1:0]==2'b01 )
                                                Burst_Length = 16;
                                            else if ( SI_Reg[1:0]==2'b10 )
                                                Burst_Length = 32;
                                            else if ( SI_Reg[1:0]==2'b11 )
                                                Burst_Length = 64;
                                        end
                                        else begin
                                                EN_Burst     = 0;
                                        end
                                    end
                                    else if (CS_INT == 1'b1 && Bit == 63 && DOPI && Address == 0 && !CRC_EN) begin
                                        EN_Burst = !SI_Reg[12];
                                        if ( SI_Reg[15:13]==3'b000 && SI_Reg[11:10]==2'b00 ) begin
                                            if ( SI_Reg[9:8]==2'b00 )
                                                EN_Burst     = 0;
                                            else if ( SI_Reg[9:8]==2'b01 )
                                                Burst_Length = 16;
                                            else if ( SI_Reg[9:8]==2'b10 )
                                                Burst_Length = 32;
                                            else if ( SI_Reg[9:8]==2'b11 )
                                                Burst_Length = 64;
                                        end
                                        else begin
                                                EN_Burst     = 0;
                                        end
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 95 && DOPI && Address ==0 && CRC_EN ) begin
                                      if ( SI_Reg[31:24] == ~SI_Reg[15:8]) begin                                            
                                        EN_Burst = !SI_Reg[28];
                                        if ( SI_Reg[31:29]==3'b000 && SI_Reg[27:26]==2'b00 ) begin
                                            if ( SI_Reg[25:24]==2'b00 )
                                                EN_Burst     = 0;
                                            else if ( SI_Reg[25:24]==2'b01 )
                                                Burst_Length = 16;
                                            else if ( SI_Reg[25:24]==2'b10 )
                                                Burst_Length = 32;
                                            else if ( SI_Reg[25:24]==2'b11 )
                                                Burst_Length = 64;
                                        end
                                        else begin
                                                EN_Burst     = 0;
                                        end
                                      end
                                      else begin
                                            STATE <= `BAD_CMD_STATE;
                                      end                                              
                                    end
                                    else if ( CS_INT == 1'b1 && ((Bit != 95 && DOPI && CRC_EN) && (Bit != 63 && DOPI && !CRC_EN) || (Bit != 55 && SOPI) || (Bit != 15 && !OPI_EN)))
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        READ1X3B: 
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN && !OPI_EN ) begin
                                    //$display( $time, " Enter Read Data Function ..." );
                                    Read_SHSL = 1'b1;
                                    if ( Bit == 31 ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);
                                    end
                                    Read_1XIO_Mode = 1'b1;
                                    ADD_3B_Mode = 1'b1;
                                end     
                                else if ( Bit == 7 )
                                    STATE <= `BAD_CMD_STATE;                            
                            end
                         
                        READ1X4B: 
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN && !OPI_EN ) begin
                                    //$display( $time, " Enter Read Data Function ..." );
                                    Read_SHSL = 1'b1;
                                    if ( Bit == 39 ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);
                                    end
                                    Read_1XIO_Mode = 1'b1;
                                end     
                                else if ( Bit == 7 )
                                    STATE <= `BAD_CMD_STATE;                            
                            end
                         
                        FASTREAD1X3B:
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN && !OPI_EN ) begin
                                    //$display( $time, " Enter Fast Read Data Function ..." );
                                    Read_SHSL = 1'b1;
                                    if ( Bit == 31 ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);
                                    end
                                    FastRD_1XIO_Mode = 1'b1;
                                    ADD_3B_Mode = 1'b1;
                                end     
                                else if ( Bit == 7 )
                                    STATE <= `BAD_CMD_STATE;                            
                            end

                        FASTREAD1X4B:
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN && !OPI_EN ) begin
                                    //$display( $time, " Enter Fast Read Data Function ..." );
                                    Read_SHSL = 1'b1;
                                    if ( Bit == 39 ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);
                                    end
                                    FastRD_1XIO_Mode = 1'b1;
                                end     
                                else if ( Bit == 7 )
                                    STATE <= `BAD_CMD_STATE;                            
                            end

                        SE3B: 
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode &&  Chip_EN && !EPSUSP && !OPI_EN ) begin
                                    ADD_3B_Mode = 1'b1;
                                    if ( Bit == 31 ) begin
                                        Address = SI_Reg [A_MSB:0];
                                    end

                                    if ( CS_INT == 1'b1 && Bit == 31 ) begin
                                        //$display( $time, " Enter Sector Erase Function ..." );
                                        ->SE_4K_Event;
                                        SE_4K_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit != 31 )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( Bit == 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        SE4B: 
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode &&  Chip_EN && !EPSUSP ) begin
                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end

                                    if ( CS_INT == 1'b1 && Bit == 39 && !OPI_EN ) begin
                                        //$display( $time, " Enter Sector Erase Function ..." );
                                        ->SE_4K_Event;
                                        SE_4K_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 47 && SOPI ) begin
                                        //$display( $time, " Enter Sector Erase Function ..." );
                                        ->SE_4K_Event;
                                        SE_4K_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 47 && DOPI && !CRC_EN ) begin
                                        //$display( $time, " Enter Sector Erase Function ..." );
                                        ->SE_4K_Event;
                                        SE_4K_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 63 && DOPI && CRC_EN ) begin
                                        //$display( $time, " Enter Sector Erase Function ..." );
                                        ->SE_4K_Event;
                                        SE_4K_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit != 39 && !OPI_EN )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 47 && SOPI )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 47 && DOPI && !CRC_EN )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 63 && DOPI && CRC_EN ) begin
                                        STATE <= `BAD_CMD_STATE;
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        BE3B: 
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode &&  Chip_EN && !EPSUSP && !OPI_EN ) begin
                                    ADD_3B_Mode = 1'b1;
                                    if ( Bit == 31 ) begin
                                        Address = SI_Reg [A_MSB:0];
                                    end

                                    if ( CS_INT == 1'b1 && Bit == 31 ) begin
                                        //$display( $time, " Enter Block Erase Function ..." );
                                        ->BE_Event;
                                        BE_Mode = 1'b1;
                                        BE64K_Mode = 1'b1;
                                    end 
                                    else if ( CS_INT == 1'b1 && Bit != 31 )
                                        STATE <= `BAD_CMD_STATE;
                                end 
                                else if ( Bit == 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        BE4B: 
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode &&  Chip_EN && !EPSUSP ) begin
                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                        
                                    if ( CS_INT == 1'b1 && Bit == 39 && !OPI_EN ) begin
                                        //$display( $time, " Enter Block Erase Function ..." );
                                        ->BE_Event;
                                        BE_Mode = 1'b1;
                                        BE64K_Mode = 1'b1;
                                    end 
                                    else if ( CS_INT == 1'b1 && Bit == 47 && SOPI ) begin
                                        //$display( $time, " Enter Block Erase Function ..." );
                                        ->BE_Event;
                                        BE_Mode = 1'b1;
                                        BE64K_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 47 && DOPI && !CRC_EN ) begin
                                        //$display( $time, " Enter Block Erase Function ..." );
                                        ->BE_Event;
                                        BE_Mode = 1'b1;
                                        BE64K_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 63 && DOPI && CRC_EN ) begin
                                        //$display( $time, " Enter Block Erase Function ..." );
                                        ->BE_Event;
                                        BE_Mode = 1'b1;
                                        BE64K_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit != 39 && !OPI_EN )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 47 && SOPI )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 47 && DOPI && !CRC_EN )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 63 && DOPI && CRC_EN ) begin
                                        STATE <= `BAD_CMD_STATE;
                                    end
                                end 
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        SUSP:
                            begin
                                if ( !DP_Mode && WEL && !Secur_Mode && Chip_EN && !EPSUSP ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin
                                        //$display( $time, " Enter Suspend Function ..." );
                                        ->Susp_Event;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin
                                        //$display( $time, " Enter Suspend Function ..." );
                                        ->Susp_Event;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        RESU:
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN && EPSUSP ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin
                                        //$display( $time, " Enter Resume Function ..." );
                                        Secur_Mode = 1'b0;
                                        ->Resume_Event;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin
                                        //$display( $time, " Enter Resume Function ..." );
                                        Secur_Mode = 1'b0;
                                        ->Resume_Event;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end
                          
                        CE1, CE2:
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode && Chip_EN && !EPSUSP) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin
                                        //$display( $time, " Enter Chip Erase Function ..." );
                                        ->CE_Event;
                                        CE_Mode = 1'b1 ;
                                    end 
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin
                                        //$display( $time, " Enter Chip Erase Function ..." );
                                        ->CE_Event;
                                        CE_Mode = 1'b1 ;
                                    end 
                                    else if ( CS_INT == 1'b1 && ( (Bit != 7 && !OPI_EN) || (Bit != 15 && OPI_EN) ) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end
                          
                        PP3B: 
                            begin
                                if ( !DP_Mode && !WIP && WEL && Chip_EN && !EPSUSP && !OPI_EN ) begin
                                    ADD_3B_Mode = 1'b1;
                                    if ( Bit == 31 ) begin
                                        Address = SI_Reg [A_MSB:0];
                                    end

                                    if ( CS_INT == 1'b0 && Bit == 31 ) begin
                                        //$display( $time, " Enter Page Program Function ..." );
                                        ->PP_Event;
                                        PP_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1 && ( (Bit < 39) || ((Bit + 1) % 8 !== 0) ) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( Bit == 7 ) 
                                    STATE <= `BAD_CMD_STATE;
                            end


                        PP4B: 
                            begin
                                if ( !DP_Mode && !WIP && WEL && Chip_EN && !EPSUSP ) begin
                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            CRC_ERR = 1'b1;
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end

                                    if ( CS_INT == 1'b0 && Bit == 39 && !OPI_EN ) begin
                                        //$display( $time, " Enter Page Program Function ..." );
                                        ->PP_Event;
                                        PP_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 47 && SOPI && SCLK ) begin
                                        //$display( $time, " Enter Page Program Function ..." );
                                        ->PP_Event;
                                        PP_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 47 && DOPI && !CRC_EN && Address[0] == 0 ) begin
                                        //$display( $time, " Enter Page Program Function ..." );
                                        ->PP_Event;
                                        PP_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 63 && DOPI && CRC_EN && !CRC_ERR ) begin
                                        if ( ( CRC_CYC[1:0] == 2'b00 && Address[3:0] != 0) ||
                                             ( CRC_CYC[1:0] == 2'b01 && Address[4:0] != 0) ||
                                             ( CRC_CYC[1:0] == 2'b10 && Address[5:0] != 0) ||
                                             ( CRC_CYC[1:0] == 2'b11 && Address[6:0] != 0)) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        else begin
                                            //$display( $time, " Enter Page Program Function ..." );
                                            ->PP_Event;
                                            PP_Mode = 1'b1;
                                        end
                                    end
                                    else if ( CS_INT == 1 && Bit < 39 && !OPI_EN )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1 && Bit < 47 && SOPI )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1 && Bit < 47 && DOPI && !CRC_EN )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1 && Bit < 63 && DOPI && CRC_EN ) begin
                                        STATE <= `BAD_CMD_STATE;
                                    end
                                    else if ( CS_INT == 1 && ( (Bit + 1) % 8 !== 0 ) ) begin
                                        STATE <= `BAD_CMD_STATE;
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) ) 
                                    STATE <= `BAD_CMD_STATE;
                            end

                        SFDP_READ:
                            begin
                                if ( !DP_Mode && !Secur_Mode && !WIP && Chip_EN ) begin
                                    //$display( $time, " Enter SFDP read mode ..." );
                                    if ( Bit == 31 && !OPI_EN ) begin
                                        Address = {8'h00,SI_Reg [23:0]};
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                    load_address(Address);

                                    if ( Bit == 7 && !OPI_EN ) begin
                                        SFDP_Mode = 1;
                                        FastRD_1XIO_Mode = 1'b1;
                                        Read_SHSL = 1'b1;
                                    end
                                    else if ( Bit == 15 && SOPI ) begin
                                        SFDP_Mode = 1;
                                        Read_8XIO_Mode = 1'b1;
                                        Read_SHSL = 1'b1;
                                    end
                                    else if ( Bit == 15 && DOPI ) begin
                                        SFDP_Mode = 1;
                                        DDRRead_8XIO_Mode = 1'b1;
                                        Read_SHSL = 1'b1;
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end


                        WPSEL:
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode && Chip_EN && !EPSUSP ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin
                                        //$display( $time, " Enter Write Protection Selection Function ..." );
                                        ->WPSEL_Event;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin
                                        //$display( $time, " Enter Write Protection Selection Function ..." );
                                        ->WPSEL_Event;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        WRLR:
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode && WPSEL_Mode && Chip_EN && !EPSUSP ) begin
                                    if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end

                                    if ( CS_INT == 1'b1 && Bit == 15 && !OPI_EN ) begin
                                        //$display( $time, " Enter Write Lock Register Function ..." );
                                        ->WRLR_Event;
                                        WRLR_Mode = 1'b1;
                                    end    
                                    else if ( CS_INT == 1'b1 && Bit == 55 && SOPI ) begin
                                        //$display( $time, " Enter Write Lock Register Function ..." );
                                        ->WRLR_Event;
                                        WRLR_Mode = 1'b1;
                                    end    
                                    else if ( CS_INT == 1'b1 && Bit == 63 && DOPI && !CRC_EN ) begin
                                        //$display( $time, " Enter Write Lock Register Function ..." ); 
                                        ->WRLR_Event;
                                        WRLR_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 95 && DOPI && CRC_EN ) begin
                                        if ( SI_Reg[31:24] == ~SI_Reg[15:8]) begin
                                            //$display( $time, " Enter Write Lock Register Function ..." ); 
                                            ->WRLR_Event;
                                            WRLR_Mode = 1'b1;
                                        end
                                        else begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                    end
                                    else if ( CS_INT == 1'b1 && Bit != 15 && !OPI_EN )
                                            STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 &&  Bit != 55 && SOPI )
                                            STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 &&  Bit != 63 && DOPI && !CRC_EN )
                                            STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 &&  Bit != 95 && DOPI && CRC_EN ) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        RDLR:
                            begin 
                                if ( !DP_Mode && !WIP && !Secur_Mode && WPSEL_Mode && Chip_EN ) begin 
                                //$display( $time, " Enter Read Lock Register Function ..." );
                                    Read_SHSL = 1'b1;
                                    RDLR_Mode = 1'b1 ;
                                    if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                end
                                else if ( ( Bit == 7 && !OPI_EN ) || ( Bit == 15 && OPI_EN ) )
                                    STATE <= `BAD_CMD_STATE;    
                            end

`ifdef MODEL_CODE_00
                        WRPASS:
                            begin
                                if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && WPSEL_Mode && Chip_EN && !EPSUSP && PWDMLB ) begin
                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 71 && !OPI_EN ) begin
                                        Pwd_Tmp_Reg[31:0] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 103 && !OPI_EN ) begin
                                        Pwd_Tmp_Reg[63:32] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 79 && SOPI ) begin
                                        Pwd_Tmp_Reg[31:0] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 111 && SOPI ) begin
                                        Pwd_Tmp_Reg[63:32] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 79 && DOPI && !CRC_EN ) begin
                                        Pwd_Tmp_Reg[31:0] = { SI_Reg[15:8], SI_Reg[7:0],  SI_Reg[31:24], SI_Reg[23:16] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 111 && DOPI && !CRC_EN ) begin
                                        Pwd_Tmp_Reg[63:32] = { SI_Reg[15:8], SI_Reg[7:0],  SI_Reg[31:24], SI_Reg[23:16] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 95 && DOPI && CRC_EN ) begin
                                        Pwd_Tmp_Reg[31:0] = { SI_Reg[15:8], SI_Reg[7:0],  SI_Reg[31:24], SI_Reg[23:16] };

                                        crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 127 && DOPI && CRC_EN ) begin
                                        Pwd_Tmp_Reg[63:32] = { SI_Reg[15:8], SI_Reg[7:0],  SI_Reg[31:24], SI_Reg[23:16] };

                                        crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                    end
                                    else if ( CS_INT == 1'b0 && Bit >= 128 && ( (Bit-127)%32 == 0 ) && DOPI && CRC_EN && (
                                              ( Bit <= 191 && CRC_CYC[1:0] == 2'b00 ) || 
                                              ( Bit <= 319 && CRC_CYC[1:0] == 2'b01 ) || 
                                              ( Bit <= 575 && CRC_CYC[1:0] == 2'b10 ) || 
                                              ( Bit <= 1087 && CRC_CYC[1:0] == 2'b11 ) ) 
                                            ) begin
                                        if ( SI_Reg [31:0] != 32'hffff_ffff ) begin
                                            STATE <= `BAD_CMD_STATE;    
                                        end
                                    end
                                    else if ( CS_INT == 1'b0 && DOPI && CRC_EN && (
                                              ( Bit == 207 &&  CRC_CYC[1:0] == 2'b00 ) ||
                                              ( Bit == 335 &&  CRC_CYC[1:0] == 2'b01 ) ||
                                              ( Bit == 591 &&  CRC_CYC[1:0] == 2'b10 ) ||
                                              ( Bit == 1103 &&  CRC_CYC[1:0] == 2'b11 ) )
                                            ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end

                                    if ( CS_INT == 1'b0 && Bit == 103 && !OPI_EN ) begin
                                        //$display( $time, " Enter Write Lock Register Function ..." ); 
                                        ->WRPASS_Event;
                                        WRPASS_Mode = 1'b1;
                                    end    
                                    else if ( CS_INT == 1'b0 && Bit == 111 && SOPI ) begin
                                        //$display( $time, " Enter Write Lock Register Function ..." );
                                        ->WRPASS_Event;
                                        WRPASS_Mode = 1'b1;
                                    end    
                                    else if ( CS_INT == 1'b0 && Bit == 111 && DOPI && !CRC_EN ) begin
                                        //$display( $time, " Enter Write Lock Register Function ..." );
                                        ->WRPASS_Event;
                                        WRPASS_Mode = 1'b1;
                                    end    
                                    else if ( CS_INT == 1'b1 && DOPI && CRC_EN && (
                                              ( Bit == 207 && CRC_CYC[1:0] == 2'b00 ) ||
                                              ( Bit == 335 && CRC_CYC[1:0] == 2'b01 ) ||
                                              ( Bit == 591 && CRC_CYC[1:0] == 2'b10 ) ||
                                              ( Bit == 1103 && CRC_CYC[1:0] == 2'b11 ) )
                                            ) begin
                                        //$display( $time, " Enter Write Fast Boot Register Function ..." ); 
                                        ->WRPASS_Event;
                                        WRPASS_Mode = 1'b1;
                                    end 

                                    else if ( CS_INT == 1'b1 && Bit != 103 && !OPI_EN ) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit != 111 && SOPI ) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit != 111 && DOPI && !CRC_EN) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                    else if ( CS_INT == 1'b1 && DOPI && CRC_EN && (
                                              ( Bit != 207 && CRC_CYC[1:0] == 2'b00 ) ||
                                              ( Bit != 335 && CRC_CYC[1:0] == 2'b01 ) ||
                                              ( Bit != 591 && CRC_CYC[1:0] == 2'b10 ) ||
                                              ( Bit != 1103 && CRC_CYC[1:0] == 2'b11 ) )
                                            ) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                end
                                else if (( Bit == 7 && !OPI_EN ) || ( Bit == 15 && OPI_EN))
                                    STATE <= `BAD_CMD_STATE;
                            end

                        PASSULK:
                            begin
                                if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && WPSEL_Mode && Chip_EN && !EPSUSP && !PWDMLB ) begin
                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 71 && !OPI_EN ) begin
                                        Pwd_Tmp_Reg[31:0] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 103 && !OPI_EN ) begin
                                        Pwd_Tmp_Reg[63:32] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 79 && SOPI ) begin
                                        Pwd_Tmp_Reg[31:0] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 111 && SOPI ) begin
                                        Pwd_Tmp_Reg[63:32] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 79 && DOPI && !CRC_EN ) begin
                                        Pwd_Tmp_Reg[31:0] = { SI_Reg[15:8], SI_Reg[7:0],  SI_Reg[31:24], SI_Reg[23:16] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 111 && DOPI && !CRC_EN ) begin
                                        Pwd_Tmp_Reg[63:32] = { SI_Reg[15:8], SI_Reg[7:0],  SI_Reg[31:24], SI_Reg[23:16] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 95 && DOPI && CRC_EN ) begin
                                        Pwd_Tmp_Reg[31:0] = { SI_Reg[15:8], SI_Reg[7:0],  SI_Reg[31:24], SI_Reg[23:16] };

                                        crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 127 && DOPI && CRC_EN ) begin
                                        Pwd_Tmp_Reg[63:32] = { SI_Reg[15:8], SI_Reg[7:0],  SI_Reg[31:24], SI_Reg[23:16] };

                                        crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                        crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                    end
                                    else if ( CS_INT == 1'b0 && Bit >= 128 && ( (Bit-127)%32 == 0 ) && DOPI && CRC_EN && (
                                              ( Bit <= 191 && CRC_CYC[1:0] == 2'b00 ) || 
                                              ( Bit <= 319 && CRC_CYC[1:0] == 2'b01 ) || 
                                              ( Bit <= 575 && CRC_CYC[1:0] == 2'b10 ) || 
                                              ( Bit <= 1087 && CRC_CYC[1:0] == 2'b11 ) ) 
                                            ) begin
                                        if ( SI_Reg [31:0] != 32'hffff_ffff ) begin
                                            STATE <= `BAD_CMD_STATE;    
                                        end
                                    end
                                    else if ( CS_INT == 1'b0 && DOPI && CRC_EN && (
                                              ( Bit == 207 &&  CRC_CYC[1:0] == 2'b00 ) ||
                                              ( Bit == 335 &&  CRC_CYC[1:0] == 2'b01 ) ||
                                              ( Bit == 591 &&  CRC_CYC[1:0] == 2'b10 ) ||
                                              ( Bit == 1103 &&  CRC_CYC[1:0] == 2'b11 ) )
                                            ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end

                                    if ( CS_INT == 1'b0 && Bit == 103 && !OPI_EN ) begin
                                        //$display( $time, " Enter Write Lock Register Function ..." ); 
                                        ->PASSULK_Event;
                                        PASSULK_Mode = 1'b1;
                                    end    
                                    else if ( CS_INT == 1'b0 && Bit == 111 && SOPI ) begin
                                        //$display( $time, " Enter Write Lock Register Function ..." ); 
                                        ->PASSULK_Event;
                                        PASSULK_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 111 && DOPI && !CRC_EN ) begin
                                        //$display( $time, " Enter Write Lock Register Function ..." ); 
                                        ->PASSULK_Event;
                                        PASSULK_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && DOPI && CRC_EN && (
                                              ( Bit == 207 && CRC_CYC[1:0] == 2'b00 ) ||
                                              ( Bit == 335 && CRC_CYC[1:0] == 2'b01 ) ||
                                              ( Bit == 591 && CRC_CYC[1:0] == 2'b10 ) ||
                                              ( Bit == 1103 && CRC_CYC[1:0] == 2'b11 ) )
                                            ) begin
                                        //$display( $time, " Enter Write Fast Boot Register Function ..." ); 
                                        ->PASSULK_Event;
                                        PASSULK_Mode = 1'b1;
                                    end 

                                    else if ( CS_INT == 1'b1 && Bit != 103 && !OPI_EN ) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit != 111 && SOPI ) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit != 111 && DOPI && !CRC_EN) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                    else if ( CS_INT == 1'b1 && DOPI && CRC_EN && (
                                              ( Bit != 207 && CRC_CYC[1:0] == 2'b00 ) ||
                                              ( Bit != 335 && CRC_CYC[1:0] == 2'b01 ) ||
                                              ( Bit != 591 && CRC_CYC[1:0] == 2'b10 ) ||
                                              ( Bit != 1103 && CRC_CYC[1:0] == 2'b11 ) )
                                            ) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN))
                                    STATE <= `BAD_CMD_STATE;
                            end

                        RDPASS:
                            begin
                                if ( !DP_Mode && !WIP && Norm_Array_Mode && WPSEL_Mode && Chip_EN && PWDMLB ) begin
                                    //$display( $time, " Enter Read Password Register Function ..." );
                                    Read_SHSL = 1'b1;
                                    RDPASS_Mode = 1'b1;
                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end
`endif
                        WRSPB:
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode && WPSEL_Mode && Chip_EN && !EPSUSP ) begin
                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end

                                    if ( CS_INT == 1'b1 && Bit == 39 && !OPI_EN ) begin
                                        //$display( $time, " Enter Write SPB Function ..." );
                                        ->WRSPB_Event;
                                        WRSPB_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 47 && SOPI ) begin
                                        //$display( $time, " Enter Write SPB Function ..." );
                                        ->WRSPB_Event;
                                        WRSPB_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 47 && DOPI && !CRC_EN ) begin
                                        //$display( $time, " Enter Write SPB Function ..." );
                                        ->WRSPB_Event;
                                        WRSPB_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 63 && DOPI && CRC_EN ) begin
                                        //$display( $time, " Enter Write SPB Function ..." );
                                        ->WRSPB_Event;
                                        WRSPB_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit != 39 && !OPI_EN )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 47 && SOPI )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 47 && DOPI && !CRC_EN )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 63 && DOPI && CRC_EN ) begin
                                        STATE <= `BAD_CMD_STATE;
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        RDSPB:
                            begin
                                if ( !DP_Mode && !WIP && !Secur_Mode && WPSEL_Mode && Chip_EN ) begin
                                    //$display( $time, " Enter Read SPB Register Function ..." );
                                    Read_SHSL = 1'b1;
                                    RDSPB_Mode = 1'b1 ;

                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        ESSPB:
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode && WPSEL_Mode && Chip_EN && !EPSUSP ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin
                                        //$display( $time, " Enter Erase SPB Function ..." );
                                        ->ESSPB_Event;
                                        ESSPB_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin
                                        //$display( $time, " Enter Erase SPB Function ..." );
                                        ->ESSPB_Event;
                                        ESSPB_Mode = 1'b1;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        WRDPB:
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode && WPSEL_Mode && Chip_EN && !EPSUSP ) begin
                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end

                                    if ( CS_INT == 1'b1 && Bit == 47 && !OPI_EN ) begin
                                        //$display( $time, " Enter Write DPB Function ..." );
                                        ->WRDPB_Event;
                                        WRDPB_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 55 && SOPI ) begin
                                        //$display( $time, " Enter Write DPB Function ..." );
                                        ->WRDPB_Event;
                                        WRDPB_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 63 && DOPI && !CRC_EN ) begin
                                        //$display( $time, " Enter Write DPB Function ..." );
                                        ->WRDPB_Event;
                                        WRDPB_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 95 && DOPI && CRC_EN ) begin
                                        if ( SI_Reg[31:24] == ~SI_Reg[15:8]) begin
                                            //$display( $time, " Enter Write DPB Function ..." );
                                            ->WRDPB_Event;
                                            WRDPB_Mode = 1'b1;
                                        end
                                        else begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                    end
                                    else if ( CS_INT == 1'b1 && Bit != 47 && !OPI_EN )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 55 && SOPI )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 63 && DOPI && !CRC_EN )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 95 && DOPI && CRC_EN ) begin
                                        STATE <= `BAD_CMD_STATE;
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        RDDPB:
                            begin
                                if ( !DP_Mode && !WIP && !Secur_Mode && WPSEL_Mode && Chip_EN ) begin
                                    //$display( $time, " Enter Read DPB Register Function ..." );
                                    Read_SHSL = 1'b1;
                                    RDDPB_Mode = 1'b1 ;

                                    if ( Bit == 39 && !OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;
                                    end
                                    else if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg[A_MSB:0] ;

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        GBLK:
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode && WPSEL_Mode && Chip_EN && !EPSUSP ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin
                                        //$display( $time, " Enter Chip Protection Function ..." );
                                        ->GBLK_Event;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin
                                        //$display( $time, " Enter Chip Protection Function ..." );
                                        ->GBLK_Event;
                                    end 
                                    else if ( CS_INT == 1'b1 && ( (Bit != 7 && !OPI_EN) || (Bit != 15 && OPI_EN) ) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        GBULK:
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode && WPSEL_Mode && Chip_EN && !EPSUSP ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin
                                        //$display( $time, " Enter Chip Unprotection Function ..." );
                                        ->GBULK_Event;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin
                                        //$display( $time, " Enter Chip Unprotection Function ..." );
                                        ->GBULK_Event;
                                    end 
                                    else if ( CS_INT == 1'b1 && ( (Bit != 7 && !OPI_EN) || (Bit != 15 && OPI_EN) ) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        RDFBR:
                            begin 
                                if ( !DP_Mode && !WIP && Chip_EN ) begin 
                                    //$display( $time, " Enter Read Fast Boot Register Function ..." );
                                    if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                    Read_SHSL = 1'b1;
                                    RDFBR_Mode = 1'b1 ;
                                end
                                else if ( (Bit == 7 &&  !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;    
                            end

                        WRFBR:
                            begin
                                if ( !DP_Mode && !WIP && WEL && Chip_EN && !Secur_Mode && !EPSUSP ) begin
                                    if (  CS_INT == 1'b0 && Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 39 && !OPI_EN ) begin
                                        FB_Tmp_Reg[31:0] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 79 && SOPI ) begin
                                        FB_Tmp_Reg[31:0] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 79 && DOPI && !CRC_EN ) begin
                                        FB_Tmp_Reg[31:0] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };
                                    end
                                    else if ( CS_INT == 1'b0 && Bit == 95 && DOPI && CRC_EN ) begin
                                        FB_Tmp_Reg[31:0] = { SI_Reg[7:0], SI_Reg[15:8], SI_Reg[23:16], SI_Reg[31:24] };

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( CS_INT == 1'b0 && Bit >= 96 && ( (Bit-95)%32 == 0 ) && DOPI && CRC_EN && (
                                              ( Bit <= 191 && CRC_CYC[1:0] == 2'b00 ) || 
                                              ( Bit <= 319 && CRC_CYC[1:0] == 2'b01 ) || 
                                              ( Bit <= 575 && CRC_CYC[1:0] == 2'b10 ) || 
                                              ( Bit <= 1087 && CRC_CYC[1:0] == 2'b11 ) ) 
                                            ) begin
                                        if ( SI_Reg [31:0] != 32'hffff_ffff ) begin
                                            STATE <= `BAD_CMD_STATE;    
                                        end
                                    end
                                    else if ( CS_INT == 1'b0 && DOPI && CRC_EN && (
                                              ( Bit == 207 &&  CRC_CYC[1:0] == 2'b00 ) ||
                                              ( Bit == 335 &&  CRC_CYC[1:0] == 2'b01 ) ||
                                              ( Bit == 591 &&  CRC_CYC[1:0] == 2'b10 ) ||
                                              ( Bit == 1103 &&  CRC_CYC[1:0] == 2'b11 ) )
                                            ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end

                                    if ( CS_INT == 1'b1 && Bit == 39 && !OPI_EN ) begin
                                        //$display( $time, " Enter Write Fast Boot Register Function ..." );
                                        ->WRFBR_Event;
                                        WRFBR_Mode = 1'b1;
                                    end    
                                    else if ( CS_INT == 1'b1 && Bit == 79 && SOPI ) begin
                                        //$display( $time, " Enter Write Fast Boot Register Function ..." ); 
                                        ->WRFBR_Event;
                                        WRFBR_Mode = 1'b1;
                                    end    
                                    else if ( CS_INT == 1'b1 && Bit == 79 && DOPI && !CRC_EN ) begin
                                        //$display( $time, " Enter Write Fast Boot Register Function ..." ); 
                                        ->WRFBR_Event;
                                        WRFBR_Mode = 1'b1;
                                    end    
                                    else if ( CS_INT == 1'b1 && DOPI && CRC_EN && (
                                              ( Bit == 207 && CRC_CYC[1:0] == 2'b00 ) ||
                                              ( Bit == 335 && CRC_CYC[1:0] == 2'b01 ) ||
                                              ( Bit == 591 && CRC_CYC[1:0] == 2'b10 ) ||
                                              ( Bit == 1103 && CRC_CYC[1:0] == 2'b11 ) )
                                            ) begin
                                        //$display( $time, " Enter Write Fast Boot Register Function ..." ); 
                                        ->WRFBR_Event;
                                        WRFBR_Mode = 1'b1;
                                    end    
                                    else if ( CS_INT == 1'b1 && Bit != 39 && !OPI_EN )
                                        STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 79 && SOPI )
                                            STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && Bit != 79 && DOPI && !CRC_EN )
                                            STATE <= `BAD_CMD_STATE;
                                    else if ( CS_INT == 1'b1 && DOPI && CRC_EN && (
                                              ( Bit != 207 && CRC_CYC[1:0] == 2'b00 ) ||
                                              ( Bit != 335 && CRC_CYC[1:0] == 2'b01 ) ||
                                              ( Bit != 591 && CRC_CYC[1:0] == 2'b10 ) ||
                                              ( Bit != 1103 && CRC_CYC[1:0] == 2'b11 ) )
                                            ) begin
                                            STATE <= `BAD_CMD_STATE;
                                    end
                                end
                                else if (  (Bit == 7 &&  !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        ESFBR:
                            begin
                                if ( !DP_Mode && !WIP && WEL && Chip_EN && !Secur_Mode && !EPSUSP ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin
                                        //$display( $time, " Enter Erase Fast Boot Register Function ..." );
                                        ->ESFBR_Event;
                                        ESFBR_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin
                                        //$display( $time, " Enter Erase Fast Boot Register Function ..." );
                                        ->ESFBR_Event;
                                        ESFBR_Mode = 1'b1;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if (  (Bit == 7 &&  !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        DP:
                            begin
                                if ( !WIP && Chip_EN && !EPSUSP ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN && DP_Mode == 1'b0 ) begin
                                        //$display( $time, " Enter Deep Power Down Function ..." );
                                        tDP_Chk = 1'b1;
                                        DP_Mode = 1'b1;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN && DP_Mode == 1'b0 ) begin
                                        //$display( $time, " Enter Deep Power Down Function ..." );
                                        tDP_Chk = 1'b1;
                                        DP_Mode = 1'b1;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 &&  !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        RDP:
                            begin
                                if ( !WIP && Chip_EN ) begin
                                    // $display( $time, " Enter Release from Deep Power Down Function ..." );
                                    Read_SHSL = 1'b1;
                   
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN && DP_Mode ) begin
                                        tRES1_Chk = 1'b1;
                                        DP_Mode = 1'b0;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN && DP_Mode ) begin
                                        tRES1_Chk = 1'b1;
                                        DP_Mode = 1'b0;
                                    end
                                    
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end
                        ENSO: 
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN  ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin  
                                        //$display( $time, " Enter ENSO  Function ..." );
                                        enter_secured_otp;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin  
                                        //$display( $time, " Enter ENSO  Function ..." );
                                        enter_secured_otp;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end
                          
                        EXSO: 
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin  
                                        //$display( $time, " Exit ENSO  Function ..." );
                                        exit_secured_otp;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin  
                                        //$display( $time, " Exit ENSO  Function ..." );
                                        exit_secured_otp;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end
                          
                        RDSCUR: 
                            begin
                                if ( !DP_Mode && Chip_EN ) begin 
                                    // $display( $time, " Enter Read Secur_Register Function ..." );
                                    Read_SHSL = 1'b1;
                                    RDSCUR_Mode = 1'b1;
                                    if ( Bit == 47 && OPI_EN ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);

                                        if ( DOPI && CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && DOPI && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;    
                            end
                          
                          
                        WRSCUR: 
                            begin
                                if ( !DP_Mode && !WIP && WEL && !Secur_Mode && Chip_EN && !EPSUSP ) begin
                                    if ( CS_INT == 1'b1 && Bit == 7 && !OPI_EN ) begin  
                                        //$display( $time, " Enter WRSCUR Secur_Register Function ..." );
                                        ->WRSCUR_Event;
                                    end
                                    else if ( CS_INT == 1'b1 && Bit == 15 && OPI_EN ) begin  
                                        //$display( $time, " Enter WRSCUR Secur_Register Function ..." );
                                        ->WRSCUR_Event;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;    
                            end
                          
                        READ8X:
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN && SOPI ) begin
                                    //$display( $time, " Enter READX8 Function ..." );
                                    Read_SHSL = 1'b1;
                                    if ( Bit == 47 ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);
                                    end
                                    Read_8XIO_Mode = 1'b1;
                                end
                                else if ( Bit == 15 && OPI_EN )
                                    STATE <= `BAD_CMD_STATE;                        
                            end
                                              
                        DDRREAD8X:
                            begin
                                if ( !DP_Mode && !WIP && Chip_EN && DOPI ) begin
                                    //$display( $time, " Enter DDRREADX8 Function ..." );
                                    Read_SHSL = 1'b1;
                                    if ( Bit == 47 ) begin
                                        Address = SI_Reg [A_MSB:0];
                                        load_address(Address);

                                        if ( CRC_EN ) begin
                                            crc_calculation(SI_Reg[31:24], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[23:16], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[15:8], 1, CRC[7:0]);
                                            crc_calculation(SI_Reg[7:0], 1, CRC[7:0]);
                                        end
                                    end
                                    else if ( Bit == 63 && CRC_EN ) begin
                                        if ( CRC[7:0] !== SI_Reg[15:8] ) begin
                                            STATE <= `BAD_CMD_STATE;
                                        end
                                        crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                    end
                                    DDRRead_8XIO_Mode = 1'b1;
                                end
                                else if ( Bit == 15 && OPI_EN )
                                    STATE <= `BAD_CMD_STATE;                        
                            end
                                              
                        RSTEN:
                            begin
                                if ( Chip_EN ) begin
                                    if ( CS_INT == 1'b1 && ((Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN)) ) begin
                                        //$display( $time, " Reset enable ..." );
                                        ->RST_EN_Event;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        RST:
                            begin
                                if ( Chip_EN && RST_CMD_EN ) begin
                                    if ( CS_INT == 1'b1 && ((Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN)) ) begin
                                        //$display( $time, " Reset memory ..." );
                                        ->RST_Event;
                                    end
                                    else if ( (Bit > 7 && !OPI_EN) || (Bit > 15 && OPI_EN) )
                                        STATE <= `BAD_CMD_STATE;
                                end
                                else if ( (Bit == 7 && !OPI_EN) || (Bit == 15 && OPI_EN) )
                                    STATE <= `BAD_CMD_STATE;
                            end

                        NOP:
                            begin
                            end

                        default: 
                                begin
                                    STATE <= `BAD_CMD_STATE;
                                end
                        endcase
                    end
                     
                `BAD_CMD_STATE: 
                    begin
                        if( DOPI && CRC_EN ) CRC_ERR = 1;
                    end
                
                default: 
                    begin
                        STATE =  `STANDBY_STATE;
                    end
            endcase
        end
    end

    always @ (posedge CS_INT) begin
            SIO_Reg <= #tSHQZ 8'bxxxx_xxxx;
            SIO_Out_Reg <= #tSHQZ 8'bxxxx_xxxx;
            DQS_Reg <= #tSHQZ 1'bz; 
            ECSB_Reg <= #tSHQZ 1'bz;
           
            SO_OUT_EN    <= #tSHQZ 1'b0;
            SI_OUT_EN    <= #tSHQZ 1'b0;
            OPI_OUT_EN   <= #tSHQZ 1'b0;
            DQS_OUT_EN   <= #tSHQZ 1'b0;
            DQS_TOGGLE_EN <= #tSHQZ 1'b0;
            Prea_OUT_EN1     = 1'b0;
            Prea_OUT_EN8     = 1'b0;
            #1;
            Not_Mode0   = 1'b0;
            Bit         = 1'b0;
            Bit_Tmp     = 1'b0;
           
            SO_IN_EN    = 1'b0;
            SI_IN_EN    = 1'b0;
            OPI_IN_EN   = 1'b0;

            CRC_ERR = 0;
            crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
            ECC_1b_correct = 1'b0;
            ECC_2b_detect  = 1'b0;
            ECC_double_pgm = 1'b0;
            Read_start     = 1'b0;
            RDID_Mode   = 1'b0;
            RDSR_Mode   = 1'b0;
            RDCR2_Mode  = 1'b0;
            RDCR_Mode   = 1'b0;
            RDSCUR_Mode = 1'b0;
            RDLR_Mode   = 1'b0;
            RDSPB_Mode   = 1'b0;
            RDDPB_Mode   = 1'b0;
            RDPASS_Mode  = 1'b0;
            RDFBR_Mode   = 1'b0;
            Read_Mode   = 1'b0;
            RD_Mode      = 1'b0;
            SFDP_Mode    = 1'b0;
            Read_1XIO_Mode  = 1'b0;
            Read_8XIO_Mode  = 1'b0;
            Read_1XIO_Chk   = 1'b0;
            Read_8XIO_Chk   = 1'b0;
            DDRRead_8XIO_Mode = 1'b0;
            DDRRead_8XIO_Chk  = 1'b0;
            FastRD_1XIO_Mode= 1'b0;
            STATE <=  `STANDBY_STATE;

            if( Chip_EN ) begin
                EN_Boot     = 1'b0;
            end
            FAST_BOOT_Mode  = 1'b0;
            FAST_BOOT_Chk   = 1'b0;

            ADD_3B_Mode = 1'b0;

            disable read_id;
            disable read_status;
            disable read_cr2;
            disable read_cr;
            disable read_Secur_Register;
            disable read_1xio;
            disable read_8xio;
            disable read_password_register;
            disable ddrread_8xio;
            disable fastread_1xio;
            disable read_function;
            disable dummy_cycle;
            disable fast_boot_read;
            disable read_FB_register;
    end



    always @ ( negedge Prea_OUT_EN1 or negedge Prea_OUT_EN8 ) begin
        #tCLQV;
        if ( !Prea_OUT_EN1 && !Prea_OUT_EN8 ) begin
                disable preamble_bit_out;
                disable preamble_bit_out_dtr;
        end
    end

    
    /*----------------------------------------------------------------------*/
    /*  ALL function trig action                                            */
    /*----------------------------------------------------------------------*/
    always @ ( posedge Read_1XIO_Mode
            or posedge FastRD_1XIO_Mode
            or posedge Read_8XIO_Mode 
            or posedge DDRRead_8XIO_Mode
           ) begin:read_function 
        wait ( SCLK == 1'b0 );
        if ( Read_1XIO_Mode == 1'b1 ) begin
            Read_1XIO_Chk = 1'b1;
            read_1xio;
        end
        else if ( FastRD_1XIO_Mode == 1'b1 ) begin
            fastread_1xio;
        end
        else if ( Read_8XIO_Mode == 1'b1 ) begin
            Read_8XIO_Chk = 1'b1;
            read_8xio;
        end
        else if ( DDRRead_8XIO_Mode == 1'b1 ) begin
            DDRRead_8XIO_Chk = 1'b1;
            ddrread_8xio;
        end
    end 

    always @ ( posedge FAST_BOOT_Mode ) begin
        FAST_BOOT_Chk = 1'b1;
        fast_boot_read;
    end

    always @ ( RST_EN_Event ) begin
        RST_CMD_EN = #2 1'b1;
    end
    
    always @ ( RST_Event ) begin
        During_RST_REC = 1;
        if ((WRSR_Mode||WRSR2_Mode||WRSR_OPI_Mode) && tWRSR==tW) begin
            #(tREADY2_W);
        end
        else if ( WRLR_Mode || WR_WPSEL_Mode || WRPASS_Mode || PASSULK_Mode || WRSPB_Mode || WRFBR_Mode || WRSCUR_Mode || PP_Mode ) begin
            #(tREADY2_P);
        end
        else if ( SE_4K_Mode || ESSPB_Mode || ESFBR_Mode ) begin
            #(tREADY2_SE);
        end
        else if ( BE64K_Mode ) begin
            #(tREADY2_BE);
        end
        else if ( CE_Mode ) begin
            #(tREADY2_CE);
        end
        else if ( DP_Mode == 1'b1 ) begin
            #(tRES1);
        end
        else if ( Read_SHSL == 1'b1 ) begin
            #(tREADY2_R);
        end
        else begin
            #(tREADY2_D);
        end
        disable write_status;
        disable write_status_opi;
        disable write_cr2;
        disable block_erase;
        disable sector_erase_4k;
        disable chip_erase;
        disable page_program; // can deleted
        disable update_array;
        disable read_Secur_Register;
        disable write_secur_register;
        disable read_id;
        disable read_cr2;
        disable read_cr;
        disable read_status;
        disable suspend_write;
        disable resume_write;
        disable er_timer;
        disable pg_timer;
        disable stimeout_cnt;
        disable rtimeout_cnt;

        disable read_1xio;
        disable read_8xio;
        disable ddrread_8xio;
        disable fastread_1xio;
        disable read_function;
        disable dummy_cycle;

        disable fast_boot_read;
        disable read_FB_register;
        disable write_FB_register;
        disable erase_FB_register;

        disable write_lock_register;
        disable program_spb_register;
        disable erase_spb_register;
        disable write_dpb_register;
        disable write_protection_select;
        disable read_lock_register;
        disable read_spb_register;
        disable read_dpb_register;

        disable read_password_register;
        disable password_unlock;
        disable write_password_register;

        disable chip_lock;
        disable chip_unlock;
        reset_sm;
        Status_Reg[1:0] = 2'b0;
        Secur_Reg[6:2]  = 5'b0;

        CR[2:0]         = 3'b111;
        CR[4]           = 1'b0;
//        CR2[xx]      = 0;   //not defined yet
    end

// *==============================================================================================
// * Hardware Reset Function description
// * =============================================================================================
    always @ ( negedge RESETB_INT ) begin
        if (RESETB_INT == 1'b0) begin
            disable hd_reset;
            #0;
            -> HDRST_Event;
        end
    end
    always @ ( HDRST_Event ) begin: hd_reset
      if (RESETB_INT == 1'b0) begin
        During_RST_REC = 1;
        if ((WRSR_Mode||WRSR2_Mode||WRSR_OPI_Mode) && tWRSR==tW) begin
            #(tREADY2_W);
        end
        else if ( WRLR_Mode || WR_WPSEL_Mode || WRPASS_Mode || PASSULK_Mode || WRSPB_Mode || WRFBR_Mode || WRSCUR_Mode || PP_Mode ) begin
            #(tREADY2_P);
        end
        else if ( SE_4K_Mode || ESSPB_Mode || ESFBR_Mode ) begin
            #(tREADY2_SE);
        end
        else if ( BE64K_Mode ) begin
            #(tREADY2_BE);
        end
        else if ( CE_Mode ) begin
            #(tREADY2_CE);
        end
        else if ( DP_Mode == 1'b1 ) begin
            #(tRES1+tRLRH);
        end
        else if ( Read_SHSL == 1'b1 ) begin
            #(tREADY2_R);
        end
        else begin
            #(tREADY2_D);
        end
        disable write_status;
        disable write_cr2; 
        disable write_status_opi;
        disable block_erase;
        disable sector_erase_4k;
        disable chip_erase;
        disable page_program; // can deleted
        disable update_array;
        disable read_Secur_Register;
        disable write_secur_register;
        disable read_id;
        disable read_status;
        disable suspend_write;
        disable resume_write;
        disable er_timer;
        disable pg_timer;
        disable stimeout_cnt;
        disable rtimeout_cnt;

        disable read_1xio;
        disable read_8xio;
        disable ddrread_8xio;
        disable fastread_1xio;
        disable read_function;
        disable dummy_cycle;
        disable read_cr;
        disable read_cr2; 
        disable fast_boot_read;
        disable read_FB_register;
        disable write_FB_register;
        disable erase_FB_register;

        disable read_password_register;
        disable password_unlock;
        disable write_password_register;

        disable write_lock_register;
        disable program_spb_register;
        disable erase_spb_register;
        disable write_dpb_register;
        disable write_protection_select;
        disable read_lock_register;
        disable read_spb_register;
        disable read_dpb_register;
        disable chip_lock;
        disable chip_unlock;

        reset_sm;
        Status_Reg[1:0] = 2'b0;
        Secur_Reg[6:2]  = 5'b0;
        CR[2:0]         = 3'b111;
        CR[4]           = 1'b0;
//        CR2[xx]      = 0;   //not defined yet
      end
    end

    always @ ( posedge Susp_Trig ) begin:stimeout_cnt
        Susp_Trig <= #1 1'b0;
    end

    always @ ( posedge Resume_Trig ) begin:rtimeout_cnt
        Resume_Trig <= #1 1'b0;
    end

    always @ ( WRSR_Event ) begin
        write_status;
    end

    always @ ( WRSR_OPI_Event ) begin
        write_status_opi;
    end

    always @ ( WRCR2_Event ) begin
        write_cr2;
    end

    always @ ( WRFBR_Event ) begin
        write_FB_register;
    end

    always @ ( ESFBR_Event ) begin
        erase_FB_register;
    end

    always @ ( BE_Event ) begin
        block_erase;
    end

    always @ ( CE_Event ) begin
        chip_erase;
    end

    
    always @ ( PP_Event ) begin:page_program_mode
        page_program( Address );
    end
   
    always @ ( SE_4K_Event ) begin
        sector_erase_4k;
    end

    always @ ( posedge RDID_Mode ) begin
        read_id;
    end

    always @ ( posedge RDSR_Mode ) begin
        read_status;
    end

    always @ ( posedge RDCR2_Mode ) begin
        read_cr2;
    end

    always @ ( posedge RDCR_Mode ) begin
        read_cr;
    end

    always @ ( posedge RDSCUR_Mode ) begin
        read_Secur_Register;
    end

    always @ ( WPSEL_Event ) begin
        write_protection_select;
    end

    always @ ( WRLR_Event ) begin
        write_lock_register;
    end

    always @ ( WRSPB_Event ) begin
        program_spb_register;
    end

    always @ ( ESSPB_Event ) begin
        erase_spb_register;
    end

    always @ ( WRDPB_Event ) begin
        write_dpb_register;
    end

    always @ ( posedge RDLR_Mode ) begin
        read_lock_register;
    end

    always @ ( posedge RDSPB_Mode ) begin
        read_spb_register;
    end

    always @ ( posedge RDDPB_Mode ) begin
        read_dpb_register;
    end

    always @ ( posedge RDPASS_Mode ) begin
        read_password_register;
    end


    always @ ( GBLK_Event ) begin
        chip_lock;
    end

    always @ ( GBULK_Event ) begin
        chip_unlock;
    end

    always @ ( WRPASS_Event ) begin
        write_password_register;
    end

    always @ ( PASSULK_Event ) begin
        password_unlock;
    end

    always @ ( posedge RDFBR_Mode ) begin
        read_FB_register;
    end

    always @ ( WRSCUR_Event ) begin
        write_secur_register;
    end

    always @ ( Susp_Event ) begin
        suspend_write;
    end

    always @ ( Resume_Event ) begin
        resume_write;
    end



// *========================================================================================== 
// * Module Task Declaration
// *========================================================================================== 
    /*----------------------------------------------------------------------*/
    /*  Description: define a wait dummy cycle task                         */
    /*  INPUT                                                               */
    /*      Cnum: cycle number                                              */
    /*----------------------------------------------------------------------*/
    task dummy_cycle;
        input [31:0] Cnum;
        begin
            repeat( Cnum ) begin
                @ ( posedge SCLK );
            end
        end
    endtask // dummy_cycle

    task dummy_cycle_prea;
        input [31:0] Cnum;
        begin
            repeat( Cnum ) begin
                @ ( posedge SCLK );
            end
        end
    endtask // dummy_cycle_prea

    /*----------------------------------------------------------------------*/
    /*  Description: define a write enable task                             */
    /*----------------------------------------------------------------------*/
    task write_enable;
        begin
            //$display( $time, " Old Status Register = %b", Status_Reg );
            Status_Reg[1] = 1'b1; 
            // $display( $time, " New Status Register = %b", Status_Reg );
        end
    endtask // write_enable
    
    /*----------------------------------------------------------------------*/
    /*  Description: define a write disable task (WRDI)                     */
    /*----------------------------------------------------------------------*/
    task write_disable;
        begin
            //$display( $time, " Old Status Register = %b", Status_Reg );
            Status_Reg[1]  = 1'b0;
            //$display( $time, " New Status Register = %b", Status_Reg );
        end
    endtask // write_disable
    
    /*----------------------------------------------------------------------*/
    /*  Description: define a read id task (RDID)                           */
    /*----------------------------------------------------------------------*/
    task read_id;
        reg  [23:0] Dummy_ID;
        integer Dummy_Count;
        begin
            Dummy_ID = {ID_MXIC, Memory_Type, Memory_Density};
                
            if( DOPI ) begin
                Dummy_Count = CRC_EN ? 6 : 3;
            end
            else if( SOPI ) begin
                Dummy_Count = 3;
            end
            else if( !OPI_EN ) begin
                Dummy_Count = 24;
            end

            if( OPI_EN ) begin 
                if( SOPI ) begin
                    dummy_cycle(4); //for address
                    #0.1;
                    if( Address !== 0 ) begin
                        disable read_id;
                    end
                    dummy_cycle(1);
                    @( negedge SCLK );
                    if( STRDQS )begin
                        DQS_OUT_EN = 1;
                    end

                    dummy_cycle(2);
                    @( negedge SCLK );
                    SI_OUT_EN   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                    SIO_Reg <=  8'hxx;
                    dummy_cycle(1);
                    DQS_TOGGLE_EN = 1'b1;
                end
                else if( DOPI ) begin
                    dummy_cycle(2 + CRC_EN); //for address
                    @( negedge SCLK );
                    #0.1;
                    if( Address !== 0 ) begin
                        disable read_id;
                    end
                    if ( CRC_ERR ) begin
                        disable read_id;
                    end
                    dummy_cycle(2);
                    DQS_OUT_EN = 1;

                    if( DDQSPRC ) begin
                        dummy_cycle(1);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    else if( !DDQSPRC ) begin
                        dummy_cycle(2);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                    end
                end
            end

            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_id;
                end
                else if ( (SCLK === 1'b0 && !DOPI) || (SCLK===1'b1 && DOPI) ) begin
                    if (OPI_EN) begin
                        SI_OUT_EN    = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                        
                    if( Dummy_Count ) begin
                        Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        if( SOPI )begin
                            Dummy_Count = 2;
                        end
                        else if( DOPI )begin
                            Dummy_Count = CRC_EN ? 5 : 2;
                        end
                        else if( !OPI_EN )begin
                            Dummy_Count = 23;
                        end
                    end

                    if ( SOPI ) begin
                        if( Dummy_Count == 2 ) begin
                            SIO_Reg <= ID_MXIC;
                        end
                        else if( Dummy_Count == 1 ) begin
                            SIO_Reg <= Memory_Type;
                        end
                        else if( Dummy_Count == 0 ) begin
                            SIO_Reg <= Memory_Density;
                        end
                    end
                    else if ( DOPI ) begin
                        if( CRC_EN ) begin
                            if( Dummy_Count/2 == 2 ) begin
                                SIO_Reg <= Dummy_Count[0] ? ID_MXIC : ~ID_MXIC;
                            end
                            else if( Dummy_Count/2 == 1 ) begin
                                SIO_Reg <= Dummy_Count[0] ? Memory_Type : ~Memory_Type;
                            end
                            else if( Dummy_Count/2 == 0 ) begin
                                SIO_Reg <= Dummy_Count[0] ? Memory_Density : ~Memory_Density;
                            end
                        end
                        else begin //!CRC_EN
                            if( Dummy_Count == 2 ) begin
                                SIO_Reg <= ID_MXIC;
                            end
                            else if( Dummy_Count == 1 ) begin
                                SIO_Reg <= Memory_Type;
                            end
                            else if( Dummy_Count == 0 ) begin
                                SIO_Reg <= Memory_Density;
                            end
                        end
                    end
                    else if ( !OPI_EN ) begin
                        SIO_Reg[1]  <= Dummy_ID[Dummy_Count];
                    end          
                
                end
            end  // end forever
        end
    endtask // read_id
    
    /*----------------------------------------------------------------------*/
    /*  Description: define a read CR2 task (RDCR2)                         */
    /*----------------------------------------------------------------------*/
    task read_cr2;
        integer Dummy_Count;
        begin
            Dummy_Count = 8;

            if( !OPI_EN ) begin 
                dummy_cycle(32);
                #0.1;
                if( Address_CR2 !== 0 && Address_CR2 !== 12'h200 && Address_CR2 !== 12'h300 && Address_CR2 !== 12'h500 && 
                    Address_CR2 !== 32'h4000_0000 && Address_CR2 !== 32'h8000_0000 &&
                    Address_CR2 !== 12'h400 && Address_CR2 !== 12'h800 &&
                    Address_CR2 !== 12'hc00 && Address_CR2 !== 12'hd00 && Address_CR2 !== 12'he00 && Address_CR2 !== 12'hf00&&
                    Address_CR2 !== 32'h0400_0800 && Address_CR2 !== 32'h0400_0c00 && Address_CR2 !== 32'h0400_0d00 && 
                    Address_CR2 !== 32'h0400_0e00 && Address_CR2 !== 32'h0400_0f00 ||
                    (WIP && Address_CR2 !== 32'h8000_0000) ) begin
                    disable read_cr2;
                end
            end
            else if( OPI_EN ) begin 
                if( SOPI ) begin
                    dummy_cycle(4);
                    #0.1;
                    if( Address_CR2 !== 0 && Address_CR2 !== 12'h200 && Address_CR2 !== 12'h300 && Address_CR2 !== 12'h500 && 
                        Address_CR2 !== 32'h4000_0000 && Address_CR2 !== 32'h8000_0000 &&
                        Address_CR2 !== 12'h400 && Address_CR2 !== 12'h800 &&
                        Address_CR2 !== 12'hc00 && Address_CR2 !== 12'hd00 && Address_CR2 !== 12'he00 && Address_CR2 !== 12'hf00&&
                        Address_CR2 !== 32'h0400_0800 && Address_CR2 !== 32'h0400_0c00 && Address_CR2 !== 32'h0400_0d00 && 
                        Address_CR2 !== 32'h0400_0e00 && Address_CR2 !== 32'h0400_0f00 ||
                        (WIP && Address_CR2 !== 32'h8000_0000) ) begin
                        disable read_cr2;
                    end
                    dummy_cycle(1);
                    @( negedge SCLK );
                    if( STRDQS )begin
                        DQS_OUT_EN = 1;
                    end

                    dummy_cycle(2);
                    @( negedge SCLK );
                    SI_OUT_EN   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                    SIO_Reg <=  8'hxx;
                    dummy_cycle(1);
                    DQS_TOGGLE_EN = 1'b1;
                end
                else if( DOPI ) begin
                    dummy_cycle(2 + CRC_EN); //for address
                    @( negedge SCLK );
                    #0.1;
                    if( Address_CR2 !== 0 && Address_CR2 !== 12'h200 && Address_CR2 !== 12'h300 && Address_CR2 !== 12'h500 && 
                        Address_CR2 !== 32'h4000_0000 && Address_CR2 !== 32'h8000_0000 &&
                        Address_CR2 !== 12'h400 && Address_CR2 !== 12'h800 &&
                        Address_CR2 !== 12'hc00 && Address_CR2 !== 12'hd00 && Address_CR2 !== 12'he00 && Address_CR2 !== 12'hf00&&
                        Address_CR2 !== 32'h0400_0800 && Address_CR2 !== 32'h0400_0c00 && Address_CR2 !== 32'h0400_0d00 && 
                        Address_CR2 !== 32'h0400_0e00 && Address_CR2 !== 32'h0400_0f00 ||
                        (WIP && Address_CR2 !== 32'h8000_0000) ) begin
                        disable read_cr2;
                    end
                    if ( CRC_ERR ) begin
                        disable read_cr2;
                    end                    

                    dummy_cycle(2);
                    DQS_OUT_EN = 1;
                    if( DDQSPRC ) begin
                        dummy_cycle(1);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    else if( !DDQSPRC ) begin
                        dummy_cycle(2);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                    end
                end
            end

            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_cr2;
                end
                else if ( (SCLK === 1'b0 && !DOPI) || (SCLK===1'b1 && DOPI) ) begin
                    if (OPI_EN) begin
                        SI_OUT_EN    = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;

                    if ( OPI_EN ) begin
                        if( DOPI && CRC_EN ) begin
                            Dummy_Count[0] = Dummy_Count[0] - 1;

                            if( Address_CR2 == 0 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_Reg0 : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 12'h200 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_Reg1 : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 12'h300 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_Reg2 : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 12'h500 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_CRC0_Reg : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 32'h4000_0000 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_CRC1_Reg : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 32'h8000_0000 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_CRC2_Reg : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 12'h400 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_ECS_Reg : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 12'h800 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_ECC_Reg : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 12'hc00 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_ECCA0_Reg : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 12'hd00 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_ECCA1_Reg : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 12'he00 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_ECCA2_Reg : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 12'hf00 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_ECCA3_Reg : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 32'h0400_0800 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_ECC_Reg1 : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 32'h0400_0c00 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_ECCA0_Reg1 : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 32'h0400_0d00 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_ECCA1_Reg1 : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 32'h0400_0e00 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_ECCA2_Reg1 : ~SIO_Reg;
                            end
                            else if( Address_CR2 == 32'h0400_0f00 ) begin
                                SIO_Reg <= Dummy_Count[0] ? CR2_ECCA3_Reg1 : ~SIO_Reg;
                            end                            
                        end
                        else begin
                            if( Address_CR2 == 0 ) begin
                                SIO_Reg <= CR2_Reg0;
                            end
                            else if( Address_CR2 == 12'h200 ) begin
                                SIO_Reg <= CR2_Reg1;
                            end
                            else if( Address_CR2 == 12'h300 ) begin
                                SIO_Reg <= CR2_Reg2;
                            end
                            else if( Address_CR2 == 12'h500 ) begin
                                SIO_Reg <= CR2_CRC0_Reg;
                            end
                            else if( Address_CR2 == 32'h4000_0000 ) begin
                                SIO_Reg <= CR2_CRC1_Reg;
                            end
                            else if( Address_CR2 == 32'h8000_0000 ) begin
                                SIO_Reg <= CR2_CRC2_Reg;
                            end
                            else if( Address_CR2 == 12'h400 ) begin
                                SIO_Reg <= CR2_ECS_Reg;
                            end
                            else if( Address_CR2 == 12'h800 ) begin
                                SIO_Reg <= CR2_ECC_Reg;
                            end
                            else if( Address_CR2 == 12'hc00 ) begin
                                SIO_Reg <= CR2_ECCA0_Reg;
                            end
                            else if( Address_CR2 == 12'hd00 ) begin
                                SIO_Reg <= CR2_ECCA1_Reg;
                            end
                            else if( Address_CR2 == 12'he00 ) begin
                                SIO_Reg <= CR2_ECCA2_Reg;
                            end
                            else if( Address_CR2 == 12'hf00 ) begin
                                SIO_Reg <= CR2_ECCA3_Reg;
                            end
                            else if( Address_CR2 == 32'h0400_0800 ) begin
                                SIO_Reg <= CR2_ECC_Reg1;
                            end
                            else if( Address_CR2 == 32'h0400_0c00 ) begin
                                SIO_Reg <= CR2_ECCA0_Reg1;
                            end
                            else if( Address_CR2 == 32'h0400_0d00 ) begin
                                SIO_Reg <= CR2_ECCA1_Reg1;
                            end
                            else if( Address_CR2 == 32'h0400_0e00 ) begin
                                SIO_Reg <= CR2_ECCA2_Reg1;
                            end
                            else if( Address_CR2 == 32'h0400_0f00 ) begin
                                SIO_Reg <= CR2_ECCA3_Reg1;
                            end                            
                        end
                    end
                    else begin
                        if (Dummy_Count) begin
                            Dummy_Count = Dummy_Count - 1;
                        end
                        else begin
                            Dummy_Count = 7;
                        end


                        if( Address_CR2 == 0 ) begin
                            SIO_Reg[1]  <= CR2_Reg0[Dummy_Count];
                        end
                        else if( Address_CR2 == 12'h200 ) begin
                            SIO_Reg[1]  <= CR2_Reg1[Dummy_Count];
                        end
                        else if( Address_CR2 == 12'h300 ) begin
                            SIO_Reg[1]  <= CR2_Reg2[Dummy_Count];
                        end
                        else if( Address_CR2 == 12'h500 ) begin
                            SIO_Reg[1]  <= CR2_CRC0_Reg[Dummy_Count];
                        end
                        else if( Address_CR2 == 32'h4000_0000 ) begin
                            SIO_Reg[1]  <= CR2_CRC1_Reg[Dummy_Count];
                        end
                        else if( Address_CR2 == 32'h8000_0000 ) begin
                            SIO_Reg[1]  <= CR2_CRC2_Reg[Dummy_Count];
                        end
                        else if( Address_CR2 == 12'h400 ) begin
                            SIO_Reg[1]  <= CR2_ECS_Reg[Dummy_Count];
                        end
                        else if( Address_CR2 == 12'h800 ) begin
                            SIO_Reg[1]  <= CR2_ECC_Reg[Dummy_Count];
                        end
                        else if( Address_CR2 == 12'hc00 ) begin
                            SIO_Reg[1]  <= CR2_ECCA0_Reg[Dummy_Count];
                        end
                        else if( Address_CR2 == 12'hd00 ) begin
                            SIO_Reg[1]  <= CR2_ECCA1_Reg[Dummy_Count];
                        end
                        else if( Address_CR2 == 12'he00 ) begin
                            SIO_Reg[1]  <= CR2_ECCA2_Reg[Dummy_Count];
                        end
                        else if( Address_CR2 == 12'hf00 ) begin
                            SIO_Reg[1]  <= CR2_ECCA3_Reg[Dummy_Count];
                        end
                        else if( Address_CR2 == 32'h0400_0800 ) begin
                            SIO_Reg[1]  <= CR2_ECC_Reg1[Dummy_Count];
                        end
                        else if( Address_CR2 == 32'h0400_0c00 ) begin
                            SIO_Reg[1]  <= CR2_ECCA0_Reg1[Dummy_Count];
                        end
                        else if( Address_CR2 == 32'h0400_0d00 ) begin
                            SIO_Reg[1]  <= CR2_ECCA1_Reg1[Dummy_Count];
                        end
                        else if( Address_CR2 == 32'h0400_0e00 ) begin
                            SIO_Reg[1]  <= CR2_ECCA2_Reg1[Dummy_Count];
                        end
                        else if( Address_CR2 == 32'h0400_0f00 ) begin
                            SIO_Reg[1]  <= CR2_ECCA3_Reg1[Dummy_Count];
                        end
                    end          
                end
            end  // end forever
        end
    endtask // read_cr2


    /*----------------------------------------------------------------------*/
    /*  Description: define a read status task (RDSR)                       */
    /*----------------------------------------------------------------------*/
    task read_status;
        reg [7:0] Status_Reg_Int;
        integer Dummy_Count;
        begin
            Status_Reg_Int = Status_Reg;
            Dummy_Count = 8;

            if( OPI_EN ) begin 
                if( SOPI ) begin
                    dummy_cycle(4);
                    #0.1;
                    if( Address !== 0 ) begin
                        disable read_status;
                    end
                    dummy_cycle(1);
                    @( negedge SCLK );
                    if( STRDQS )begin
                        DQS_OUT_EN = 1;
                    end

                    dummy_cycle(2);
                    @( negedge SCLK );
                    SI_OUT_EN   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                    SIO_Reg <=  8'hxx;
                    dummy_cycle(1);
                    DQS_TOGGLE_EN = 1'b1;
                end
                else if( DOPI ) begin
                    dummy_cycle(2 + CRC_EN);
                    @( negedge SCLK );
                    #0.1;
                    if( Address !== 0 || CRC_ERR ) begin
                        disable read_status;
                    end

                    dummy_cycle(2);
                    DQS_OUT_EN = 1;
                    if( DDQSPRC ) begin
                        dummy_cycle(1);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    else if( !DDQSPRC ) begin
                        dummy_cycle(2);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                    end
                end
            end

            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_status;
                end
                else if ( (SCLK === 1'b0 && !DOPI) || (SCLK===1'b1 && DOPI) ) begin
                    if (OPI_EN) begin
                        SI_OUT_EN    = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;

                    if ( OPI_EN ) begin
                        Status_Reg_Int = Status_Reg;

                        if( DOPI && CRC_EN ) begin
                            Dummy_Count[0] = Dummy_Count[0] - 1;
                            SIO_Reg <= Dummy_Count[0] ? Status_Reg_Int : ~SIO_Reg;
                        end
                        else begin
                            SIO_Reg <= Status_Reg_Int;
                        end
                    end
                    else begin
                        if (Dummy_Count) begin
                            Dummy_Count = Dummy_Count - 1;
                        end
                        else begin
                            Dummy_Count = 7;
                            Status_Reg_Int = Status_Reg;
                        end
                        SIO_Reg[1]  <= Status_Reg_Int[Dummy_Count];
                    end          
                end
            end  // end forever
        end
    endtask // read_status

    /*----------------------------------------------------------------------*/
    /*  Description: define a read configuration register task (RDCR)       */
    /*----------------------------------------------------------------------*/
    task read_cr;
        integer Dummy_Count;
        begin
            Dummy_Count = 8;

            if( OPI_EN ) begin 
                if( SOPI ) begin
                    dummy_cycle(4);
                    #0.1;
                    if( Address !== 1 ) begin
                        disable read_cr;
                    end
                    dummy_cycle(1);
                    @( negedge SCLK );
                    if( STRDQS )begin
                        DQS_OUT_EN = 1;
                    end
                    dummy_cycle(2);
                    @( negedge SCLK );
                    SI_OUT_EN   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                    SIO_Reg <=  8'hxx;
                    dummy_cycle(1);
                    DQS_TOGGLE_EN = 1'b1;
                end
                else if( DOPI ) begin
                    dummy_cycle(2 + CRC_EN); //for address
                    @( negedge SCLK );
                    #0.1;
                    if( Address !== 1 || CRC_ERR ) begin
                        disable read_cr;
                    end

                    dummy_cycle(2);
                    DQS_OUT_EN = 1;
                    if( DDQSPRC ) begin
                        dummy_cycle(1);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    else if( !DDQSPRC ) begin
                        dummy_cycle(2);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                    end
                end
            end


            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_cr;
                end
                else if ( (SCLK === 1'b0 && !DOPI) || (SCLK===1'b1 && DOPI) ) begin
                    if (OPI_EN) begin
                        SI_OUT_EN    = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;

                    if ( OPI_EN ) begin

                        if( DOPI && CRC_EN ) begin
                            Dummy_Count[0] = Dummy_Count[0] - 1;
                            SIO_Reg <= Dummy_Count[0] ? CR : ~SIO_Reg;
                        end
                        else begin
                            SIO_Reg <= CR;
                        end
                    end
                    else begin
                        if (Dummy_Count) begin
                            Dummy_Count = Dummy_Count - 1;
                        end
                        else begin
                            Dummy_Count = 7;
                        end
                        SIO_Reg[1]  <= CR[Dummy_Count];
                    end          
                end
            end  // end forever
        end
    endtask // read_cr

    /*----------------------------------------------------------------------*/
    /*  Description: define a write status OPI task                         */
    /*----------------------------------------------------------------------*/
    task write_status_opi;
    reg [7:0] Status_Reg_Up;
    reg [7:0] CR_Up;
        begin
          if (Address === 0 && !DOPI) begin
            Status_Reg_Up = SI_Reg[7:0] ;
          end
          else if (Address === 1 && !DOPI) begin
            CR_Up = SI_Reg[7:0] ;
          end
          else if (Address === 0 && DOPI) begin
            Status_Reg_Up = CRC_EN ? SI_Reg[31:24] : SI_Reg[15:8] ;
          end
          else if (Address === 1 && DOPI) begin
            CR_Up = CRC_EN ? SI_Reg[31:24] : SI_Reg[15:8] ;
          end
          else begin
            Status_Reg[1]   = 1'b0;
            WRSR_OPI_Mode   = 1'b0;
            disable write_status_opi;
          end

          if (Address == 0) begin       //WRSR
                tWRSR = tW;
                Secur_Reg[5] = 1'b0;
                //SRWD:Status Register Write Protect
                Status_Reg[0]   = 1'b1;
                #tWRSR;
                if (Secur_Reg[7] == 1'b0) begin
                    Status_Tmp_Reg[5:2] = Status_Reg_Up[5:2];
                end
                Status_Reg[5:2] =  Status_Tmp_Reg[5:2];
                //WIP : write in process Bit
                Status_Reg[0]   = 1'b0;
                //WEL:Write Enable Latch
                Status_Reg[1]   = 1'b0;
                WRSR_OPI_Mode   = 1'b0;
          end    
          else if (Address == 1) begin  //WRCR
                tWRSR = tW;
                if ((CR_Up[2:0] == CR[2:0]) && (CR_Up[4] == CR[4]) && ((CR_Up[3] == 1 ) && (CR[3] == 0))) begin
                        tWRSR = tBP;
                end                
                Secur_Reg[5] = 1'b0;
                //SRWD:Status Register Write Protect
                Status_Reg[0]   = 1'b1;
                #tWRSR;
                CR[4]           =  CR_Up[4];
                CR[3]           =  CR[3] | CR_Up[3];
                CR[2:0]         =  CR_Up[2:0];
                //WIP : write in process Bit
                Status_Reg[0]   = 1'b0;
                //WEL:Write Enable Latch
                Status_Reg[1]   = 1'b0;
                WRSR_OPI_Mode   = 1'b0;
          end
        end
    endtask // write_status_opi

    /*----------------------------------------------------------------------*/
    /*  Description: define a write configuration register2 task            */
    /*----------------------------------------------------------------------*/
    task automatic write_cr2;
        reg [7:0] Reg_Up;
        begin
          if ( DOPI ) begin
            Reg_Up = CRC_EN ? SI_Reg[31:24] : SI_Reg[15:8] ;
          end
          else if (!DOPI) begin
            Reg_Up = SI_Reg[7:0] ;
          end
                
          if ( Address_CR2 == 0 ) begin       
                if( (CR2_Reg0[0] || Reg_Up[0]) && (CR2_Reg0[1] || Reg_Up[1]) )begin
                    $display( $time, " OPI and DOPI can't be enabled at the same time"  );
                end
                else begin
                Status_Reg[0] = 1'b1;
                #tW2V;
                CR2_Reg0[1:0] = Reg_Up[1:0];
                Status_Reg[0] = 1'b0;
                end
          end    
          else if ( Address_CR2 == 12'h200 ) begin 
                Status_Reg[0] = 1'b1;
                #tW2V;
                CR2_Reg1[1:0] = Reg_Up[1:0];
                Status_Reg[0] = 1'b0;
          end
          else if ( Address_CR2 == 12'h300 ) begin
                Status_Reg[0] = 1'b1;
                #tW2V;
                CR2_Reg2[2:0] = Reg_Up[2:0];
                Status_Reg[0] = 1'b0;
          end
          else if ( Address_CR2 == 12'h500 ) begin  
                Status_Reg[0] = 1'b1;
                #tW2V;
                CR2_CRC0_Reg[0] = Reg_Up[0];
                CR2_CRC0_Reg[6:4] = Reg_Up[6:4];

                if ( CR2_CRC0_Reg[0] == 1'b0 ) begin
                    Prea_Reg[15:0]     = 16'b0011_0100_1001_1010;
                    Prea_Reg_DQ3[15:0] = 16'b0011_0101_0001_0100;
                end
                else if ( CR2_CRC0_Reg[0] == 1'b1 ) begin
                    Prea_Reg[15:0]     = 16'b0101_0101_0101_0101;
                    Prea_Reg_DQ3[15:0] = 16'b0101_0101_0101_0101;
                end
                Status_Reg[0] = 1'b0;
          end
          else if ( Address_CR2 == 32'h4000_0000 ) begin  
                Secur_Reg[5] = 1'b0;
                Status_Reg[0] = 1'b1;
                #tW2N;
                CR2_CRC1_Reg[3]   = Reg_Up[3] & CR2_CRC1_Reg[3];  //CRCENB
                if( (!CR2_CRC1_Reg[0] || !Reg_Up[0]) && (!CR2_CRC1_Reg[1] || !Reg_Up[1]) )begin
                Secur_Reg[5] = 1'b1;
                    $display( $time, " OPI and DOPI can't be enabled at the same time"  );
                end
                else begin
                    CR2_CRC1_Reg[1:0] = Reg_Up[1:0] & CR2_CRC1_Reg[1:0]; //SOPI and DOPI default value
                end
                Status_Reg[0] = 1'b0;
          end
          else if ( Address_CR2 == 32'h8000_0000 && Reg_Up == 8'h00 ) begin  
                Status_Reg[0] = 1'b1;
                #tW2V;
                CR2_CRC2_Reg[7:0] = 8'h00;
                Status_Reg[0] = 1'b0;
          end
          else if ( Address_CR2 == 12'h400 ) begin  
                Status_Reg[0] = 1'b1;
                #tW2V;
                CR2_ECS_Reg[1:0]  = Reg_Up[1:0];
                Status_Reg[0] = 1'b0;
          end
          else if ( ( Address_CR2 == 12'h800 || Address_CR2 == 32'h0400_0800) && Reg_Up == 8'h00 ) begin  
                Status_Reg[0] = 1'b1;
                #tW2V;
                CR2_ECC_Reg[7:0]   = 8'b0000_0000;
                CR2_ECCA0_Reg[7:0] = 8'b0000_0000;
                CR2_ECCA1_Reg[7:0] = 8'b0000_0000;
                CR2_ECCA2_Reg[7:0] = 8'b0000_0000;
                CR2_ECCA3_Reg[7:0] = 8'b0000_0000;
                CR2_ECC_Reg1[7:0]   = 8'b0000_0000;
                CR2_ECCA0_Reg1[7:0] = 8'b0000_0000;
                CR2_ECCA1_Reg1[7:0] = 8'b0000_0000;
                CR2_ECCA2_Reg1[7:0] = 8'b0000_0000;
                CR2_ECCA3_Reg1[7:0] = 8'b0000_0000;
                Status_Reg[0] = 1'b0;
          end
          
          if ( Address_CR2 !== 32'h8000_0000) begin
              Status_Reg[1] = 1'b0;
          end
          WRCR2_Mode   = 1'b0;

        end
    endtask // write_cr2


    /*----------------------------------------------------------------------*/
    /*  Description: define a write status task                             */
    /*----------------------------------------------------------------------*/
    task write_status;
    reg [7:0] Status_Reg_Up;
    reg [7:0] CR_Up;
        begin
            //$display( $time, " Old Status Register = %b", Status_Reg );
          if (WRSR_Mode == 1'b0 && WRSR2_Mode == 1'b1) begin
            Status_Reg_Up = SI_Reg[15:8] ;
            CR_Up = SI_Reg [7:0];
          end
          else if (WRSR_Mode == 1'b1 && WRSR2_Mode == 1'b0) begin
            Status_Reg_Up = SI_Reg[7:0] ;
          end

          if (WRSR_Mode == 1'b1 && WRSR2_Mode == 1'b0) begin       //for one byte WRSR write
                tWRSR = tW;
                Secur_Reg[5] = 1'b0;
                //SRWD:Status Register Write Protect
                Status_Reg[0]   = 1'b1;
                #tWRSR;
                if (Secur_Reg[7] == 1'b0) begin
                    Status_Tmp_Reg[5:2] = Status_Reg_Up[5:2];
                end
                Status_Reg[5:2] =  Status_Tmp_Reg[5:2];
                //WIP : write in process Bit
                Status_Reg[0]   = 1'b0;
                //WEL:Write Enable Latch
                Status_Reg[1]   = 1'b0;
                WRSR_Mode       = 1'b0;
          end    

          else if (WRSR_Mode == 1'b0 && WRSR2_Mode == 1'b1) begin  //for two byte WRSR write
                tWRSR = tW;
                Secur_Reg[5] = 1'b0;
                //SRWD:Status Register Write Protect
                Status_Reg[0]   = 1'b1;
                #tWRSR;
                CR[4]           =  CR_Up[4];
                CR[3]           =  CR[3] | CR_Up[3];
                CR[2:0]         =  CR_Up[2:0];
                if (Secur_Reg[7] == 1'b0) begin
                    Status_Tmp_Reg[5:2] = Status_Reg_Up[5:2];
                end
                Status_Reg[5:2] =  Status_Tmp_Reg[5:2];
                //WIP : write in process Bit
                Status_Reg[0]   = 1'b0;
                //WEL:Write Enable Latch
                Status_Reg[1]   = 1'b0;
                WRSR2_Mode      = 1'b0;
          end
        end
    endtask // write_status
   
  
    /*----------------------------------------------------------------------*/
    /*  Description: define a fast boot read data task                      */
    /*----------------------------------------------------------------------*/
    task fast_boot_read;
        integer Dummy_Count, Tmp_Int;
        reg  [7:0]  OUT_Buf;
        reg         CRC_Out_En;
        begin

            if(OPI_EN) Dummy_Count = 1;
            else       Dummy_Count = 8;

            CRC_Out_En = 1'b0;

           if ( !OPI_EN ) begin
                dummy_cycle(12);
            end
            else begin
                if ( SOPI ) begin
                    dummy_cycle(1);
                    @( negedge SCLK );
                    if( STRDQS )begin
                        DQS_OUT_EN = 1;
                    end

                    if ( FB_Reg[2:1] == 2'b00 )
                            dummy_cycle(10-1-1);
                    else if ( FB_Reg[2:1] == 2'b01 )
                            dummy_cycle(14-1-1);
                    else if ( FB_Reg[2:1] == 2'b10 )
                            dummy_cycle(16-1-1);
                    else
                            dummy_cycle(20-1-1);

                    @ (negedge SCLK);
                    SO_OUT_EN   = 1'b1;
                    SI_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN    = 1'b0;
                    SI_IN_EN    = 1'b0;
                    OPI_IN_EN   = 1'b0;
                    Read_Mode   = 1'b1;
                    SIO_Reg[7:0] <=  8'hxx;
                    dummy_cycle(1);
                    DQS_TOGGLE_EN = 1'b1;
                end
                else if ( DOPI ) begin
                    dummy_cycle(2);
                    DQS_OUT_EN = 1;

                    if ( FB_Reg[2:1] == 2'b00 )
                            dummy_cycle(10-2-DDQSPRC);
                    else if ( FB_Reg[2:1] == 2'b01 )
                            dummy_cycle(14-2-DDQSPRC);
                    else if ( FB_Reg[2:1] == 2'b10 )
                            dummy_cycle(16-2-DDQSPRC);
                    else
                            dummy_cycle(20-2-DDQSPRC);

                    SO_OUT_EN   = 1'b1;
                    SI_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN    = 1'b0;
                    SI_IN_EN    = 1'b0;
                    OPI_IN_EN   = 1'b0;
                    Read_Mode   = 1'b1;
                    SIO_Reg[7:0] <=  8'hxx;

                    dummy_cycle(DDQSPRC);
                    if( DDQSPRC ) begin
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    @ (negedge SCLK);
                end
            end

            Address = { FB_Reg[31:4], 4'b0000 };
            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable fast_boot_read;
                end 
                else begin
                    if (OPI_EN) begin
                        SI_OUT_EN    = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                    Read_Mode = 1'b1;
                    RD_Mode   = 1'b1;

                    if ( !OPI_EN && SCLK==1'b0 ) begin

                        if ( Dummy_Count ) begin
                            read_array(Address, OUT_Buf);

                            Dummy_Count = Dummy_Count - 1;
                            SIO_Reg[1] <= OUT_Buf[Dummy_Count];
                        end
                        else begin
                            Address = Address + 1;
                            read_array(Address, OUT_Buf);

                            Dummy_Count = 7;
                            SIO_Reg[1] <= OUT_Buf[Dummy_Count];
                        end

                    end //if ( !OPI_EN && SCLK==1'b0 )
                    else if ( OPI_EN ) begin
                        DQS_TOGGLE_EN = 1'b1;

                        if ( SOPI && SCLK==1'b0 ) begin
                            read_array(Address, OUT_Buf);
                            SIO_Reg[7:0] <= OUT_Buf[7:0];

                            Address = Address + 1;
                        end
                        else if ( DOPI ) begin
                            if( CRC_Out_En ) begin
                                if( Dummy_Count[0] == 1 )
                                    SIO_Reg[7:0] <= CRC[7:0];
                                else begin
                                    SIO_Reg[7:0] <= CRCBEN ? ~CRC[7:0] : CRC[7:0];
                                    crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                end
                            end
                            else begin
                                read_array( {Address[A_MSB:1],Dummy_Count[0]} , OUT_Buf);
                                SIO_Reg[7:0] <=         OUT_Buf[7:0];

                                if( CRC_EN )
                                    crc_calculation(OUT_Buf[7:0], 1, CRC[7:0]);
                            end

                            if ( Dummy_Count[0] == 0 ) begin
                                if( CRC_EN && !CRC_Out_En && Address[3:1] == 3'b111) begin //CRC_CYC is default value 00
                                    CRC_Out_En = 1;
                                end
                                else if ( CRC_Out_En ) begin
                                    CRC_Out_En = 0;
                                end

                                if( !CRC_Out_En ) Address = Address + 2;
                            end

                            Dummy_Count[0] = Dummy_Count[0] - 1;
                        end
                    end //else if ( OPI_EN )
                end
            end  // end forever
        end   
    endtask // fast_boot_read


    /*----------------------------------------------------------------------*/
    /*  Description: define a read data task                                */
    /*               03 AD1 AD2 AD3 X                                       */
    /*----------------------------------------------------------------------*/
    task read_1xio;
        integer Dummy_Count;
        reg  [7:0] OUT_Buf;
        begin
            Dummy_Count = 8;
            if ( ADD_3B_Mode ) begin
                dummy_cycle(24); //for address
            end
            else begin
                dummy_cycle(32); //for address
            end
            #0.1; 
            read_array(Address, OUT_Buf);
            forever begin
                @ ( negedge SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_1xio;
                end 
                else  begin 
                    Read_Mode   = 1'b1;
                    RD_Mode     = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    SI_IN_EN    = 1'b0;
                    if ( Dummy_Count ) begin
                        Dummy_Count = Dummy_Count - 1;
                        SIO_Reg[1] <= OUT_Buf[Dummy_Count];
                    end
                    else begin
                        Address = Address + 1;

                        load_address(Address);
                        read_array(Address, OUT_Buf);
                        Dummy_Count = 7 ;
                        SIO_Reg[1] <= OUT_Buf[Dummy_Count];
                    end
                end 
            end  // end forever
        end   
    endtask // read_1xio

    /*----------------------------------------------------------------------*/
    /*  Description: define a fast read data task                           */
    /*               0B AD1 AD2 AD3 X                                       */
    /*----------------------------------------------------------------------*/
    task fastread_1xio;
        integer Dummy_Count, Tmp_Int;
        reg  [7:0]       OUT_Buf;
        begin
            Dummy_Count = 8;
            if ( ADD_3B_Mode || SFDP_Mode ) begin
                dummy_cycle(24); //for address
            end
            else begin
                dummy_cycle(32); //for address
            end

            fork
                begin
                    dummy_cycle(8); //for dummy cycle

                    Prea_OUT_EN1 <= #1 1'b0;
                    read_array(Address, OUT_Buf);
                    forever begin
                        @ ( negedge SCLK or posedge CS_INT );
                        if ( CS_INT == 1'b1 ) begin
                            disable fastread_1xio;
                        end 
                        else begin 
                            Read_Mode = 1'b1;
                            RD_Mode   = 1'b1;
                            SO_OUT_EN = 1'b1;
                            SI_IN_EN  = 1'b0;
                            if ( Dummy_Count ) begin
                                Dummy_Count = Dummy_Count - 1;
                                SIO_Reg[1] <= OUT_Buf[Dummy_Count];
                            end
                            else begin
                                Address = Address + 1;

                                load_address(Address);

                                read_array(Address, OUT_Buf);
                                Dummy_Count = 7 ;
                                SIO_Reg[1] <= OUT_Buf[Dummy_Count];
                            end
                        end    
                    end  // end forever
                end
                begin
                    if ( CR[4] ) begin
                        dummy_cycle_prea(2);
                        Prea_OUT_EN1 = 1'b1;
                        preamble_bit_out;
                    end
                end
            join
        end   
    endtask // fastread_1xio

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Write protection select                        */
    /*----------------------------------------------------------------------*/
    task write_protection_select;
        begin
            Secur_Reg [5] = 1'b0;
            WR_WPSEL_Mode = 1'b1;
            Status_Reg[0] = 1'b1;
            #tBP;
            WR_WPSEL_Mode = 1'b0;
            Secur_Reg[7]  = 1'b1;
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
            Status_Reg[7] = 1'b0;
        end
    endtask // write_protection_select

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Write Lock Register                            */
    /*----------------------------------------------------------------------*/
    task write_lock_register;
        reg [7:0] Lock_Reg_Up;
        begin
            if ( OPI_EN && Address !== 0 ) begin
                disable write_lock_register;
            end

            Secur_Reg[5] = 1'b0;
            if(DOPI)
                Lock_Reg_Up [7:0] = CRC_EN ? SI_Reg [31:24] : SI_Reg [15:8];
            else
                Lock_Reg_Up [7:0] = SI_Reg [7:0];
`ifdef MODEL_CODE_00
            if ( Lock_Reg[6] == 1'b0 || Lock_Reg[2] == 1'b0 ) begin
                Secur_Reg[5] = 1'b1;               
            end
            else begin            
                Status_Reg[0] = 1'b1;
                #tPP;
                Lock_Reg[2] = Lock_Reg_Up[2] & Lock_Reg[2];
                Lock_Reg[6] = Lock_Reg_Up[6] & Lock_Reg[6];
                if ( Lock_Reg[2] == 1'b0 ) begin
                        Lock_Reg[6] = 1'b0;
                end
            end
`else
            Status_Reg[0] = 1'b1;
            #tPP;
            Lock_Reg[6] = Lock_Reg_Up[6] & Lock_Reg[6];
`endif    
            //WIP : write in process Bit
            Status_Reg[0] = 1'b0;
            //WEL:Write Enable Latch
            Status_Reg[1] = 1'b0;
            WRLR_Mode = 1'b0;           
        end    
    endtask // write_lock_register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute program SPB register                           */
    /*----------------------------------------------------------------------*/
    task program_spb_register;
        reg [A_MSB:0] Address_Int;
        reg  [Block_MSB:0] Block;
        begin
            Address_Int = Address;
            Secur_Reg[5] = 1'b0;
            if ( SPBLKDN == 1'b0 ) begin
                //WIP : write in process Bit
                Status_Reg[0] = 1'b0;
                //WEL:Write Enable Latch
                Status_Reg[1] = 1'b0;           
                Secur_Reg[5] = 1'b1;
                WRSPB_Mode = 1'b0;
            end
            else begin
                    Block  =  Address_Int [A_MSB:16];
                    Status_Reg[0] = 1'b1;
                    #tBP;

                    if (Block[Block_MSB:0] == 0) begin 
                        SPB_Reg_BOT[Address_Int[15:12]] = 1'b1;
                    end
                    else if (Block[Block_MSB:0] == Block_NUM-1) begin 
                        SPB_Reg_TOP[Address_Int[15:12]] = 1'b1;
                    end
                    else 
                        SPB_Reg[Block] = 1'b1;
                    //WIP : write in process Bit
                    Status_Reg[0] = 1'b0;
                    //WEL:Write Enable Latch
                    Status_Reg[1] = 1'b0;
                    Secur_Reg[5] = 1'b0;
                    WRSPB_Mode = 1'b0;
            end
        end
    endtask // program_spb_register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute erase SPB register                             */
    /*----------------------------------------------------------------------*/
    task erase_spb_register;
        begin
            Secur_Reg[6] = 1'b0;
            if ( SPBLKDN == 1'b0 ) begin
                //WIP : write in process Bit
                Status_Reg[0] = 1'b0;
                //WEL:Write Enable Latch
                Status_Reg[1] = 1'b0;
                Secur_Reg[6] = 1'b1;
                ESSPB_Mode = 1'b0;
            end
            else begin
                    Status_Reg[0] = 1'b1;
                    #tSE;
                    for ( i = 0; i <= 15; i = i + 1 ) begin
                        SPB_Reg_TOP[i] = 1'b0;
                        SPB_Reg_BOT[i] = 1'b0;
                    end
                    for ( i = 1; i <= Block_NUM - 2; i = i + 1 ) begin
                        SPB_Reg[i] = 1'b0;
                    end
                    //WIP : write in process Bit
                    Status_Reg[0] = 1'b0;
                    //WEL:Write Enable Latch
                    Status_Reg[1] = 1'b0;
                    Secur_Reg[6] = 1'b0;
                    ESSPB_Mode = 1'b0;
            end
        end
    endtask // erase_spb_register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute write DPB register                             */
    /*----------------------------------------------------------------------*/
    task write_dpb_register;
        reg [A_MSB:0] Address_Int;
        reg  [Block_MSB:0] Block;          
        reg  [7:0] DPB_Reg_Up;
        begin
            Address_Int = Address;
            if ( DOPI ) begin
              DPB_Reg_Up = CRC_EN ? SI_Reg[31:24] : SI_Reg[15:8] ;
            end
            else if (!DOPI) begin
              DPB_Reg_Up = SI_Reg[7:0] ;
            end
            Block  =  Address_Int [A_MSB:16];
            if (Block[Block_MSB:0] == 0) begin
                if ( DPB_Reg_Up[0] == 1'b1 ) 
                        DPB_Reg_BOT[Address_Int[15:12]] = 1'b1;
                else
                        DPB_Reg_BOT[Address_Int[15:12]] = 1'b0;
            end
            else if (Block[Block_MSB:0] == Block_NUM-1) begin
                if ( DPB_Reg_Up[0] == 1'b1 ) 
                        DPB_Reg_TOP[Address_Int[15:12]] = 1'b1;
                else
                        DPB_Reg_TOP[Address_Int[15:12]] = 1'b0;
            end
            else begin
                if ( DPB_Reg_Up[0] == 1'b1 ) 
                        DPB_Reg[Block] = 1'b1;
                else
                        DPB_Reg[Block] = 1'b0;
            end
            //WEL:Write Enable Latch
            Status_Reg[1] = 1'b0;
            WRDPB_Mode = 1'b0;
        end
    endtask // write_dpb_register 

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Read Lock Register                             */
    /*----------------------------------------------------------------------*/
    task read_lock_register;
        reg [7:0] Dummy_LR;
        integer Dummy_Count;
        begin
            Dummy_Count = 8;
            Dummy_LR = Lock_Reg[7:0];

            if( OPI_EN ) begin 
                if( SOPI ) begin
                    dummy_cycle(4); //for address
                    #0.1;
                    if ( Address !== 0 ) begin
                        disable read_lock_register;
                    end

                    dummy_cycle(1);
                    @( negedge SCLK );
                    if( STRDQS )begin
                        DQS_OUT_EN = 1;
                    end
                    dummy_cycle(2);
                    @( negedge SCLK );
                    SI_OUT_EN   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                    SIO_Reg <=  8'hxx;
                    dummy_cycle(1);
                    DQS_TOGGLE_EN = 1'b1;
                end
                else if( DOPI ) begin
                    dummy_cycle(2 + CRC_EN); //for address
                    @( negedge SCLK );
                    #0.1;
                    if ( Address !== 0 ) begin
                        disable read_lock_register;
                    end
                    if ( CRC_ERR ) begin
                        disable read_lock_register;
                    end

                    dummy_cycle(2);
                    DQS_OUT_EN = 1;
                    if( DDQSPRC ) begin
                        dummy_cycle(1);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    else if( !DDQSPRC ) begin
                        dummy_cycle(2);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                    end
                end
            end // if( OPI_EN )

            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_lock_register;
                end
                else if ( (SCLK === 1'b0 && !DOPI) || (SCLK===1'b1 && DOPI) ) begin
                    if (OPI_EN) begin
                        SI_OUT_EN    = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;

                    if ( OPI_EN ) begin
                        if( DOPI && CRC_EN ) begin
                            Dummy_Count[0] = Dummy_Count[0] - 1;
                            SIO_Reg <= Dummy_Count[0] ? Dummy_LR : ~Dummy_LR;
                        end
                        else begin
                            SIO_Reg <= Dummy_LR;
                        end
                    end
                    else begin
                        if (Dummy_Count) begin
                            Dummy_Count = Dummy_Count - 1;
                        end
                        else begin
                            Dummy_Count = 7;
                        end
                        SIO_Reg[1]  <= Dummy_LR[Dummy_Count];
                    end          
                end
            end  // end forever
        end
    endtask // read_lock_register


    /*----------------------------------------------------------------------*/
    /*  Description: Execute Read SPB Register                              */
    /*----------------------------------------------------------------------*/
    task read_spb_register;
        reg  [Block_MSB:0] Block;          
        reg [7:0] SPB_Out;
        integer Dummy_Count;
        begin
            Dummy_Count = 8;

            if( !OPI_EN ) begin 
                dummy_cycle(32);
            end
            else if( OPI_EN ) begin 
                if( SOPI ) begin
                    dummy_cycle(4); //for address

                    dummy_cycle(1);
                    @( negedge SCLK );
                    if( STRDQS )begin
                        DQS_OUT_EN = 1;
                    end
                    case(DMCYC[2:0])
                        3'd0: dummy_cycle(20-1-1);
                        3'd1: dummy_cycle(18-1-1);
                        3'd2: dummy_cycle(16-1-1);
                        3'd3: dummy_cycle(14-1-1);
                        3'd4: dummy_cycle(12-1-1);
                        3'd5: dummy_cycle(10-1-1);
                        3'd6: dummy_cycle(8 -1-1);
                        3'd7: dummy_cycle(6 -1-1);
                        default: dummy_cycle(20-1-1);
                    endcase
                    @( negedge SCLK );
                    SI_OUT_EN   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                    SIO_Reg <=  8'hxx;
                    dummy_cycle(1);
                    DQS_TOGGLE_EN = 1'b1;
                end
                else if( DOPI ) begin
                    dummy_cycle(2 + CRC_EN); //for address

                    #0.1;
                    if ( CRC_ERR ) begin
                        disable read_spb_register;
                    end

                    dummy_cycle(2);
                    DQS_OUT_EN = 1;
                    if( DDQSPRC ) begin
                        case(DMCYC[2:0])
                            3'd0: dummy_cycle(20-2-1);
                            3'd1: dummy_cycle(18-2-1);
                            3'd2: dummy_cycle(16-2-1);
                            3'd3: dummy_cycle(14-2-1);
                            3'd4: dummy_cycle(12-2-1);
                            3'd5: dummy_cycle(10-2-1);
                            3'd6: dummy_cycle(8 -2-1);
                            3'd7: dummy_cycle(6 -2-1);
                            default: dummy_cycle(20-2-1);
                        endcase
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    else if( !DDQSPRC ) begin
                        case(DMCYC[2:0])
                            3'd0: dummy_cycle(20-2);
                            3'd1: dummy_cycle(18-2);
                            3'd2: dummy_cycle(16-2);
                            3'd3: dummy_cycle(14-2);
                            3'd4: dummy_cycle(12-2);
                            3'd5: dummy_cycle(10-2);
                            3'd6: dummy_cycle(8 -2);
                            3'd7: dummy_cycle(6 -2);
                            default: dummy_cycle(20-2);
                        endcase
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                    end
                end
            end

            #1;
            Block =  Address[A_MSB:16];
            if (Block[Block_MSB:0] == 0) begin
                SPB_Out =  {8{SPB_Reg_BOT[Address[15:12]]}};
            end
            else if (Block[Block_MSB:0] == Block_NUM-1) begin
                SPB_Out =  {8{SPB_Reg_TOP[Address[15:12]]}};
            end
            else begin
                SPB_Out =  {8{SPB_Reg[Block]}};
            end

            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_spb_register;
                end
                else if ( (SCLK === 1'b0 && !DOPI) || (SCLK===1'b1 && DOPI) ) begin
                    if (OPI_EN) begin
                        SI_OUT_EN    = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;

                    if ( OPI_EN ) begin
                        if( DOPI && CRC_EN ) begin
                            Dummy_Count[0] = Dummy_Count[0] - 1;
                            SIO_Reg <= Dummy_Count[0] ? SPB_Out : ~SPB_Out;
                        end
                        else begin
                            SIO_Reg <= SPB_Out;
                        end
                    end
                    else begin
                        if (Dummy_Count) begin
                            Dummy_Count = Dummy_Count - 1;
                        end
                        else begin
                            Dummy_Count = 7;
                        end
                        SIO_Reg[1]  <= SPB_Out[Dummy_Count];
                    end          
                end
            end  // end forever
        end   
     endtask // read_spb_register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Read DPB Register                              */
    /*----------------------------------------------------------------------*/
    task read_dpb_register;
        reg  [Block_MSB:0] Block;          
        reg [7:0] DPB_Out;
        integer Dummy_Count;
        begin
            Dummy_Count = 8;

            if( !OPI_EN ) begin 
                dummy_cycle(32);
            end
            else if( OPI_EN ) begin 
                if( SOPI ) begin
                    dummy_cycle(4); //for address

                    dummy_cycle(1);
                    @( negedge SCLK );
                    if( STRDQS )begin
                        DQS_OUT_EN = 1;
                    end
                    case(DMCYC[2:0])
                        3'd0: dummy_cycle(20-1-1);
                        3'd1: dummy_cycle(18-1-1);
                        3'd2: dummy_cycle(16-1-1);
                        3'd3: dummy_cycle(14-1-1);
                        3'd4: dummy_cycle(12-1-1);
                        3'd5: dummy_cycle(10-1-1);
                        3'd6: dummy_cycle(8 -1-1);
                        3'd7: dummy_cycle(6 -1-1);
                        default: dummy_cycle(20-1-1);
                    endcase
                    @( negedge SCLK );
                    SI_OUT_EN   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                    SIO_Reg <=  8'hxx;
                    dummy_cycle(1);
                    DQS_TOGGLE_EN = 1'b1;
                end
                else if( DOPI ) begin
                    dummy_cycle(2 + CRC_EN); //for address

                    #0.1;
                    if ( CRC_ERR ) begin
                        disable read_dpb_register;
                    end

                    dummy_cycle(2);
                    DQS_OUT_EN = 1;
                    if( DDQSPRC ) begin
                        case(DMCYC[2:0])
                            3'd0: dummy_cycle(20-2-1);
                            3'd1: dummy_cycle(18-2-1);
                            3'd2: dummy_cycle(16-2-1);
                            3'd3: dummy_cycle(14-2-1);
                            3'd4: dummy_cycle(12-2-1);
                            3'd5: dummy_cycle(10-2-1);
                            3'd6: dummy_cycle(8 -2-1);
                            3'd7: dummy_cycle(6 -2-1);
                            default: dummy_cycle(20-2-1);
                        endcase
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    else if( !DDQSPRC ) begin
                        case(DMCYC[2:0])
                            3'd0: dummy_cycle(20-2);
                            3'd1: dummy_cycle(18-2);
                            3'd2: dummy_cycle(16-2);
                            3'd3: dummy_cycle(14-2);
                            3'd4: dummy_cycle(12-2);
                            3'd5: dummy_cycle(10-2);
                            3'd6: dummy_cycle(8 -2);
                            3'd7: dummy_cycle(6 -2);
                            default: dummy_cycle(20-2);
                        endcase
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                    end
                end
            end

            #1;
            Block =  Address[A_MSB:16];
            if (Block[Block_MSB:0] == 0) begin
                DPB_Out =  {8{DPB_Reg_BOT[Address[15:12]]}};
            end
            else if (Block[Block_MSB:0] == Block_NUM-1) begin
                DPB_Out =  {8{DPB_Reg_TOP[Address[15:12]]}};
            end
            else begin
                DPB_Out =  {8{DPB_Reg[Block]}};
            end
            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                        disable read_dpb_register;
                end 
                else if ( (SCLK === 1'b0 && !DOPI) || (SCLK===1'b1 && DOPI) ) begin
                    if (OPI_EN) begin
                        SI_OUT_EN    = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;

                    if ( OPI_EN ) begin
                        if( DOPI && CRC_EN ) begin
                            Dummy_Count[0] = Dummy_Count[0] - 1;
                            SIO_Reg <= Dummy_Count[0] ? DPB_Out : ~DPB_Out;
                        end
                        else begin
                            SIO_Reg <= DPB_Out;
                        end
                    end
                    else begin
                        if (Dummy_Count) begin
                            Dummy_Count = Dummy_Count - 1;
                        end
                        else begin
                            Dummy_Count = 7;
                        end
                        SIO_Reg[1]  <= DPB_Out[Dummy_Count];
                    end          
                end
            end  // end forever
        end   
     endtask // read_dpb_register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Write Fast Boot Register                       */
    /*----------------------------------------------------------------------*/
    task write_FB_register;
        reg [31:0] FB_Reg_Up;
        reg [31:0] FB_Reg_Old;
        begin
            if ( OPI_EN && Address !== 0 ) begin
                disable write_FB_register;
            end

            FB_Reg_Up[31:0] = FB_Tmp_Reg[31:0];
            FB_Reg_Old = FB_Reg;

            Secur_Reg[5] = 1'b0;
            Status_Reg[0] = 1'b1;
            #tWRFBR;
            FB_Reg = FB_Reg_Up & FB_Reg_Old;
            //WIP : write in process Bit
            Status_Reg[0] = 1'b0;
            //WEL:Write Enable Latch
            Status_Reg[1] = 1'b0;
            WRFBR_Mode = 1'b0;
        end
    endtask // write_FB_register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute erase Fast Boot register                       */
    /*----------------------------------------------------------------------*/
    task erase_FB_register;
        begin
            Secur_Reg[6] = 1'b0;
            Status_Reg[0] = 1'b1;
            #tSE;
            FB_Reg = 32'hffff_ffff;
            //WIP : write in process Bit
            Status_Reg[0] = 1'b0;
            //WEL:Write Enable Latch
            Status_Reg[1] = 1'b0;
            Secur_Reg[6] = 1'b0;
            ESFBR_Mode = 1'b0;
        end
    endtask // erase_FB_register


    /*----------------------------------------------------------------------*/
    /*  Description: Execute Read Fast Boot Register                        */
    /*----------------------------------------------------------------------*/
    task read_FB_register;
        reg [31:0] Dummy_FB;
        integer Dummy_Count;
        begin
            Dummy_FB = { FB_Reg [7:0], FB_Reg [15:8], FB_Reg [23:16], FB_Reg [31:24] };

            if( DOPI ) begin
                Dummy_Count = CRC_EN ? 8 : 4;
            end
            else if( SOPI ) begin
                Dummy_Count = 4;
            end
            else if( !OPI_EN ) begin
                Dummy_Count = 32;
            end

            if( OPI_EN ) begin 
                if( SOPI ) begin
                    dummy_cycle(4); //for address
                    #0.1;
                    if( Address !== 0 ) begin
                        disable read_FB_register;
                    end

                    dummy_cycle(1);
                    @( negedge SCLK );
                    if( STRDQS )begin
                        DQS_OUT_EN = 1;
                    end
                    dummy_cycle(2);
                    @( negedge SCLK );
                    SI_OUT_EN   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                    SIO_Reg <=  8'hxx;
                    dummy_cycle(1);
                    DQS_TOGGLE_EN = 1'b1;
                end
                else if( DOPI ) begin
                    dummy_cycle(2 + CRC_EN); //for address
                    @( negedge SCLK );
                    #0.1;
                    if( Address !== 0 ) begin
                        disable read_FB_register;
                    end
                    if ( CRC_ERR ) begin
                        disable read_FB_register;
                    end

                    dummy_cycle(2);
                    DQS_OUT_EN = 1;
                    if( DDQSPRC ) begin
                        dummy_cycle(1);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    else if( !DDQSPRC ) begin
                        dummy_cycle(2);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                    end
                end
            end

            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_FB_register;
                end
                else if ( (SCLK === 1'b0 && !DOPI) || (SCLK===1'b1 && DOPI) ) begin
                    if (OPI_EN) begin
                        SI_OUT_EN    = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                        
                    if( Dummy_Count ) begin
                        Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        if( SOPI )begin
                            Dummy_Count = 3;
                        end
                        else if( DOPI )begin
                            Dummy_Count = CRC_EN ? 7 : 3;
                        end
                        else if( !OPI_EN )begin
                            Dummy_Count = 31;
                        end
                    end

                    if ( SOPI ) begin
                        if( Dummy_Count == 3 ) begin
                            SIO_Reg <= Dummy_FB[31:24];
                        end
                        else if( Dummy_Count == 2 ) begin
                            SIO_Reg <= Dummy_FB[23:16];
                        end
                        else if( Dummy_Count == 1 ) begin
                            SIO_Reg <= Dummy_FB[15:8];
                        end
                        else if( Dummy_Count == 0 ) begin
                            SIO_Reg <= Dummy_FB[7:0];
                        end
                    end
                    else if ( DOPI ) begin
                        if( CRC_EN ) begin
                            if( Dummy_Count/2 == 3 ) begin
                                SIO_Reg <= Dummy_Count[0] ? Dummy_FB[31:24] : ~Dummy_FB[31:24];
                            end
                            else if( Dummy_Count/2 == 2 ) begin
                                SIO_Reg <= Dummy_Count[0] ? Dummy_FB[23:16] : ~Dummy_FB[23:16];
                            end
                            else if( Dummy_Count/2 == 1 ) begin
                                SIO_Reg <= Dummy_Count[0] ? Dummy_FB[15:8] : ~Dummy_FB[15:8];
                            end
                            else if( Dummy_Count/2 == 0 ) begin
                                SIO_Reg <= Dummy_Count[0] ? Dummy_FB[7:0] : ~Dummy_FB[7:0];
                            end
                        end
                        else begin //!CRC_EN
                            if( Dummy_Count == 3 ) begin
                                SIO_Reg <= Dummy_FB[31:24];
                            end
                            else if( Dummy_Count == 2 ) begin
                                SIO_Reg <= Dummy_FB[23:16];
                            end
                            else if( Dummy_Count == 1 ) begin
                                SIO_Reg <= Dummy_FB[15:8];
                            end
                            else if( Dummy_Count == 0 ) begin

                                SIO_Reg <= Dummy_FB[7:0];
                            end
                        end
                    end
                    else if ( !OPI_EN ) begin
                        SIO_Reg[1]  <= Dummy_FB[Dummy_Count];
                    end          
                
                end
            end  // end forever

        end
    endtask // read_FB_register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Write Password Register                     */
    /*----------------------------------------------------------------------*/
    task write_password_register;
        reg [63:0] Pwd_Reg_Up;
        reg [63:0] Pwd_Reg_Old;
        begin
            if (Address !== 0) begin
                disable write_password_register;
            end

            Pwd_Reg_Up = Pwd_Tmp_Reg;
            Pwd_Reg_Old = Pwd_Reg;

            Secur_Reg[5] = 1'b0;
            Status_Reg[0] = 1'b1;
            #tWRPASS;
            Pwd_Reg = Pwd_Reg_Up & Pwd_Reg_Old;
            //WIP : write in process Bit
            Status_Reg[0] = 1'b0;
            //WEL:Write Enable Latch
            Status_Reg[1] = 1'b0;
            WRPASS_Mode = 1'b0;
        end
    endtask // write_password_register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Password Unlock                             */
    /*----------------------------------------------------------------------*/
    task password_unlock;
        reg [63:0] Pwd_Reg_In;
        begin
            if (Address !== 0) begin
                disable password_unlock;
            end
            
            Pwd_Reg_In = Pwd_Tmp_Reg;
            Secur_Reg[5] = 1'b0;
            Status_Reg[0] = 1'b1;

            if ( Pwd_Reg === Pwd_Reg_In ) begin
                #tPASSULK;
                Lock_Reg[6] = 1'b1;
                //WIP : write in process Bit
                Status_Reg[0] = 1'b0;
                //WEL:Write Enable Latch
                Status_Reg[1] = 1'b0;
                PASSULK_Mode = 1'b0;
            end
            else begin
                #tPASSULK_FAIL;
                //WIP : write in process Bit
                Status_Reg[0] = 1'b0;
                //WEL:Write Enable Latch
                Status_Reg[1] = 1'b0;
                Secur_Reg[5] = 1'b1;
                PASSULK_Mode = 1'b0;
            end
        end
    endtask // password_unlock

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Read Password Register                      */
    /*----------------------------------------------------------------------*/
    task read_password_register;
        reg [63:0] Dummy_PWD;
        reg CRC_Out_En;
        integer Dummy_Count;
        integer Dummy_Counter;
        begin
            Dummy_PWD = { Pwd_Reg [7:0], Pwd_Reg [15:8], Pwd_Reg [23:16], Pwd_Reg [31:24],
                            Pwd_Reg [39:32], Pwd_Reg [47:40], Pwd_Reg [55:48], Pwd_Reg [63:56] };
            CRC_Out_En = 0;

            if( DOPI ) begin
                Dummy_Count = 512;
            end
            else if( SOPI ) begin
                Dummy_Count = 512;
            end
            else if( !OPI_EN ) begin
                Dummy_Count = 4096;
            end

            if( OPI_EN ) begin 
                if( SOPI ) begin
                    dummy_cycle(4); //for address
                    #0.1;
                    if( Address !== 0 ) begin
                        disable read_password_register;
                    end

                    dummy_cycle(1);
                    @( negedge SCLK );
                    if( STRDQS )begin
                        DQS_OUT_EN = 1;
                    end
                    dummy_cycle(18);
                    @( negedge SCLK );
                    SI_OUT_EN   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                    SIO_Reg <=  8'hxx;
                    dummy_cycle(1);
                    DQS_TOGGLE_EN = 1'b1;
                end
                else if (DOPI) begin
                    dummy_cycle(2 + CRC_EN); //for address
                    @( negedge SCLK );
                    #0.1;
                    if( Address !== 0 ) begin
                        disable read_password_register;
                    end
                    if ( CRC_ERR ) begin
                        disable read_password_register;
                    end

                    dummy_cycle(2);
                    DQS_OUT_EN = 1;
                    if( DDQSPRC ) begin
                        dummy_cycle(17);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;
                        @ (negedge SCLK);
                    end
                    else if( !DDQSPRC ) begin
                        dummy_cycle(18);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                        @ (negedge SCLK);
                    end
                end
            end
            else if (!OPI_EN) begin
                    dummy_cycle(32); //for address
                    #0.1;
                    if( Address !== 0 ) begin
                        disable read_password_register;
                    end
                    dummy_cycle(8);
                    SO_OUT_EN   = 1'b1;
                    SI_IN_EN  = 1'b0;
                    SIO_Reg <=  8'hxx;
            end
            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_password_register;
                end
                else if ( (SCLK === 1'b0 && !DOPI) || DOPI ) begin
                    if (OPI_EN) begin
                        SI_OUT_EN    = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                        
                    if ( !CRC_Out_En) begin
                        if( Dummy_Count ) begin
                            Dummy_Count = Dummy_Count - 1;
                        end
                        else begin
                            if( SOPI )begin
                                Dummy_Count = 511;
                            end
                            else if( DOPI )begin
                                Dummy_Count = 511;
                            end
                            else if( !OPI_EN )begin
                                Dummy_Count = 4095;
                            end
                        end
                    end

                    if ( SOPI ) begin
                        if (Dummy_Count > 503) begin
                            if( Dummy_Count == 511 ) begin
                                SIO_Reg <= Dummy_PWD[63:56];
                            end
                            else if( Dummy_Count == 510 ) begin
                                SIO_Reg <= Dummy_PWD[55:48];
                            end
                            else if( Dummy_Count == 509 ) begin
                                SIO_Reg <= Dummy_PWD[47:40];
                            end
                            else if( Dummy_Count == 508 ) begin
                                SIO_Reg <= Dummy_PWD[39:32];
                            end
                            else if( Dummy_Count == 507 ) begin
                                SIO_Reg <= Dummy_PWD[31:24];
                            end
                            else if( Dummy_Count == 506 ) begin
                                SIO_Reg <= Dummy_PWD[23:16];
                            end
                            else if( Dummy_Count == 505 ) begin
                                SIO_Reg <= Dummy_PWD[15:8];
                            end
                            else if( Dummy_Count == 504 ) begin
                                SIO_Reg <= Dummy_PWD[7:0];
                            end
                        end
                        else begin
                            SIO_Reg <= 8'hff;
                        end
                    end
                    else if ( DOPI ) begin
                        if ( CRC_EN )  begin
                            if ( !CRC_Out_En ) begin
                                if ( Dummy_Count > 503) begin
                                    if( Dummy_Count == 511 ) begin
                                        SIO_Reg <= Dummy_PWD[55:48];
                                        crc_calculation(Dummy_PWD[55:48],1,CRC[7:0]);
                                    end
                                    else if( Dummy_Count == 510 ) begin
                                        SIO_Reg <= Dummy_PWD[63:56];
                                        crc_calculation(Dummy_PWD[63:56],1,CRC[7:0]);
                                    end
                                    else if( Dummy_Count == 509 ) begin
                                        SIO_Reg <= Dummy_PWD[39:32];
                                        crc_calculation(Dummy_PWD[39:32],1,CRC[7:0]);
                                    end
                                    else if( Dummy_Count == 508 ) begin
                                        SIO_Reg <= Dummy_PWD[47:40];
                                        crc_calculation(Dummy_PWD[47:40],1,CRC[7:0]);
                                    end
                                    else if( Dummy_Count == 507 ) begin
                                        SIO_Reg <= Dummy_PWD[23:16];
                                        crc_calculation(Dummy_PWD[23:16],1,CRC[7:0]);
                                    end
                                    else if( Dummy_Count == 506 ) begin
                                        SIO_Reg <= Dummy_PWD[31:24];
                                        crc_calculation(Dummy_PWD[32:24],1,CRC[7:0]);
                                    end
                                    else if( Dummy_Count == 505 ) begin
                                        SIO_Reg <= Dummy_PWD[7:0];
                                        crc_calculation(Dummy_PWD[7:0],1,CRC[7:0]);
                                    end
                                    else if( Dummy_Count == 504 ) begin
                                        SIO_Reg <= Dummy_PWD[15:8];
                                        crc_calculation(Dummy_PWD[15:8],1,CRC[7:0]);
                                    end
                                end
                                else begin
                                    SIO_Reg <= 8'hff;
                                    crc_calculation(8'hff,1,CRC[7:0]);
                                end
                            end
                            else begin
                                if (CRCBEN && SCLK == 0) begin
                                    SIO_Reg <= ~CRC[7:0];
                                end
                                else begin
                                    SIO_Reg <= CRC[7:0];
                                end
                            end

                            if ( CRC_Out_En == 0 &&
                                 (( Dummy_Count % 16 == 0 && CRC_CYC[1:0] == 0 ) ||
                                 ( Dummy_Count % 32 == 0 && CRC_CYC[1:0] == 1 ) ||
                                 ( Dummy_Count % 64 == 0 && CRC_CYC[1:0] == 2 ) || 
                                 ( Dummy_Count % 128 == 0 && CRC_CYC[1:0] == 3 )) ) begin
                                 CRC_Out_En = 1;
                            end
                            else if ( CRC_Out_En == 1 && SCLK == 0 && 
                                      (( Dummy_Count % 16 == 0 && CRC_CYC[1:0] == 0 )  ||
                                      ( Dummy_Count % 32 == 0 && CRC_CYC[1:0] == 1 ) ||
                                      ( Dummy_Count % 64 == 0 && CRC_CYC[1:0] == 2 ) || 
                                      ( Dummy_Count % 128 == 0 && CRC_CYC[1:0] == 3 )) ) begin
                                 CRC_Out_En = 0;
                                 crc_calculation(0,0,CRC[7:0]);
                            end
                        end
                        else begin
                            if ( Dummy_Count > 503 ) begin
                                if( Dummy_Count == 511 ) begin
                                    SIO_Reg <= Dummy_PWD[55:48];
                                end
                                else if( Dummy_Count == 510 ) begin
                                    SIO_Reg <= Dummy_PWD[63:56];
                                end
                                else if( Dummy_Count == 509 ) begin
                                    SIO_Reg <= Dummy_PWD[39:32];
                                end
                                else if( Dummy_Count == 508 ) begin
                                    SIO_Reg <= Dummy_PWD[47:40];
                                end
                                else if( Dummy_Count == 507 ) begin
                                    SIO_Reg <= Dummy_PWD[23:16];
                                end
                                else if( Dummy_Count == 506 ) begin
                                    SIO_Reg <= Dummy_PWD[31:24];
                                end
                                else if( Dummy_Count == 505 ) begin
                                    SIO_Reg <= Dummy_PWD[7:0];
                                end
                                else if( Dummy_Count == 504 ) begin
                                    SIO_Reg <= Dummy_PWD[15:8];
                                end
                            end
                            else begin
                                SIO_Reg <= 8'hff;
                            end
                        end
                    end
                    else if ( !OPI_EN ) begin
                        if (Dummy_Count > 4031) begin
                            Dummy_Counter = Dummy_Count - 4032;
                            SIO_Reg[1] <= Dummy_PWD[Dummy_Counter];
                        end
                        else begin
                            SIO_Reg[1] <= 1'b1;
                        end
                    end          
                end
            end     // end forever
        end
    endtask // read_password_register
    /*----------------------------------------------------------------------*/
    /*  Description: define an suspend task                                 */
    /*----------------------------------------------------------------------*/
    task suspend_write;
        begin
            disable resume_write;
            Susp_Ready = 1'b1;

            if ( Pgm_Mode ) begin
                Susp_Trig = 1;
                During_Susp_Wait = 1'b1;
                #tPSL;
                $display ( $time, " Suspend Program ..." );
                Secur_Reg[2]  = 1'b1;//PSB
                Status_Reg[0] = 1'b0;//WIP
                Status_Reg[1] = 1'b0;//WEL
                WR2Susp = 0;
               During_Susp_Wait = 1'b0;                
            end
            else if ( Ers_Mode ) begin
                Susp_Trig = 1;
                During_Susp_Wait = 1'b1;                
                #tESL;
                $display ( $time, " Suspend Erase ..." );
                Secur_Reg[3]  = 1'b1;//ESB
                Status_Reg[0] = 1'b0;//WIP
                Status_Reg[1] = 1'b0;//WEL
                WR2Susp = 0;
                During_Susp_Wait = 1'b0;                
            end
        end
    endtask // suspend_write

    /*----------------------------------------------------------------------*/
    /*  Description: define an resume task                                  */
    /*----------------------------------------------------------------------*/
    task resume_write;
        begin
            if ( Pgm_Mode ) begin
                Susp_Ready    = 1'b0;
                Status_Reg[0] = 1'b1;//WIP
                Status_Reg[1] = 1'b1;//WEL
                Secur_Reg[2]  = 1'b0;//PSB
                Resume_Trig   = 1;
                #tPRS;
                Susp_Ready    = 1'b1;
            end
            else if ( Ers_Mode ) begin
                Susp_Ready    = 1'b0;
                Status_Reg[0] = 1'b1;//WIP
                Status_Reg[1] = 1'b1;//WEL
                Secur_Reg[3]  = 1'b0;//ESB
                Resume_Trig   = 1;
                #tERS;
                Susp_Ready    = 1'b1;
            end
        end
    endtask // resume_write

    /*----------------------------------------------------------------------*/
    /*  Description: define a timer to count erase time                     */
    /*----------------------------------------------------------------------*/
    task er_timer;
        begin
            ERS_CLK = 1'b0;
            forever
                begin
                    #(Clock*20) ERS_CLK = ~ERS_CLK;    // erase timer period is 2us
                end
        end
    endtask // er_timer

    /*----------------------------------------------------------------------*/
    /*  Description: Execute  Chip Lock                                     */
    /*----------------------------------------------------------------------*/
    task chip_lock;
        begin
            for ( i = 0; i <= 15; i = i + 1 ) begin
                DPB_Reg_TOP[i] = 1'b1;
                DPB_Reg_BOT[i] = 1'b1;
            end
            for ( i = 1; i <= Block_NUM - 2; i = i + 1 ) begin
                DPB_Reg[i] = 1'b1;
            end
            Status_Reg[1] = 1'b0;
        end
    endtask // chip_lock

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Chip Block Unlock                              */
    /*----------------------------------------------------------------------*/
    task chip_unlock;
        begin
            for ( i = 0; i <= 15; i = i + 1 ) begin
                DPB_Reg_TOP[i] = 1'b0;
                DPB_Reg_BOT[i] = 1'b0;
            end
            for ( i = 1; i <= Block_NUM - 2; i = i + 1 ) begin
                DPB_Reg[i] = 1'b0;
            end
            Status_Reg[1] = 1'b0;
        end
    endtask // chip_unlock

    /*----------------------------------------------------------------------*/
    /*  Description: define a block erase task                              */
    /*               D8 AD1 AD2 AD3                                         */
    /*----------------------------------------------------------------------*/
    task block_erase;
        integer i, i_tmp;
        //time ERS_Time;
        integer Start_Add;
        integer End_Add;
        begin
            Block       =  Address[A_MSB:16];
            Block2      =  Address[A_MSB:15];
            Start_Add   = (Address[A_MSB:16]<<16) + 16'h0;
            End_Add     = (Address[A_MSB:16]<<16) + 16'hffff;
            //WIP : write in process Bit
            Status_Reg[0] =  1'b1;
            Secur_Reg[6]  =  1'b0;
            if ( write_protect(Address) == 1'b0 &&
                 !(WPSEL_Mode == 1'b1 && Block[Block_MSB:0] == 0 && SEC_Pro_Reg_BOT) &&
                 !(WPSEL_Mode == 1'b1 && Block[Block_MSB:0] == Block_NUM-1 && SEC_Pro_Reg_TOP) ) begin
               for( i = Start_Add; i <= End_Add; i = i + 1 )
               begin
                   ARRAY[i] = 8'hxx;
               end
               ERS_Time = ERS_Count_BE;
               fork
                   er_timer;
                   begin
                       for( i = 0; i < ERS_Time - 1; i = i + 1 ) begin
                           @ ( negedge ERS_CLK or posedge Susp_Trig );
                           if ( Susp_Trig == 1'b1 ) begin
                               if( Susp_Ready == 0 ) i = i_tmp;
                               i_tmp = i;
                               wait( Resume_Trig );
                               $display ( $time, " Resume BE Erase ..." );
                           end
                       end
                        #tWR_END;
                       //#tBE ;
                       for( i = Start_Add; i <= End_Add; i = i + 1 )
                       begin
                           ARRAY[i] = 8'hff;
                           if( i[3:0]==0 ) begin
                               ECC[i[A_MSB:4]]            = 10'h3ff;
                               ECC_DBPGM[i[A_MSB:4]]      = 0;
                               ECC_1BERR[i[A_MSB:4]]      = 0;
                               ECC_2BERR[i[A_MSB:4]]      = 0;
                               ECC_FADDR_BYTE[i[A_MSB:4]] = 4'h0; 
                               ECC_FADDR_BIT[i[A_MSB:4]]  = 3'h0; 
                           end
                       end
                       disable er_timer;
                       disable resume_write;
                       Susp_Ready = 1'b1;
                   end
               join
            end
            else begin
                #tERS_CHK;
                Secur_Reg[6] = 1'b1;
            end   
            //WIP : write in process Bit
            Status_Reg[0] =  1'b0;//WIP
            //WEL : write enable latch
            Status_Reg[1] =  1'b0;//WEL
            BE_Mode = 1'b0;
            BE64K_Mode = 1'b0;
        end
    endtask // block_erase

    /*----------------------------------------------------------------------*/
    /*  Description: define a sector 4k erase task                          */
    /*               20 AD1 AD2 AD3                                         */
    /*----------------------------------------------------------------------*/
    task sector_erase_4k;
        integer i, i_tmp;
        //time ERS_Time;
        integer Start_Add;
        integer End_Add;
        begin
            Sector      =  Address[A_MSB:12]; 
            Start_Add   = (Address[A_MSB:12]<<12) + 12'h000;
            End_Add     = (Address[A_MSB:12]<<12) + 12'hfff;          
            //WIP : write in process Bit
            Status_Reg[0] =  1'b1;
            Secur_Reg[6]  =  1'b0;
            if ( write_protect(Address) == 1'b0 ) begin
               for( i = Start_Add; i <= End_Add; i = i + 1 )
               begin
                   ARRAY[i] = 8'hxx;
               end
               ERS_Time = ERS_Count_SE;
               fork
                   er_timer;
                   begin
                       for( i = 0; i < ERS_Time - 1; i = i + 1 ) begin
                           @ ( negedge ERS_CLK or posedge Susp_Trig );
                           if ( Susp_Trig == 1'b1 ) begin
                               if( Susp_Ready == 0 ) i = i_tmp;
                               i_tmp = i;
                               wait( Resume_Trig );
                               $display ( $time, " Resume SE Erase ..." );
                           end
                       end
                        #tWR_END;
                       for( i = Start_Add; i <= End_Add; i = i + 1 )
                       begin
                           ARRAY[i] = 8'hff;
                           if( i[3:0]==0 ) begin
                               ECC[i[A_MSB:4]]            = 10'h3ff;
                               ECC_DBPGM[i[A_MSB:4]]      = 0;
                               ECC_1BERR[i[A_MSB:4]]      = 0;
                               ECC_2BERR[i[A_MSB:4]]      = 0;
                               ECC_FADDR_BYTE[i[A_MSB:4]] = 4'h0; 
                               ECC_FADDR_BIT[i[A_MSB:4]]  = 3'h0; 
                           end
                       end
                       disable er_timer;
                       disable resume_write;
                       Susp_Ready = 1'b1;
                   end
               join
            end
            else begin
                #tERS_CHK;
                Secur_Reg[6] = 1'b1;
            end
            //WIP : write in process Bit
            Status_Reg[0] = 1'b0;//WIP
            //WEL : write enable latch
            Status_Reg[1] = 1'b0;//WEL
            SE_4K_Mode = 1'b0;
         end
    endtask // sector_erase_4k
    
    /*----------------------------------------------------------------------*/
    /*  Description: define a chip erase task                               */
    /*               60(C7)                                                 */
    /*----------------------------------------------------------------------*/
    task chip_erase;
        reg [A_MSB:0] Address_Int;
        integer i, j, k;
        begin
            Address_Int = Address;
            Status_Reg[0] =  1'b1;
            Secur_Reg[6]  =  1'b0;
            if ( (Dis_CE == 1'b1 && WPSEL_Mode == 1'b0) || ( ( (SEC_Pro_Reg_BOT) && (SEC_Pro_Reg_TOP)&& (&SEC_Pro_Reg) ) && WPSEL_Mode == 1'b1) ) begin
                #tERS_CHK;
                Secur_Reg[6] = 1'b1;
            end
            else begin
                for ( i = 0;i<tCE/100;i = i + 1) begin
                    #100_000_000;
                end
                if ( WPSEL_Mode == 1'b1 ) begin
                    for( i = 0; i <Block_NUM; i = i+1 ) begin
                            if ( i == 0 ) begin: bot_check
                                for ( k = 0; k <= 15; k = k + 1 ) begin
                                        if ( SEC_Pro_Reg_BOT[k] == 1'b1 ) begin
                                                disable bot_check;
                                        end
                                end
                                Address_Int = (i<<16) + 16'h0;
                                Start_Add = (i<<16) + 16'h0;
                                End_Add   = (i<<16) + 16'hffff;
                                for( j = Start_Add; j <=End_Add; j = j + 1 ) begin
                                        ARRAY[j] =  8'hff;
                                        if( j[3:0]==0 ) begin
                                               ECC[j[A_MSB:4]]            = 10'h3ff;
                                               ECC_DBPGM[j[A_MSB:4]]      = 0;
                                               ECC_1BERR[j[A_MSB:4]]      = 0;
                                               ECC_2BERR[j[A_MSB:4]]      = 0;
                                               ECC_FADDR_BYTE[j[A_MSB:4]] = 4'h0; 
                                               ECC_FADDR_BIT[j[A_MSB:4]]  = 3'h0; 
                                        end
                                end
                            end
                            else if ( i == Block_NUM -1 ) begin: top_check
                                for ( k = 0; k <= 15; k = k + 1 ) begin
                                        if ( SEC_Pro_Reg_TOP[k] == 1'b1 ) begin
                                                disable top_check;
                                        end
                                end
                                Address_Int = (i<<16) + 16'h0;
                                Start_Add = (i<<16) + 16'h0;
                                End_Add   = (i<<16) + 16'hffff;
                                for( j = Start_Add; j <=End_Add; j = j + 1 ) begin
                                        ARRAY[j] =  8'hff;
                                        if( j[3:0]==0 ) begin
                                            ECC[j[A_MSB:4]]            = 10'h3ff;
                                            ECC_DBPGM[j[A_MSB:4]]      = 0;
                                            ECC_1BERR[j[A_MSB:4]]      = 0;
                                            ECC_2BERR[j[A_MSB:4]]      = 0;
                                            ECC_FADDR_BYTE[j[A_MSB:4]] = 4'h0; 
                                            ECC_FADDR_BIT[j[A_MSB:4]]  = 3'h0; 
                                        end
                                end
                            end
                            else begin                  
                                Address_Int = (i<<16) + 16'h0;
                                if ( SEC_Pro_Reg[i] == 1'b0 ) begin
                                        Start_Add = (i<<16) + 16'h0;
                                        End_Add   = (i<<16) + 16'hffff; 
                                        for( j = Start_Add; j <=End_Add; j = j + 1 ) begin
                                                ARRAY[j] =  8'hff;
                                                if( j[3:0]==0 ) begin
                                                    ECC[j[A_MSB:4]]            = 10'h3ff;
                                                    ECC_DBPGM[j[A_MSB:4]]      = 0;
                                                    ECC_1BERR[j[A_MSB:4]]      = 0;
                                                    ECC_2BERR[j[A_MSB:4]]      = 0;
                                                    ECC_FADDR_BYTE[j[A_MSB:4]] = 4'h0; 
                                                    ECC_FADDR_BIT[j[A_MSB:4]]  = 3'h0; 
                                                end
                                        end
                                end
                            end
                    end
                end
                else begin
                    for( i = 0; i <Block_NUM; i = i+1 ) begin
                        Address_Int = (i<<16) + 16'h0;
                        Start_Add = (i<<16) + 16'h0;
                        End_Add   = (i<<16) + 16'hffff;
                        for( j = Start_Add; j <=End_Add; j = j + 1 ) begin
                                ARRAY[j] =  8'hff;
                                if( j[3:0]==0 ) begin
                                    ECC[j[A_MSB:4]]            = 10'h3ff;
                                    ECC_DBPGM[j[A_MSB:4]]      = 0;
                                    ECC_1BERR[j[A_MSB:4]]      = 0;
                                    ECC_2BERR[j[A_MSB:4]]      = 0;
                                    ECC_FADDR_BYTE[j[A_MSB:4]] = 4'h0; 
                                    ECC_FADDR_BIT[j[A_MSB:4]]  = 3'h0; 
                                end
                        end
                    end
                end
            end
            //WIP : write in process Bit
            Status_Reg[0] = 1'b0;//WIP
            //WEL : write enable latch
            Status_Reg[1] = 1'b0;//WEL
            CE_Mode = 1'b0;
        end
    endtask // chip_erase       


    /*----------------------------------------------------------------------*/
    /*  Description: define a page program task                             */
    /*               02 AD1 AD2 AD3                                         */
    /*----------------------------------------------------------------------*/
    task page_program;
        input  [A_MSB:0]  Address;
        reg    [7:0]      Offset;
        reg               CRC_In_En;
        integer Dummy_Count, Tmp_Int, i;

        begin
            Dummy_Count = Buffer_Num;    // page size
            CRC_In_En = 0;
            Tmp_Int = 0;
            if(DOPI) begin
                Offset  = {Address[7:1],1'b0};
            end
            else if(!DOPI) begin
                Offset  = Address[7:0];
            end
            /*------------------------------------------------*/
            /*  Store 256 bytes into a temp buffer - Dummy_A  */
            /*------------------------------------------------*/
            for (i = 0; i < Dummy_Count ; i = i + 1 ) begin
                Dummy_A[i]  = 8'hff;
            end

            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    if ( (Tmp_Int % 8 !== 0) || (Tmp_Int == 1'b0) || (Tmp_Int < 16 && DOPI) ) begin
                        if ( DOPI && CRC_EN ) begin
                            CRC_ERR = 1;
                        end
                        PP_Mode = 0;
                        disable page_program;
                    end
                    else if ( DOPI && CRC_EN && ( ( CRC_CYC[1:0] == 2'b00 && Tmp_Int % (16 *8) !== 0 ) ||
                                                  ( CRC_CYC[1:0] == 2'b01 && Tmp_Int % (32 *8) !== 0 ) ||
                                                  ( CRC_CYC[1:0] == 2'b10 && Tmp_Int % (64 *8) !== 0 ) ||
                                                  ( CRC_CYC[1:0] == 2'b11 && Tmp_Int % (128*8) !== 0 ) )
                            ) begin
                        CRC_ERR = 1;
                        PP_Mode = 0;
                        disable page_program;
                    end
                    else begin
                        tPP_Real = tPP;

                        if ( Tmp_Int > 8 || DOPI ) begin
                            Byte_PGM_Mode = 1'b0;
                        end
                        else begin
                            Byte_PGM_Mode = 1'b1;
                        end

                        #tCEH;
                        if ( CS_INT == 0 ) begin
                            PP_Mode = 0;
                            Byte_PGM_Mode = 1'b0;
                            disable page_program;
                        end
                        else begin
                            update_array ( Address );
                        end
                    end
                    disable page_program;
                end
                else begin 
                    if( SCLK == 1'b1 || (SCLK == 1'b0 && DOPI) )begin
                        if( !OPI_EN )begin
                            Tmp_Int = Tmp_Int + 1;
                        end
                        else if( OPI_EN )begin
                            if ( DOPI && CRC_EN && CRC_In_En ) Tmp_Int = Tmp_Int;
                            else                               Tmp_Int = Tmp_Int + 8;
                        end

                        if ( (Tmp_Int % 8 == 0) && !DOPI ) begin
                            #1;
                            Dummy_A[Offset] = SI_Reg [7:0];
                            Offset = Offset + 1;   
                            Offset = Offset[7:0];   
                        end  
                        else if ( (Tmp_Int % 16 == 0) && DOPI ) begin
                            #1;
                            if( CRC_In_En ) begin
                                if ( SCLK==0) begin
                                    if ( SI_Reg[15:8] !== CRC[7:0] ) begin
                                        PP_Mode = 0;
                                        CRC_ERR = 1;
                                        disable page_program;
                                    end
                                    CRC_In_En = 0;
                                    crc_calculation(0, 0, CRC[7:0]);
                                end
                            end
                            else begin
                                Dummy_A[Offset+1] = SI_Reg [15:8];
                                Dummy_A[Offset]   = SI_Reg [7:0];
                                if( CRC_EN ) begin
                                    crc_calculation(SI_Reg [15:8], 1, CRC[7:0]);
                                    crc_calculation(SI_Reg [7:0], 1, CRC[7:0]);
                                end

                                if( DOPI && CRC_EN && !CRC_In_En && (
                                     ( CRC_CYC[1:0] == 0 && Offset[3:1] == 3'b111 ) ||    //CRC-16
                                     ( CRC_CYC[1:0] == 1 && Offset[4:1] == 4'b1_111 ) ||    //CRC-32
                                     ( CRC_CYC[1:0] == 2 && Offset[5:1] == 5'b11_111 ) ||    //CRC-64
                                     ( CRC_CYC[1:0] == 3 && Offset[6:1] == 6'b111_111 ) ) ) begin    //CRC-128
                                    CRC_In_En = 1;
                                end

                                Offset = Offset + 2;   
                                Offset = Offset[7:0];   
                            end
                        end  
                    end
                end
            end  // end forever
        end
    endtask // page_program

    /*----------------------------------------------------------------------*/
    /*  Description: define a program time calculation function             */
    /*  INPUT: program number                                               */
    /*----------------------------------------------------------------------*/ 
    function time pgm_time_cal;
        input pgm_num;
        integer pgm_num;
        time  pgm_time_tmp;

        begin
            pgm_time_tmp = ( 20 + ( (pgm_num + 15) / 16 ) * 12 ) * 1000;
            if ( pgm_time_tmp > tPP ) begin
                pgm_time_cal = tPP;
            end
            else begin
                pgm_time_cal = pgm_time_tmp;
            end
        end
    endfunction

    /*----------------------------------------------------------------------*/
    /*  Description: define a program chip task                             */
    /*  INPUT:address                                                       */
    /*----------------------------------------------------------------------*/
    task update_array;
        input [A_MSB:0] Address;
        integer Dummy_Count, i, i_tmp;
        integer program_time;
        reg [7:0]  ori [0:Buffer_Num-1];
        begin
            Dummy_Count = Buffer_Num;
            Address = { Address [A_MSB:8], 8'h0 };
            program_time = tPP_Real - tCEH;
            Status_Reg[0]= 1'b1;
            Secur_Reg[5] = 1'b0;
            if ( write_protect(Address) == 1'b0 && add_in_erase(Address) == 1'b0 ) begin
                for ( i = 0; i < Dummy_Count; i = i + 1 ) begin
                    if ( Secur_Mode == 1'b1) begin
                        ori[i] = Secur_ARRAY[Address + i];
                        Secur_ARRAY[Address + i] = Secur_ARRAY[Address + i] & 8'bx;
                    end
                    else begin
                        ori[i] = ARRAY[Address + i];
                        ARRAY[Address+ i] = ARRAY[Address + i] & 8'bx;
                    end
                end
                fork
                    pg_timer;
                    begin
                        for( i = 0; i*2 < program_time - tWR_END; i = i + 1 ) begin
                            @ ( negedge PGM_CLK or posedge Susp_Trig );
                            if ( Susp_Trig == 1'b1 ) begin
                                if( Susp_Ready == 0 ) i = i_tmp;
                                i_tmp = i;
                                wait( Resume_Trig );
                                $display ( $time, " Resume program ..." );
                            end
                        end
                        #tWR_END;
                        //#program_time ;
                        for ( i = 0; i < Dummy_Count; i = i + 1 ) begin
                            if ( Secur_Mode == 1'b1)
                                Secur_ARRAY[Address + i] = ori[i] & Dummy_A[i];
                            else
                                ARRAY[Address+ i] = ori[i] & Dummy_A[i];
                        end
                        #0;
                        update_ecc(Address);
                        disable pg_timer;
                        disable resume_write;
                        Susp_Ready = 1'b1;
                    end
                join
            end
            else begin
                #tPGM_CHK ;
                Secur_Reg[5] = 1'b1;
            end
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
            PP_Mode = 1'b0;
            Byte_PGM_Mode = 1'b0;
        end
    endtask // update_array

    /*----------------------------------------------------------------------*/
    /*  Description: define a program ecc task                              */
    /*  INPUT:address                                                       */
    /*----------------------------------------------------------------------*/
    task update_ecc;
        input [A_MSB:0] Address;
        reg [127:0]     data_new;
        reg [7:0]       Dummy_Page[0:255];
        reg [7:0]       Dummy[0:15];
        reg [9:0]       ecc, ecc_new;
        reg [A_MSB:4]   Chunk;
        reg [A_MSB:0]   Address_Int;
        integer         i, j, k, m;

        begin
            for ( i = 0; i < Buffer_Num; i = i + 1 ) begin
                Address_Int = Address[A_MSB:0] + i[7:0];
                Chunk       = Address_Int[A_MSB:4];
                if ( Secur_Mode == 1'b1) begin
                    j[7:0] = Secur_ARRAY[Address_Int];
                end
                else if ( SFDP_Mode == 1'b1) begin
                    j[7:0] = SFDP_ARRAY[Address_Int];
                end
                else begin
                    j[7:0] = ARRAY[Address_Int];
                end

                Dummy_Page[i] = j[7:0];
            end

            for( m=0; m<Buffer_Num/16; m=m+1 ) begin
                for( i=0; i<16; i=i+1 ) begin
                    Dummy[i] = Dummy_Page[m*16+i];
                end
                Chunk = Address[A_MSB:4] + m;

                for( i=0; i<16; i=i+1 ) begin
                    for( j=0; j<8; j=j+1 ) begin
                        k = i*8 + j;
                        data_new[k] = Dummy[i] >> j;
                    end
                end
                ecc_new = ecc_calculation(data_new[127:0]);
                ecc     = Secur_Mode ? SOTP_ECC[Chunk] : (SFDP_Mode ? SFDP_ECC[Chunk] : ECC[Chunk]);

                if( ~ecc & ecc_new ) begin
                    if ( Secur_Mode == 1'b1 ) begin
                        SOTP_ECC_DBPGM[Chunk] = 1;
                        SOTP_ECC[Chunk]       = 10'h000;
                    end
                    else if ( SFDP_Mode == 1'b1 ) begin
                        SFDP_ECC_DBPGM[Chunk] = 1;
                        SFDP_ECC[Chunk]       = 10'h000;
                    end
                    else begin
                        ECC_DBPGM[Chunk] = 1;
                        ECC[Chunk]       = 10'h000;
                    end
                end
                else begin
                    if ( Secur_Mode == 1'b1 ) begin
                        SOTP_ECC[Chunk]  = ecc_new;
                    end
                    else if ( SFDP_Mode == 1'b1 ) begin
                        SFDP_ECC[Chunk]  = ecc_new;
                    end
                    else begin
                        ECC[Chunk]       = ecc_new;
                    end
                end
            end

        end
    endtask

    /*----------------------------------------------------------------------*/
    /*  Description: define a ecc calculation function                      */
    /*  INPUT: data_in                                                      */
    /*----------------------------------------------------------------------*/ 
    function [9:0] ecc_calculation;
        input [127:0] data_in;
        reg   [135:0] data;
        reg   [9:0]   ecc;

        begin
            ecc = 0;
            data = { data_in[127:120], 
                     ecc[7],data_in[119:57],
                     ecc[6],data_in[56:26],
                     ecc[5],data_in[25:11],
                     ecc[4],data_in[10:4],
                     ecc[3],data_in[3:1],
                     ecc[2],data_in[0],
                     ecc[1],ecc[0] };


            ecc[0] =  ( data[0] ^ data[2] ^ data[4] ^ data[6] ^ data[8] ^ data[10] ^ data[12] ^ data[14] ^
                        data[16] ^ data[18] ^ data[20] ^ data[22] ^ data[24] ^ data[26] ^ data[28] ^ data[30] ^
                        data[32] ^ data[34] ^ data[36] ^ data[38] ^ data[40] ^ data[42] ^ data[44] ^ data[46] ^
                        data[48] ^ data[50] ^ data[52] ^ data[54] ^ data[56] ^ data[58] ^ data[60] ^ data[62] ^
                        data[64] ^ data[66] ^ data[68] ^ data[70] ^ data[72] ^ data[74] ^ data[76] ^ data[78] ^
                        data[80] ^ data[82] ^ data[84] ^ data[86] ^ data[88] ^ data[90] ^ data[92] ^ data[94] ^
                        data[96] ^ data[98] ^ data[100] ^ data[102] ^ data[104] ^ data[106] ^ data[108] ^
                        data[110] ^ data[112] ^ data[114] ^ data[116] ^ data[118] ^ data[120] ^ data[122] ^
                        data[124] ^ data[126] ^ data[128] ^ data[130] ^ data[132] ^ data[134] ) ;

            ecc[1] =  ( data[1] ^ data[2] ^ data[5] ^ data[6] ^ data[9] ^ data[10] ^ data[13] ^ data[14] ^ 
                        data[17] ^ data[18] ^ data[21] ^ data[22] ^ data[25] ^ data[26] ^ data[29] ^ data[30] ^
                        data[33] ^ data[34] ^ data[37] ^ data[38] ^ data[41] ^ data[42] ^ data[45] ^ data[46] ^ 
                        data[49] ^ data[50] ^ data[53] ^ data[54] ^ data[57] ^ data[58] ^ data[61] ^ data[62] ^
                        data[65] ^ data[66] ^ data[69] ^ data[70] ^ data[73] ^ data[74] ^ data[77] ^ data[78] ^
                        data[81] ^ data[82] ^ data[85] ^ data[86] ^ data[89] ^ data[90] ^ data[93] ^ data[94] ^
                        data[97] ^ data[98] ^ data[101] ^ data[102] ^ data[105] ^ data[106] ^ data[109] ^
                        data[110] ^ data[113] ^ data[114] ^ data[117] ^ data[118] ^ data[121] ^ data[122] ^
                        data[125] ^ data[126] ^ data[129] ^ data[130] ^ data[133] ^ data[134] ) ;

            ecc[2] =  ( data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[11] ^ data[12] ^ data[13] ^ data[14] ^
                        data[19] ^ data[20] ^ data[21] ^ data[22] ^ data[27] ^ data[28] ^ data[29] ^ data[30] ^
                        data[35] ^ data[36] ^ data[37] ^ data[38] ^ data[43] ^ data[44] ^ data[45] ^ data[46] ^
                        data[51] ^ data[52] ^ data[53] ^ data[54] ^ data[59] ^ data[60] ^ data[61] ^ data[62] ^
                        data[67] ^ data[68] ^ data[69] ^ data[70] ^ data[75] ^ data[76] ^ data[77] ^ data[78] ^
                        data[83] ^ data[84] ^ data[85] ^ data[86] ^ data[91] ^ data[92] ^ data[93] ^ data[94] ^
                        data[99] ^ data[100] ^ data[101] ^ data[102] ^ data[107] ^ data[108] ^ data[109] ^
                        data[110] ^ data[115] ^ data[116] ^ data[117] ^ data[118] ^ data[123] ^ data[124] ^
                        data[125] ^ data[126] ^ data[131] ^ data[132] ^ data[133] ^ data[134]) ;

            ecc[3] = ~( data[7] ^ data[8] ^ data[9] ^ data[10] ^ data[11] ^ data[12] ^ data[13] ^ data[14] ^
                        data[23] ^ data[24] ^ data[25] ^ data[26] ^ data[27] ^ data[28] ^ data[29] ^ data[30] ^
                        data[39] ^ data[40] ^ data[41] ^ data[42] ^ data[43] ^ data[44] ^ data[45] ^ data[46] ^
                        data[55] ^ data[56] ^ data[57] ^ data[58] ^ data[59] ^ data[60] ^ data[61] ^ data[62] ^
                        data[71] ^ data[72] ^ data[73] ^ data[74] ^ data[75] ^ data[76] ^ data[77] ^ data[78] ^
                        data[87] ^ data[88] ^ data[89] ^ data[90] ^ data[91] ^ data[92] ^ data[93] ^ data[94] ^
                        data[103] ^ data[104] ^ data[105] ^ data[106] ^ data[107] ^ data[108] ^ data[109] ^
                        data[110] ^ data[119] ^ data[120] ^ data[121] ^ data[122] ^ data[123] ^ data[124] ^
                        data[125] ^ data[126] ^ data[135] ) ;

            ecc[4] =  ( data[15] ^ data[16] ^ data[17] ^ data[18] ^ data[19] ^ data[20] ^ data[21] ^ data[22] ^
                        data[23] ^ data[24] ^ data[25] ^ data[26] ^ data[27] ^ data[28] ^ data[29] ^ data[30] ^
                        data[47] ^ data[48] ^ data[49] ^ data[50] ^ data[51] ^ data[52] ^ data[53] ^ data[54] ^
                        data[55] ^ data[56] ^ data[57] ^ data[58] ^ data[59] ^ data[60] ^ data[61] ^ data[62] ^
                        data[79] ^ data[80] ^ data[81] ^ data[82] ^ data[83] ^ data[84] ^ data[85] ^ data[86] ^
                        data[87] ^ data[88] ^ data[89] ^ data[90] ^ data[91] ^ data[92] ^ data[93] ^ data[94] ^
                        data[111] ^ data[112] ^ data[113] ^ data[114] ^ data[115] ^ data[116] ^ data[117] ^
                        data[118] ^ data[119] ^ data[120] ^ data[121] ^ data[122] ^ data[123] ^ data[124] ^
                        data[125] ^ data[126] ) ;

            ecc[5] =  ( data[31] ^ data[32] ^ data[33] ^ data[34] ^ data[35] ^ data[36] ^ data[37] ^ data[38] ^
                        data[39] ^ data[40] ^ data[41] ^ data[42] ^ data[43] ^ data[44] ^ data[45] ^ data[46] ^
                        data[47] ^ data[48] ^ data[49] ^ data[50] ^ data[51] ^ data[52] ^ data[53] ^ data[54] ^
                        data[55] ^ data[56] ^ data[57] ^ data[58] ^ data[59] ^ data[60] ^ data[61] ^ data[62] ^
                        data[95] ^ data[96] ^ data[97] ^ data[98] ^ data[99] ^ data[100] ^ data[101] ^ data[102] ^
                        data[103] ^ data[104] ^ data[105] ^ data[106] ^ data[107] ^ data[108] ^ data[109] ^
                        data[110] ^ data[111] ^ data[112] ^ data[113] ^ data[114] ^ data[115] ^ data[116] ^
                        data[117] ^ data[118] ^ data[119] ^ data[120] ^ data[121] ^ data[122] ^ data[123] ^
                        data[124] ^ data[125] ^ data[126] ) ;

            ecc[6] =  ( data[63] ^ data[64] ^ data[65] ^ data[66] ^ data[67] ^ data[68] ^ data[69] ^ data[70] ^
                        data[71] ^ data[72] ^ data[73] ^ data[74] ^ data[75] ^ data[76] ^ data[77] ^ data[78] ^
                        data[79] ^ data[80] ^ data[81] ^ data[82] ^ data[83] ^ data[84] ^ data[85] ^ data[86] ^
                        data[87] ^ data[88] ^ data[89] ^ data[90] ^ data[91] ^ data[92] ^ data[93] ^ data[94] ^
                        data[95] ^ data[96] ^ data[97] ^ data[98] ^ data[99] ^ data[100] ^ data[101] ^ data[102] ^
                        data[103] ^ data[104] ^ data[105] ^ data[106] ^ data[107] ^ data[108] ^ data[109] ^
                        data[110] ^ data[111] ^ data[112] ^ data[113] ^ data[114] ^ data[115] ^ data[116] ^
                        data[117] ^ data[118] ^ data[119] ^ data[120] ^ data[121] ^ data[122] ^ data[123] ^
                        data[124] ^ data[125] ^ data[126] ) ;

            ecc[7] = ~( data[127] ^ data[128] ^ data[129] ^ data[130] ^ data[131] ^ data[132] ^ data[133] ^
                        data[134] ^ data[135] ) ;

            ecc[8]   = ^ecc[7:0];
            ecc[9]   = ^data_in[127:0];

            if( ecc[7:0] == 8'h00 ) ecc[9:6] = ~ecc[9:6];
            if( ecc[7:0] == 8'hff ) ecc[9:8] = ~ecc[9:8];
            
            ecc_calculation[9:0] = ecc[9:0];
        end
    endfunction

    /*----------------------------------------------------------------------*/
    /*Description: find out whether the address is selected for erase       */
    /*----------------------------------------------------------------------*/
    function add_in_erase;
        input [A_MSB:0] Address;
        begin
            if( Secur_Mode == 1'b0 ) begin
                if (( ERS_Time == ERS_Count_BE && Address[A_MSB:16] == Block && ESB ) ||
                   ( ERS_Time == ERS_Count_SE && Address[A_MSB:12] == Sector && ESB ) ) begin
                    add_in_erase = 1'b1;
                    $display ( $time," Failed programing,address is in erase" );
                end
                else begin
                    add_in_erase = 1'b0;
                end
            end
            else if( Secur_Mode == 1'b1 ) begin
                    add_in_erase = 1'b0;
            end
        end
    endfunction // add_in_erase

    /*----------------------------------------------------------------------*/
    /*  Description: define a timer to count program time                   */
    /*----------------------------------------------------------------------*/
    task pg_timer;
        begin
            PGM_CLK = 1'b0;
            forever
                begin
                    #1 PGM_CLK = ~PGM_CLK;    // program timer period is 2ns
                end
        end
    endtask // pg_timer

    /*----------------------------------------------------------------------*/
    /*  Description: define a enter secured OTP task                        */
    /*----------------------------------------------------------------------*/
    task enter_secured_otp;
        begin
            //$display( $time, " Enter secured OTP mode  = %b",  Secur_Mode );
            Secur_Mode= 1;
            //$display( $time, " New Enter  secured OTP mode  = %b",  Secur_Mode );
        end
    endtask // enter_secured_otp

    /*----------------------------------------------------------------------*/
    /*  Description: define a exit secured OTP task                         */
    /*----------------------------------------------------------------------*/
    task exit_secured_otp;
        begin
            //$display( $time, " Enter secured OTP mode  = %b",  Secur_Mode );
            Secur_Mode = 0;
            //$display( $time,  " New Enter secured OTP mode  = %b",  Secur_Mode );
        end
    endtask

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Reading Security Register                      */
    /*----------------------------------------------------------------------*/
    task read_Secur_Register;
        integer Dummy_Count;
        begin
        Dummy_Count = 8;

            if( OPI_EN ) begin 
                if( SOPI ) begin
                    dummy_cycle(4); //for address
                    #0.1;
                    if( Address !== 0 ) begin
                        disable read_Secur_Register;
                    end

                    dummy_cycle(1);
                    @( negedge SCLK );
                    if( STRDQS )begin
                        DQS_OUT_EN = 1;
                    end
                    dummy_cycle(2);
                    @( negedge SCLK );
                    SI_OUT_EN   = 1'b1;
                    SO_OUT_EN   = 1'b1;
                    OPI_OUT_EN  = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;
                    SIO_Reg <=  8'hxx;
                    dummy_cycle(1);
                    DQS_TOGGLE_EN = 1'b1;
                end
                else if( DOPI ) begin
                    dummy_cycle(2 + CRC_EN); //for address
                    @( negedge SCLK );
                    #0.1;
                    if( Address !== 0 ) begin
                        disable read_Secur_Register;
                    end
                    if ( CRC_ERR ) begin
                        disable read_Secur_Register;
                    end

                    dummy_cycle(2);
                    DQS_OUT_EN = 1;
                    if( DDQSPRC ) begin
                        dummy_cycle(1);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    else if( !DDQSPRC ) begin
                        dummy_cycle(2);
                        SI_OUT_EN   = 1'b1;
                        SO_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN  = 1'b0;
                        SI_IN_EN  = 1'b0;
                        OPI_IN_EN = 1'b0;
                        SIO_Reg <=  8'hxx;
                    end
                end
            end

            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable read_Secur_Register;
                end
                else if ( (SCLK === 1'b0 && !DOPI) || (SCLK===1'b1 && DOPI) ) begin
                    if (OPI_EN) begin
                        SI_OUT_EN    = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        DQS_TOGGLE_EN = 1'b1;
                    end
                    SO_OUT_EN = 1'b1;
                    SO_IN_EN  = 1'b0;
                    SI_IN_EN  = 1'b0;
                    OPI_IN_EN = 1'b0;

                    if ( OPI_EN ) begin
                        if( DOPI && CRC_EN ) begin
                            Dummy_Count[0] = Dummy_Count[0] - 1;
                            SIO_Reg <= Dummy_Count[0] ? Secur_Reg : ~SIO_Reg;
                        end
                        else begin
                            SIO_Reg <= Secur_Reg;
                        end
                    end
                    else begin
                        if (Dummy_Count) begin
                            Dummy_Count = Dummy_Count - 1;
                        end
                        else begin
                            Dummy_Count = 7;
                        end
                        SIO_Reg[1]  <= Secur_Reg[Dummy_Count];
                    end          
                end
            end  // end forever
        end
    endtask // read_Secur_Register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Write Security Register                        */
    /*----------------------------------------------------------------------*/
    task write_secur_register;
        begin
            WRSCUR_Mode = 1'b1;
            Status_Reg[0] = 1'b1;
            #tBP;
            WRSCUR_Mode = 1'b0;
            Secur_Reg [1] = 1'b1;
            Status_Reg[0] = 1'b0;
            Status_Reg[1] = 1'b0;
        end
    endtask // write_secur_register


    /*----------------------------------------------------------------------*/
    /*  Description: Execute 8X IO Read Mode                                */
    /*----------------------------------------------------------------------*/
    task read_8xio;
        //reg [A_MSB:0] Address;
        reg [7:0]   OUT_Buf ;
        reg         offset;
        begin
            offset      = 0;
            SI_OUT_EN   = 1'b0;
            SO_OUT_EN   = 1'b0;
            OPI_OUT_EN  = 1'b0;
            SI_IN_EN    = 1'b1;
            SO_IN_EN    = 1'b1;
            OPI_IN_EN   = 1'b1;

            dummy_cycle(4); // for address

            fork
                begin
                    if ( CR[4] ) begin
                        dummy_cycle(1);
                        @( negedge SCLK );
                        if( STRDQS )begin
                            DQS_OUT_EN = 1;
                        end
                        dummy_cycle(2);
                        @(negedge SCLK);
                        SO_OUT_EN   = 1'b1;
                        SI_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN    = 1'b0;
                        SI_IN_EN    = 1'b0;
                        OPI_IN_EN   = 1'b0;
                        Read_Mode   = 1'b1;
                        SIO_Reg[7:0] <= 8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;

                        if( SFDP_Mode == 1 ) begin
                            dummy_cycle(20-4);
                        end
                        else begin
                            case(DMCYC[2:0])
                                3'd0: dummy_cycle(20-4);
                                3'd1: dummy_cycle(18-4);
                                3'd2: dummy_cycle(16-4);
                                3'd3: dummy_cycle(14-4);
                                3'd4: dummy_cycle(12-4);
                                3'd5: dummy_cycle(10-4);
                                3'd6: dummy_cycle(8 -4);
                                3'd7: dummy_cycle(6 -4);
                                default: dummy_cycle(20-4);
                            endcase
                        end
                    end
                    else begin
                        dummy_cycle(1);
                        @( negedge SCLK );
                        if( STRDQS )begin
                            DQS_OUT_EN = 1;
                        end

                        if( SFDP_Mode == 1 ) begin
                            dummy_cycle(20-1-1);
                        end
                        else begin
                            case(DMCYC[2:0])
                                3'd0: dummy_cycle(20-1-1);
                                3'd1: dummy_cycle(18-1-1);
                                3'd2: dummy_cycle(16-1-1);
                                3'd3: dummy_cycle(14-1-1);
                                3'd4: dummy_cycle(12-1-1);
                                3'd5: dummy_cycle(10-1-1);
                                3'd6: dummy_cycle(8 -1-1);
                                3'd7: dummy_cycle(6 -1-1);
                                default: dummy_cycle(20-1-1);
                            endcase
                        end

                        @ (negedge SCLK);
                        SO_OUT_EN   = 1'b1;
                        SI_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN    = 1'b0;
                        SI_IN_EN    = 1'b0;
                        OPI_IN_EN   = 1'b0;
                        Read_Mode   = 1'b1;
                        SIO_Reg[7:0] <= 8'hxx;
                        dummy_cycle(1);
                        DQS_TOGGLE_EN = 1'b1;
                    end
                
                    Prea_OUT_EN8 <= #1 1'b0;

                    forever @ ( negedge SCLK or posedge CS_INT ) begin
                        if ( CS_INT == 1'b1 ) begin
                            disable read_8xio;
                        end
                        else begin
                            RD_Mode = 1'b1;
                            read_array(Address, OUT_Buf[7:0]);
                            SIO_Reg[7:0] <= OUT_Buf[7:0];

                            if ( EN_Burst && Burst_Length==8 && Address[2:0]==3'b111 && !SFDP_Mode )
                                Address = {Address[A_MSB:3], 3'b000};
                            else if ( EN_Burst && Burst_Length==16 && Address[3:0]==4'b1111 && !SFDP_Mode )
                                Address = {Address[A_MSB:4], 4'b0000};
                            else if ( EN_Burst && Burst_Length==32 && Address[4:0]==5'b1_1111 && !SFDP_Mode )
                                Address = {Address[A_MSB:5], 5'b0_0000};
                            else if ( EN_Burst && Burst_Length==64 && Address[5:0]==6'b11_1111 && !SFDP_Mode )
                                Address = {Address[A_MSB:6], 6'b00_0000};
                            else
                                Address = Address + 1;

                            load_address(Address);
                        end
                    end//forever 
                end 
                begin
                    if(CR[4]) begin
                        dummy_cycle_prea(4);
                        Prea_OUT_EN8 = 1'b1;
                        preamble_bit_out;
                    end
                end
            join
        end
    endtask // read_8xio

    /*----------------------------------------------------------------------*/
    /*  Description: Execute DDR 8X IO Read Mode                            */
    /*----------------------------------------------------------------------*/
    task ddrread_8xio;
        //reg [A_MSB:0] Address;
        reg [7:0]   OUT_Buf ;
        reg         offset;
        reg         CRC_Out_En;
        begin
            offset   = 0;
            CRC_Out_En  = 1'b0;
            SI_OUT_EN   = 1'b0;
            SO_OUT_EN   = 1'b0;
            OPI_OUT_EN  = 1'b0;
            SI_IN_EN    = 1'b1;
            SO_IN_EN    = 1'b1;
            OPI_IN_EN   = 1'b1;

            dummy_cycle(2 + CRC_EN); // for address

            @(negedge SCLK);
            #1;
            if( CRC_ERR ) begin
                disable ddrread_8xio;
            end

            fork
                begin
                    if ( CR[4] ) begin
                        dummy_cycle(2);
                        DQS_OUT_EN = 1;
                        dummy_cycle(4-2-DDQSPRC);
                        SO_OUT_EN   = 1'b1;
                        SI_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN    = 1'b0;
                        SI_IN_EN    = 1'b0;
                        OPI_IN_EN   = 1'b0;
                        Read_Mode   = 1'b1;
                        SIO_Reg[7:0] <=  8'hxx;
                        dummy_cycle( DDQSPRC );
        
                        if( DDQSPRC ) begin
                            DQS_TOGGLE_EN = 1'b1;
                        end
        
                        @(negedge SCLK);
        
                        if( SFDP_Mode == 1 ) begin
                            dummy_cycle(20-4);
                        end
                        else begin
                            case(DMCYC[2:0])
                                3'd0: dummy_cycle(20-4);
                                3'd1: dummy_cycle(18-4);
                                3'd2: dummy_cycle(16-4);
                                3'd3: dummy_cycle(14-4);
                                3'd4: dummy_cycle(12-4);
                                3'd5: dummy_cycle(10-4);
                                3'd6: dummy_cycle(8 -4);
                                3'd7: dummy_cycle(6 -4);
                                default: dummy_cycle(20-4);
                            endcase
                        end
                        @(negedge SCLK);
                        Prea_OUT_EN8 <= #1 1'b0;
                    end
                    else begin
                        dummy_cycle(2);
                        DQS_OUT_EN = 1;

                        if( SFDP_Mode == 1 ) begin
                            dummy_cycle(20-2-DDQSPRC);
                        end
                        else begin
                            case(DMCYC[2:0])
                                3'd0: dummy_cycle(20-2-DDQSPRC);
                                3'd1: dummy_cycle(18-2-DDQSPRC);
                                3'd2: dummy_cycle(16-2-DDQSPRC);
                                3'd3: dummy_cycle(14-2-DDQSPRC);
                                3'd4: dummy_cycle(12-2-DDQSPRC);
                                3'd5: dummy_cycle(10-2-DDQSPRC);
                                3'd6: dummy_cycle(8 -2-DDQSPRC);
                                3'd7: dummy_cycle(6 -2-DDQSPRC);
                                default: dummy_cycle(20-2-DDQSPRC);
                            endcase
                        end

                        SO_OUT_EN   = 1'b1;
                        SI_OUT_EN   = 1'b1;
                        OPI_OUT_EN  = 1'b1;
                        SO_IN_EN    = 1'b0;
                        SI_IN_EN    = 1'b0;
                        OPI_IN_EN   = 1'b0;
                        Read_Mode   = 1'b1;
                        SIO_Reg[7:0] <= 8'hxx;
                        dummy_cycle( DDQSPRC );
        
                        if( DDQSPRC ) begin
                            DQS_TOGGLE_EN = 1'b1;
                        end
        
                        @(negedge SCLK);
                        Prea_OUT_EN8 <= #1 1'b0;

                    end
            
                    forever @ ( SCLK or posedge CS_INT ) begin
                        if ( CS_INT == 1'b1 ) begin
                            disable ddrread_8xio;
                        end
                        else begin
                            DQS_TOGGLE_EN = 1'b1;
                            RD_Mode       = 1'b1;
                            offset = offset + 1;

                            if( CRC_Out_En ) begin
                                if( offset == 1 )
                                    SIO_Reg[7:0] <= CRC[7:0];
                                else begin
                                    SIO_Reg[7:0] <= CRCBEN ? ~CRC[7:0] : CRC[7:0];
                                    crc_calculation(0, 0, CRC[7:0]); //reset CRC[7:0] to all 0
                                end
                            end
                            else begin
                                if( offset == 1 )
                                    read_array({Address[A_MSB:1],1'b1}, OUT_Buf[7:0]);    //high byte
                                else
                                    read_array({Address[A_MSB:1],1'b0}, OUT_Buf[7:0]);    //low byte

                                SIO_Reg[7:0] <= OUT_Buf[7:0];

                                if( CRC_EN )
                                    crc_calculation(OUT_Buf[7:0], 1, CRC[7:0]);
                            end

                            if( offset == 0 ) begin
                                if( CRC_EN && !CRC_Out_En && (
                                     ( CRC_CYC[1:0] == 0 && Address[3:1] == 3'b111 ) ||    //CRC-16
                                     ( CRC_CYC[1:0] == 1 && Address[4:1] == 4'b1_111 ) ||    //CRC-32
                                     ( CRC_CYC[1:0] == 2 && Address[5:1] == 5'b11_111 ) ||    //CRC-64
                                     ( CRC_CYC[1:0] == 3 && Address[6:1] == 6'b111_111 ) ) ) begin    //CRC-128
                                    CRC_Out_En = 1;
                                end
                                else if( CRC_Out_En == 1 ) begin
                                    CRC_Out_En = 0;
                                end

                                if( CRC_Out_En == 0 ) begin
                                    if ( EN_Burst && Burst_Length==8 && Address[2:1]==2'b11 )
                                        Address = {Address[A_MSB:3], 3'b000};
                                    else if ( EN_Burst && Burst_Length==16 && Address[3:1]==3'b111 )
                                        Address = {Address[A_MSB:4], 4'b0000};
                                    else if ( EN_Burst && Burst_Length==32 && Address[4:1]==4'b1_111 )
                                        Address = {Address[A_MSB:5], 5'b0_0000};
                                    else if ( EN_Burst && Burst_Length==64 && Address[5:1]==5'b11_111 )
                                        Address = {Address[A_MSB:6], 6'b00_0000};
                                    else
                                    Address = Address + 2;

                                    load_address(Address);
                                end
                            end
                        end
                    end//forever
                end
                begin
                    if( CR[4] ) begin
                        dummy_cycle_prea(4);
                        @(negedge SCLK);
                        Prea_OUT_EN8 = 1'b1;
                        preamble_bit_out_dtr;
                    end
                end
            join  
        end
    endtask // ddrread_8xio

    /*----------------------------------------------------------------------*/
    /*  Description: define a CRC calculation task                          */
    /*----------------------------------------------------------------------*/
    task crc_calculation;
        input [7:0] Data_In;
        input CRC_Rst_B;
        output [7:0] CRC_Out;

        begin
            if( !CRC_Rst_B ) begin
                CRC_Out[7:0] = 8'b0;
            end
            else begin
                CRC_Out[7:0] = Data_In[7:0] ^ CRC_Out[7:0];
            end
        end
    endtask

    /*----------------------------------------------------------------------*/
    /*  Description: define a preamble bit read task SDR                    */
    /*----------------------------------------------------------------------*/
    task preamble_bit_out;
        integer Dummy_Count;
        begin
            Dummy_Count = 16;

            forever begin
                @ ( negedge SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable preamble_bit_out;
                end 
                else begin
                    if ( Dummy_Count ) begin
                        Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        Dummy_Count = 15;
                    end

                    if ( Prea_OUT_EN8 ) begin
                        if ( STRDQS ) begin
                            DQS_TOGGLE_EN = 1'b1;

                        end
                        SIO_Reg[7:4] <= {4{Prea_Reg[Dummy_Count]}};
                        SIO_Reg[3]   <= Prea_Reg_DQ3[Dummy_Count];
                        SIO_Reg[2:0] <= {3{Prea_Reg[Dummy_Count]}};
                    end
                    else if ( Prea_OUT_EN1 ) begin
                        SO_OUT_EN  = 1'b1;
                        SI_IN_EN   = 1'b0;
                        SIO_Reg[1] <= Prea_Reg[Dummy_Count];
                    end
                end
            end //end forever
        end
     endtask //preamble_bit_out

    /*----------------------------------------------------------------------*/
    /*  Description: define a preamble bit read task DDR                    */
    /*----------------------------------------------------------------------*/
    task preamble_bit_out_dtr;
        integer Dummy_Count;
        begin
            Dummy_Count = 16;

            forever begin
                @ ( SCLK or posedge CS_INT );
                if ( CS_INT == 1'b1 ) begin
                    disable preamble_bit_out_dtr;
                end 
                else begin
                    if ( Dummy_Count ) begin
                        Dummy_Count = Dummy_Count - 1;
                    end
                    else begin
                        Dummy_Count = 15;
                    end

                    if ( Prea_OUT_EN8 ) begin
                        DQS_TOGGLE_EN = 1'b1;


                        SIO_Reg[7:4] <= {4{Prea_Reg[Dummy_Count]}};
                        SIO_Reg[3]   <= Prea_Reg_DQ3[Dummy_Count];
                        SIO_Reg[2:0] <= {3{Prea_Reg[Dummy_Count]}};
                    end
                    else if ( Prea_OUT_EN1 ) begin
                        SO_OUT_EN  = 1'b1;
                        SI_IN_EN   = 1'b0;
                        SIO_Reg[1] <= Prea_Reg[Dummy_Count];
                    end
                end
            end //end forever
        end
     endtask //preamble_bit_out_dtr

    /*----------------------------------------------------------------------*/
    /*  Description: define read array output task                          */
    /*----------------------------------------------------------------------*/
    task read_array;
        input [A_MSB:0] Address;
        output [7:0]    OUT_Buf;
        reg             ECC_1b_rdm;
        reg             ECC_2b_rdm;
        reg  [6:0]      ECC_add1_rdm;                
        reg  [6:0]      ECC_add2_rdm;                
        reg  [A_MSB:4]  Chunk;
        reg  [A_MSB:0]  Fail_Address;
        begin
            if ( Secur_Mode == 1 ) begin
                if (Read_start == 1'b0 || ( Address[3:0] == 4'b0000 && !DOPI || Address[3:0] == 4'b0001 && DOPI ) ) begin
                    Chunk = Address[A_MSB:4];

                    ECC_double_pgm = 1'b0;
                    ECC_2b_detect  = 1'b0;
                    ECC_1b_correct = 1'b0;

                    ECC_2b_rdm     = `ECC_TWO_BIT_FRATE_SOTP ? ( {$random} % `ECC_TWO_BIT_FRATE_SOTP == 0 ) : 0;
                    ECC_1b_rdm     = `ECC_ONE_BIT_FRATE_SOTP ? ( {$random} % `ECC_ONE_BIT_FRATE_SOTP == 0 ) : 0;

                    if (SOTP_ECC_DBPGM[Chunk] == 1) begin
                        ECC_double_pgm = 1'b1;
                        ECC_2b_detect  = 1'b0;
                        ECC_1b_correct = 1'b0;
                        -> ECC_double_pgm_Event;
                    end
                    else if (SOTP_ECC_2BERR[Chunk] == 1 || ECC_2b_rdm) begin
                        ECC_double_pgm = 1'b0;
                        ECC_2b_detect  = 1'b1;
                        ECC_1b_correct = 1'b0;
                        -> ECC_2b_detect_Event;
                    end
                    else if (SOTP_ECC_1BERR[Chunk] == 1 || ECC_1b_rdm) begin
                        ECC_double_pgm = 1'b0;
                        ECC_2b_detect  = 1'b0;
                        ECC_1b_correct = 1'b1;
                        -> ECC_1b_correct_Event;
                    end

                    if (Read_start == 1'b0) begin
                        Read_start = 1'b1;
                    end

                    if ( ECC_2b_detect && SOTP_ECC_2BERR[Chunk] == 0 ) begin
                        SOTP_ECC_1BERR[Chunk] = 1'b0;
                        SOTP_ECC_2BERR[Chunk] = 1'b1;
                        ECC_add1_rdm[6:0] = 1 + {$random} % 7'h7f;
                        Fail_Address = {Chunk,ECC_add1_rdm[6:3]};
                        Secur_ARRAY[Fail_Address] = Secur_ARRAY[Fail_Address] ^ (1 << ECC_add1_rdm[2:0]);
                        ECC_add2_rdm[6:0] = {$random} % ECC_add1_rdm[6:0];
                        Fail_Address = {Chunk,ECC_add2_rdm[6:3]};
                        Secur_ARRAY[Fail_Address] = Secur_ARRAY[Fail_Address] ^ (1 << ECC_add2_rdm[2:0]);
                    end

                    if ( ECC_1b_correct && SOTP_ECC_1BERR[Chunk] == 0 ) begin
                        SOTP_ECC_1BERR[Chunk] = 1'b1;
                        SOTP_ECC_2BERR[Chunk] = 1'b0;
                        ECC_add1_rdm[6:0] = {$random} % 8'h80;
                        SOTP_ECC_FADDR_BYTE[Chunk] = ECC_add1_rdm[6:3];
                        SOTP_ECC_FADDR_BIT[Chunk]  = ECC_add1_rdm[2:0];
                        Fail_Address = {Chunk,ECC_add1_rdm[6:3]};
                    end
                end

                if ( !tRES1_Chk ) begin
                    OUT_Buf = Secur_ARRAY[Address];
                end
                else begin
                    OUT_Buf = 8'hxx;
                end
            end
            else if ( SFDP_Mode == 1 ) begin
                if (Read_start == 1'b0 || ( Address[3:0] == 4'b0000 && !DOPI || Address[3:0] == 4'b0001 && DOPI ) ) begin
                    Chunk = Address[A_MSB:4];

                    ECC_double_pgm = 1'b0;
                    ECC_2b_detect  = 1'b0;
                    ECC_1b_correct = 1'b0;

                    ECC_2b_rdm     = `ECC_TWO_BIT_FRATE_SFDP ? ( {$random} % `ECC_TWO_BIT_FRATE_SFDP == 0 ) : 0;
                    ECC_1b_rdm     = `ECC_ONE_BIT_FRATE_SFDP ? ( {$random} % `ECC_ONE_BIT_FRATE_SFDP == 0 ) : 0;

                    if (SFDP_ECC_DBPGM[Chunk] == 1) begin
                        ECC_double_pgm = 1'b1;
                        ECC_2b_detect  = 1'b0;
                        ECC_1b_correct = 1'b0;
                        -> ECC_double_pgm_Event;
                    end
                    else if (SFDP_ECC_2BERR[Chunk] == 1 || ECC_2b_rdm) begin
                        ECC_double_pgm = 1'b0;
                        ECC_2b_detect  = 1'b1;
                        ECC_1b_correct = 1'b0;
                        -> ECC_2b_detect_Event;
                    end
                    else if (SFDP_ECC_1BERR[Chunk] == 1 || ECC_1b_rdm) begin
                        ECC_double_pgm = 1'b0;
                        ECC_2b_detect  = 1'b0;
                        ECC_1b_correct = 1'b1;
                        -> ECC_1b_correct_Event;
                    end

                    if (Read_start == 1'b0) begin
                        Read_start = 1'b1;
                    end

                    if ( ECC_2b_detect && SFDP_ECC_2BERR[Chunk] == 0 ) begin
                        SFDP_ECC_1BERR[Chunk] = 1'b0;
                        SFDP_ECC_2BERR[Chunk] = 1'b1;
                        ECC_add1_rdm[6:0] = 1 + {$random} % 7'h7f;
                        Fail_Address = {Chunk,ECC_add1_rdm[6:3]};
                        SFDP_ARRAY[Fail_Address] = SFDP_ARRAY[Fail_Address] ^ (1 << ECC_add1_rdm[2:0]);
                        ECC_add2_rdm[6:0] = {$random} % ECC_add1_rdm[6:0];
                        Fail_Address = {Chunk,ECC_add2_rdm[6:3]};
                        SFDP_ARRAY[Fail_Address] = SFDP_ARRAY[Fail_Address] ^ (1 << ECC_add2_rdm[2:0]);
                    end

                    if ( ECC_1b_correct && SFDP_ECC_1BERR[Chunk] == 0 ) begin
                        SFDP_ECC_1BERR[Chunk] = 1'b1;
                        SFDP_ECC_2BERR[Chunk] = 1'b0;
                        ECC_add1_rdm[6:0] = {$random} % 8'h80;
                        SFDP_ECC_FADDR_BYTE[Chunk] = ECC_add1_rdm[6:3];
                        SFDP_ECC_FADDR_BIT[Chunk]  = ECC_add1_rdm[2:0];
                        Fail_Address = {Chunk,ECC_add1_rdm[6:3]};
                    end
                end

                if ( !tRES1_Chk ) begin
                    OUT_Buf = SFDP_ARRAY[Address];
                end
                else begin
                    OUT_Buf = 8'hxx;
                end
            end
            else begin
                if (Read_start == 1'b0 || ( Address[3:0] == 4'b0000 && !DOPI || Address[3:0] == 4'b0001 && DOPI ) ) begin
                    Chunk = Address[A_MSB:4];

                    ECC_double_pgm = 1'b0;
                    ECC_2b_detect  = 1'b0;
                    ECC_1b_correct = 1'b0;

                    ECC_2b_rdm     = `ECC_TWO_BIT_FRATE ? ( {$random} % `ECC_TWO_BIT_FRATE == 0 ) : 0;
                    ECC_1b_rdm     = `ECC_ONE_BIT_FRATE ? ( {$random} % `ECC_ONE_BIT_FRATE == 0 ) : 0;

                    if (ECC_DBPGM[Chunk] == 1) begin
                        ECC_double_pgm = 1'b1;
                        ECC_2b_detect  = 1'b0;
                        ECC_1b_correct = 1'b0;
                        -> ECC_double_pgm_Event;
                    end
                    else if (ECC_2BERR[Chunk] == 1 || ECC_2b_rdm) begin
                        ECC_double_pgm = 1'b0;
                        ECC_2b_detect  = 1'b1;
                        ECC_1b_correct = 1'b0;
                        -> ECC_2b_detect_Event;
                    end
                    else if (ECC_1BERR[Chunk] == 1 || ECC_1b_rdm) begin
                        ECC_double_pgm = 1'b0;
                        ECC_2b_detect  = 1'b0;
                        ECC_1b_correct = 1'b1;
                        -> ECC_1b_correct_Event;
                    end

                    if (Read_start == 1'b0) begin
                        Read_start = 1'b1;
                    end

                    if ( ECC_2b_detect && ECC_2BERR[Chunk] == 0 ) begin
                        ECC_1BERR[Chunk] = 1'b0;
                        ECC_2BERR[Chunk] = 1'b1;
                        ECC_add1_rdm[6:0] = 1 + {$random} % 7'h7f;
                        Fail_Address = {Chunk,ECC_add1_rdm[6:3]};
                        ARRAY[Fail_Address] = ARRAY[Fail_Address] ^ (1 << ECC_add1_rdm[2:0]);
                        ECC_add2_rdm[6:0] = {$random} % ECC_add1_rdm[6:0];
                        Fail_Address = {Chunk,ECC_add2_rdm[6:3]};
                        ARRAY[Fail_Address] = ARRAY[Fail_Address] ^ (1 << ECC_add2_rdm[2:0]);
                    end

                    if ( ECC_1b_correct && ECC_1BERR[Chunk] == 0 ) begin
                        ECC_1BERR[Chunk] = 1'b1;
                        ECC_2BERR[Chunk] = 1'b0;
                        ECC_add1_rdm[6:0] = {$random} % 8'h80;
                        ECC_FADDR_BYTE[Chunk] = ECC_add1_rdm[6:3];
                        ECC_FADDR_BIT[Chunk]  = ECC_add1_rdm[2:0];
                        Fail_Address = {Chunk,ECC_add1_rdm[6:3]};
                    end
                end

                if ( !tRES1_Chk ) begin
                    OUT_Buf = ARRAY[Address];
                end
                else begin
                    OUT_Buf = 8'hxx;
                end
            end
        end
    endtask //  read_array

    /*----------------------------------------------------------------------*/
    /*  Description: define read array output task                          */
    /*----------------------------------------------------------------------*/
    task load_address;
        inout [A_MSB:0] Address;
        begin
            if ( Secur_Mode == 1 ) begin
                Address = Address[A_MSB_OTP:0] ;
            end
            else if ( SFDP_Mode == 1 ) begin
                Address = Address[A_MSB_SFDP:0] ;
            end
        end
    endtask //  load_address

    /*----------------------------------------------------------------------*/
    /*  Description: define a write_protect area function                   */
    /*  INPUT: address                                                      */
    /*----------------------------------------------------------------------*/ 
    function write_protect;
        input [A_MSB:0] Address;
        reg [Block_MSB:0] Block;
        begin
            //protect_define
            if( Secur_Mode == 1'b0 ) begin
                Block  =  Address [A_MSB:16];
                if ( WPSEL_Mode == 1'b0 ) begin
                  if ( CR[3] == 1'b0 ) begin
                    if (Status_Reg[5:2] == 4'b0000) begin
                        write_protect = 1'b0;
                    end
                    else if (Status_Reg[5:2] == 4'b0001) begin
                        if (Block[Block_MSB:0] > 2046 && Block[Block_MSB:0] <= 2047) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0010) begin
                        if (Block[Block_MSB:0] >= 2046 && Block[Block_MSB:0] <= 2047) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end

                    else if (Status_Reg[5:2] == 4'b0011) begin
                        if (Block[Block_MSB:0] >= 2044 && Block[Block_MSB:0] <= 2047) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0100) begin
                        if (Block[Block_MSB:0] >= 2040 && Block[Block_MSB:0] <= 2047) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0101) begin
                        if (Block[Block_MSB:0] >= 2032 && Block[Block_MSB:0] <= 2047) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0110) begin
                        if (Block[Block_MSB:0] >= 2016 && Block[Block_MSB:0] <= 2047) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0111) begin
                        if (Block[Block_MSB:0] >= 1984 && Block[Block_MSB:0] <= 2047) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1000) begin
                        if (Block[Block_MSB:0] >= 1920 && Block[Block_MSB:0] <= 2047) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1001) begin
                        if (Block[Block_MSB:0] >= 1792 && Block[Block_MSB:0] <= 2047) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1010) begin
                        if (Block[Block_MSB:0] >= 1536 && Block[Block_MSB:0] <= 2047) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1011) begin
                        if (Block[Block_MSB:0] >= 1024 && Block[Block_MSB:0] <= 2047) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else
                        write_protect = 1'b1;
                  end
                  else begin
                    if (Status_Reg[5:2] == 4'b0000) begin
                        write_protect = 1'b0;
                    end
                    else if (Status_Reg[5:2] == 4'b0001) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] < 1) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0010) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 1) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0011) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 3) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0100) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 7) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0101) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 15) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0110) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 31) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b0111) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 63) begin
                            write_protect = 1'b1;
                        end
                        else begin
                            write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1000) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 127) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1001) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 255) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1010) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 511) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else if (Status_Reg[5:2] == 4'b1011) begin
                        if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 1023) begin
                                write_protect = 1'b1;
                        end
                        else begin
                                write_protect = 1'b0;
                        end
                    end
                    else
                        write_protect = 1'b1;
                  end  
                end
                else begin
                    if (Block[Block_MSB:0] == 0) begin
                        if ( SEC_Pro_Reg_BOT[Address[15:12]] == 1'b0 ) begin
                            write_protect = 1'b0;
                        end
                        else begin
                            write_protect = 1'b1;
                        end
                    end
                    else if (Block[Block_MSB:0] == Block_NUM-1) begin
                        if ( SEC_Pro_Reg_TOP[Address[15:12]] == 1'b0 ) begin
                            write_protect = 1'b0;
                        end
                        else begin
                            write_protect = 1'b1;
                        end
                    end
                    else begin
                        if ( SEC_Pro_Reg[Address[A_MSB:16]] == 1'b0 ) begin
                            write_protect = 1'b0;
                        end
                        else begin
                            write_protect = 1'b1;
                        end
                    end
                end
            end
            else if( Secur_Mode == 1'b1 ) begin
                if ( Secur_Reg[0] == 1'b1 && Address[9] == 1'b1 ) begin
                    write_protect = 1'b1;
                end
                else if ( Secur_Reg[1] == 1'b1 && Address[9] == 1'b0 ) begin
                    write_protect = 1'b1;
                end
                else begin
                    write_protect = 1'b0;
                end
            end            
            else begin
                write_protect = 1'b0;
            end
        end
    endfunction // write_protect


// *============================================================================================== 
// * AC Timing Check Section
// *==============================================================================================
    assign  Write_SHSL = !Read_SHSL;

    wire SPI_Mode_Chk_W;
    assign SPI_Mode_Chk_W = !OPI_EN && ~CS && !FAST_BOOT_Chk;
    wire OPI_Mode_Chk_W;
    assign OPI_Mode_Chk_W = OPI_EN && ~CS;
    wire Read_1XIO_Chk_W;
    assign Read_1XIO_Chk_W = Read_1XIO_Chk;

    wire Read_8XIO_Chk_W_0;
    assign Read_8XIO_Chk_W_0 = Read_8XIO_Chk && DMCYC[2:0]==0;
    wire Read_8XIO_Chk_W_1;                  
    assign Read_8XIO_Chk_W_1 = Read_8XIO_Chk && DMCYC[2:0]==1;
    wire Read_8XIO_Chk_W_2;                  
    assign Read_8XIO_Chk_W_2 = Read_8XIO_Chk && DMCYC[2:0]==2;
    wire Read_8XIO_Chk_W_3;                  
    assign Read_8XIO_Chk_W_3 = Read_8XIO_Chk && DMCYC[2:0]==3;
    wire Read_8XIO_Chk_W_4;                 
    assign Read_8XIO_Chk_W_4 = Read_8XIO_Chk && DMCYC[2:0]==4;
    wire Read_8XIO_Chk_W_5;                  
    assign Read_8XIO_Chk_W_5 = Read_8XIO_Chk && DMCYC[2:0]==5;
    wire Read_8XIO_Chk_W_6;                 
    assign Read_8XIO_Chk_W_6 = Read_8XIO_Chk && DMCYC[2:0]==6;
    wire Read_8XIO_Chk_W_7;                
    assign Read_8XIO_Chk_W_7 = Read_8XIO_Chk && DMCYC[2:0]==7;

    wire DDRRead_8XIO_Chk_W_0;
    assign DDRRead_8XIO_Chk_W_0 = DDRRead_8XIO_Chk && DMCYC[2:0]==0;
    wire DDRRead_8XIO_Chk_W_1;
    assign DDRRead_8XIO_Chk_W_1 = DDRRead_8XIO_Chk && DMCYC[2:0]==1;
    wire DDRRead_8XIO_Chk_W_2;
    assign DDRRead_8XIO_Chk_W_2 = DDRRead_8XIO_Chk && DMCYC[2:0]==2;
    wire DDRRead_8XIO_Chk_W_3;
    assign DDRRead_8XIO_Chk_W_3 = DDRRead_8XIO_Chk && DMCYC[2:0]==3;
    wire DDRRead_8XIO_Chk_W_4;
    assign DDRRead_8XIO_Chk_W_4 = DDRRead_8XIO_Chk && DMCYC[2:0]==4;
    wire DDRRead_8XIO_Chk_W_5;
    assign DDRRead_8XIO_Chk_W_5 = DDRRead_8XIO_Chk && DMCYC[2:0]==5;
    wire DDRRead_8XIO_Chk_W_6;
    assign DDRRead_8XIO_Chk_W_6 = DDRRead_8XIO_Chk && DMCYC[2:0]==6;
    wire DDRRead_8XIO_Chk_W_7;
    assign DDRRead_8XIO_Chk_W_7 = DDRRead_8XIO_Chk && DMCYC[2:0]==7;

    wire Read_SHSL_W;
    assign Read_SHSL_W = Read_SHSL;

    wire STR_133L_Chk;
    assign STR_133L_Chk = (( !OPI_EN  ) || ( SOPI && DMCYC[2:0]>=3 )) && RD_Mode; //SPI: fCmax=133MHz
    wire STR_133R_Chk;
    assign STR_133R_Chk = (( !OPI_EN  ) || ( SOPI && DMCYC[2:0]<3 )) && RD_Mode;
    wire DTR_100L_Chk;
    assign DTR_100L_Chk = DOPI && DMCYC[2:0]>=6 && RD_Mode;
    wire DTR_133L_Chk;
    assign DTR_133L_Chk = DOPI && DMCYC[2:0]>=3 && RD_Mode;
    wire DTR_166L_Chk;
    assign DTR_166L_Chk = DOPI && DMCYC[2:0]>=1 && RD_Mode;
    wire DTR_166R_Chk;
    assign DTR_166R_Chk = DOPI && DMCYC[2:0]==0 && RD_Mode;


    wire SI_IN_STR_133L_EN_W;
    assign SI_IN_STR_133L_EN_W = SI_IN_EN && STR_133L_Chk;
    wire SI_IN_STR_133R_EN_W;
    assign SI_IN_STR_133R_EN_W = SI_IN_EN && STR_133R_Chk;
    wire SI_IN_DTR_100L_EN_W;
    assign SI_IN_DTR_100L_EN_W = SI_IN_EN && DTR_100L_Chk;
    wire SI_IN_DTR_133L_EN_W;
    assign SI_IN_DTR_133L_EN_W = SI_IN_EN && DTR_133L_Chk;
    wire SI_IN_DTR_166L_EN_W;
    assign SI_IN_DTR_166L_EN_W = SI_IN_EN && DTR_166L_Chk;      
    wire SI_IN_DTR_166R_EN_W;
    assign SI_IN_DTR_166R_EN_W = SI_IN_EN && DTR_166R_Chk;

    wire SO_IN_STR_133L_EN_W;
    assign SO_IN_STR_133L_EN_W = SO_IN_EN && STR_133L_Chk;
    wire SO_IN_STR_133R_EN_W;
    assign SO_IN_STR_133R_EN_W = SO_IN_EN && STR_133R_Chk;
    wire SO_IN_DTR_100L_EN_W;
    assign SO_IN_DTR_100L_EN_W = SO_IN_EN && DTR_100L_Chk;
    wire SO_IN_DTR_133L_EN_W;
    assign SO_IN_DTR_133L_EN_W = SO_IN_EN && DTR_133L_Chk;
    wire SO_IN_DTR_166L_EN_W;
    assign SO_IN_DTR_166L_EN_W = SO_IN_EN && DTR_166L_Chk;
    wire SO_IN_DTR_166R_EN_W;
    assign SO_IN_DTR_166R_EN_W = SO_IN_EN && DTR_166R_Chk;

    wire OPI_IN_STR_133L_EN_W;
    assign OPI_IN_STR_133L_EN_W = OPI_IN_EN && STR_133L_Chk;
    wire OPI_IN_STR_133R_EN_W;
    assign OPI_IN_STR_133R_EN_W = OPI_IN_EN && STR_133R_Chk;
    wire OPI_IN_DTR_100L_EN_W;
    assign OPI_IN_DTR_100L_EN_W = OPI_IN_EN && DTR_100L_Chk;
    wire OPI_IN_DTR_133L_EN_W;
    assign OPI_IN_DTR_133L_EN_W = OPI_IN_EN && DTR_133L_Chk;
    wire OPI_IN_DTR_166L_EN_W;
    assign OPI_IN_DTR_166L_EN_W = OPI_IN_EN && DTR_166L_Chk;
    wire OPI_IN_DTR_166R_EN_W;
    assign OPI_IN_DTR_166R_EN_W = OPI_IN_EN && DTR_166R_Chk;

    wire FAST_BOOT_Chk_W_00;
    assign FAST_BOOT_Chk_W_00 = FAST_BOOT_Chk && ( FB_Reg[2:1] === 2'b00 );
    wire FAST_BOOT_Chk_W_01;
    assign FAST_BOOT_Chk_W_01 = FAST_BOOT_Chk && ( FB_Reg[2:1] === 2'b01 );
    wire FAST_BOOT_Chk_W_10;
    assign FAST_BOOT_Chk_W_10 = FAST_BOOT_Chk && ( FB_Reg[2:1] === 2'b10 );
    wire FAST_BOOT_Chk_W_11;
    assign FAST_BOOT_Chk_W_11 = FAST_BOOT_Chk && ( FB_Reg[2:1] === 2'b11 );


    wire tDP_Chk_W;
    assign tDP_Chk_W = tDP_Chk;
    wire tRES1_Chk_W;
    assign tRES1_Chk_W = tRES1_Chk;


    specify
        /*----------------------------------------------------------------------*/
        /*  Timing Check                                                        */
        /*----------------------------------------------------------------------*/
        $period( posedge  SCLK &&& SPI_Mode_Chk_W, tSCLK  );    // SCLK _/~ ->_/~
        $period( negedge  SCLK &&& SPI_Mode_Chk_W, tSCLK  );    // SCLK ~\_ ->~\_
        $period( posedge  SCLK &&& OPI_Mode_Chk_W, tOSCLK  );   // SCLK _/~ ->_/~  //OPI_Mode_Chk_W = ~CS && OPI && Write
        $period( negedge  SCLK &&& OPI_Mode_Chk_W, tOSCLK  );   // SCLK ~\_ ->~\_

        $period( posedge  SCLK &&& Read_1XIO_Chk_W , tRSCLK ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& Read_8XIO_Chk_W_0 , tOSTRSCLK1 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& Read_8XIO_Chk_W_1 , tOSTRSCLK2 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& Read_8XIO_Chk_W_2 , tOSTRSCLK3 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& Read_8XIO_Chk_W_3 , tOSTRSCLK4 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& Read_8XIO_Chk_W_4 , tOSTRSCLK5 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& Read_8XIO_Chk_W_5 , tOSTRSCLK6 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& Read_8XIO_Chk_W_6 , tOSTRSCLK7 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& Read_8XIO_Chk_W_7 , tOSTRSCLK8 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& DDRRead_8XIO_Chk_W_0 , tODTRSCLK1 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& DDRRead_8XIO_Chk_W_1 , tODTRSCLK2 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& DDRRead_8XIO_Chk_W_2 , tODTRSCLK3 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& DDRRead_8XIO_Chk_W_3 , tODTRSCLK4 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& DDRRead_8XIO_Chk_W_4 , tODTRSCLK5 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& DDRRead_8XIO_Chk_W_5 , tODTRSCLK6 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& DDRRead_8XIO_Chk_W_6 , tODTRSCLK7 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& DDRRead_8XIO_Chk_W_7 , tODTRSCLK8 ); // SCLK _/~ ->_/~

        $period( posedge  SCLK &&& FAST_BOOT_Chk_W_00 , tFBSCLK ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& FAST_BOOT_Chk_W_01 , tFBSCLK2 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& FAST_BOOT_Chk_W_10 , tFBSCLK3 ); // SCLK _/~ ->_/~
        $period( posedge  SCLK &&& FAST_BOOT_Chk_W_11 , tFBSCLK4 ); // SCLK _/~ ->_/~

        $width ( posedge  SCLK &&& SPI_Mode_Chk_W, tCH_SPI   );       // SCLK _/~~\_
        $width ( negedge  SCLK &&& SPI_Mode_Chk_W, tCL_SPI   );       // SCLK _/~~\_
        $width ( posedge  SCLK &&& OPI_Mode_Chk_W, tCH_OPI   );       // SCLK ~\__/~
        $width ( negedge  SCLK &&& OPI_Mode_Chk_W, tCL_OPI   );       // SCLK ~\__/~
        $width ( posedge  SCLK &&& Read_1XIO_Chk_W, tCH_R   );       // SCLK _/~~\_
        $width ( negedge  SCLK &&& Read_1XIO_Chk_W, tCL_R   );       // SCLK ~\__/~

        $width ( posedge  CS  &&& Read_SHSL_W, tSHSL_R );       // CS _/~\_
        $width ( posedge  CS  &&& Write_SHSL, tSHSL_W );// CS _/~\_

        $setup ( SIO[0] &&& ~CS, posedge SCLK &&& SI_IN_STR_133L_EN_W,  tDVCH_STR_133L );
        $setup ( SIO[0] &&& ~CS, posedge SCLK &&& SI_IN_STR_133R_EN_W,  tDVCH_STR_133R );
        $hold  ( posedge SCLK &&& SI_IN_STR_133L_EN_W, SIO[0] &&& ~CS,  tCHDX_STR_133L );
        $hold  ( posedge SCLK &&& SI_IN_STR_133R_EN_W, SIO[0] &&& ~CS,  tCHDX_STR_133R );
        $setup ( SIO[0] &&& ~CS, posedge SCLK &&& SI_IN_DTR_100L_EN_W,  tDVCH_DTR_100L );
        $setup ( SIO[0] &&& ~CS, posedge SCLK &&& SI_IN_DTR_133L_EN_W,  tDVCH_DTR_133L );
        $setup ( SIO[0] &&& ~CS, posedge SCLK &&& SI_IN_DTR_166L_EN_W,  tDVCH_DTR_166L );
        $setup ( SIO[0] &&& ~CS, posedge SCLK &&& SI_IN_DTR_166R_EN_W,  tDVCH_DTR_166R );
        $setup ( SIO[0] &&& ~CS, negedge SCLK &&& SI_IN_DTR_100L_EN_W,  tDVCL_DTR_100L );
        $setup ( SIO[0] &&& ~CS, negedge SCLK &&& SI_IN_DTR_133L_EN_W,  tDVCL_DTR_133L );
        $setup ( SIO[0] &&& ~CS, negedge SCLK &&& SI_IN_DTR_166L_EN_W,  tDVCL_DTR_166L );
        $setup ( SIO[0] &&& ~CS, negedge SCLK &&& SI_IN_DTR_166R_EN_W,  tDVCL_DTR_166R );
        $hold  ( posedge SCLK &&& SI_IN_DTR_100L_EN_W, SIO[0] &&& ~CS,  tCHDX_DTR_100L );
        $hold  ( posedge SCLK &&& SI_IN_DTR_133L_EN_W, SIO[0] &&& ~CS,  tCHDX_DTR_133L );
        $hold  ( posedge SCLK &&& SI_IN_DTR_166L_EN_W, SIO[0] &&& ~CS,  tCHDX_DTR_166L );
        $hold  ( posedge SCLK &&& SI_IN_DTR_166R_EN_W, SIO[0] &&& ~CS,  tCHDX_DTR_166R );
        $hold  ( negedge SCLK &&& SI_IN_DTR_100L_EN_W, SIO[0] &&& ~CS,  tCLDX_DTR_100L );
        $hold  ( negedge SCLK &&& SI_IN_DTR_133L_EN_W, SIO[0] &&& ~CS,  tCLDX_DTR_133L );
        $hold  ( negedge SCLK &&& SI_IN_DTR_166L_EN_W, SIO[0] &&& ~CS,  tCLDX_DTR_166L );
        $hold  ( negedge SCLK &&& SI_IN_DTR_166R_EN_W, SIO[0] &&& ~CS,  tCLDX_DTR_166R );


        $setup ( SIO[1] &&& ~CS, posedge SCLK &&& SO_IN_STR_133L_EN_W,  tDVCH_STR_133L );
        $setup ( SIO[1] &&& ~CS, posedge SCLK &&& SO_IN_STR_133R_EN_W,  tDVCH_STR_133R );
        $hold  ( posedge SCLK &&& SO_IN_STR_133L_EN_W, SIO[1] &&& ~CS,  tCHDX_STR_133L );
        $hold  ( posedge SCLK &&& SO_IN_STR_133R_EN_W, SIO[1] &&& ~CS,  tCHDX_STR_133R );
        $setup ( SIO[1] &&& ~CS, posedge SCLK &&& SO_IN_DTR_100L_EN_W,  tDVCH_DTR_100L );
        $setup ( SIO[1] &&& ~CS, posedge SCLK &&& SO_IN_DTR_133L_EN_W,  tDVCH_DTR_133L );
        $setup ( SIO[1] &&& ~CS, posedge SCLK &&& SO_IN_DTR_166L_EN_W,  tDVCH_DTR_166L );
        $setup ( SIO[1] &&& ~CS, posedge SCLK &&& SO_IN_DTR_166R_EN_W,  tDVCH_DTR_166R );
        $setup ( SIO[1] &&& ~CS, negedge SCLK &&& SO_IN_DTR_100L_EN_W,  tDVCL_DTR_100L );
        $setup ( SIO[1] &&& ~CS, negedge SCLK &&& SO_IN_DTR_133L_EN_W,  tDVCL_DTR_133L );
        $setup ( SIO[1] &&& ~CS, negedge SCLK &&& SO_IN_DTR_166L_EN_W,  tDVCL_DTR_166L );
        $setup ( SIO[1] &&& ~CS, negedge SCLK &&& SO_IN_DTR_166R_EN_W,  tDVCL_DTR_166R );
        $hold  ( posedge SCLK &&& SO_IN_DTR_100L_EN_W, SIO[1] &&& ~CS,  tCHDX_DTR_100L );
        $hold  ( posedge SCLK &&& SO_IN_DTR_133L_EN_W, SIO[1] &&& ~CS,  tCHDX_DTR_133L );
        $hold  ( posedge SCLK &&& SO_IN_DTR_166L_EN_W, SIO[1] &&& ~CS,  tCHDX_DTR_166L );
        $hold  ( posedge SCLK &&& SO_IN_DTR_166R_EN_W, SIO[1] &&& ~CS,  tCHDX_DTR_166R );
        $hold  ( negedge SCLK &&& SO_IN_DTR_100L_EN_W, SIO[1] &&& ~CS,  tCLDX_DTR_100L );
        $hold  ( negedge SCLK &&& SO_IN_DTR_133L_EN_W, SIO[1] &&& ~CS,  tCLDX_DTR_133L );
        $hold  ( negedge SCLK &&& SO_IN_DTR_166L_EN_W, SIO[1] &&& ~CS,  tCLDX_DTR_166L );
        $hold  ( negedge SCLK &&& SO_IN_DTR_166R_EN_W, SIO[1] &&& ~CS,  tCLDX_DTR_166R );


        $setup ( SIO[7:2] &&& ~CS, posedge SCLK &&& OPI_IN_STR_133L_EN_W,  tDVCH_STR_133L );
        $setup ( SIO[7:2] &&& ~CS, posedge SCLK &&& OPI_IN_STR_133R_EN_W,  tDVCH_STR_133R );
        $hold  ( posedge SCLK &&& OPI_IN_STR_133L_EN_W, SIO[7:2] &&& ~CS,  tCHDX_STR_133L );
        $hold  ( posedge SCLK &&& OPI_IN_STR_133R_EN_W, SIO[7:2] &&& ~CS,  tCHDX_STR_133R );
        $setup ( SIO[7:2] &&& ~CS, posedge SCLK &&& OPI_IN_DTR_100L_EN_W,  tDVCH_DTR_100L );
        $setup ( SIO[7:2] &&& ~CS, posedge SCLK &&& OPI_IN_DTR_133L_EN_W,  tDVCH_DTR_133L );
        $setup ( SIO[7:2] &&& ~CS, posedge SCLK &&& OPI_IN_DTR_166L_EN_W,  tDVCH_DTR_166L );
        $setup ( SIO[7:2] &&& ~CS, posedge SCLK &&& OPI_IN_DTR_166R_EN_W,  tDVCH_DTR_166R );
        $setup ( SIO[7:2] &&& ~CS, negedge SCLK &&& OPI_IN_DTR_100L_EN_W,  tDVCL_DTR_100L );
        $setup ( SIO[7:2] &&& ~CS, negedge SCLK &&& OPI_IN_DTR_133L_EN_W,  tDVCL_DTR_133L );
        $setup ( SIO[7:2] &&& ~CS, negedge SCLK &&& OPI_IN_DTR_166L_EN_W,  tDVCL_DTR_166L );
        $setup ( SIO[7:2] &&& ~CS, negedge SCLK &&& OPI_IN_DTR_166R_EN_W,  tDVCL_DTR_166R );
        $hold  ( posedge SCLK &&& OPI_IN_DTR_100L_EN_W, SIO[7:2] &&& ~CS,  tCHDX_DTR_100L );
        $hold  ( posedge SCLK &&& OPI_IN_DTR_133L_EN_W, SIO[7:2] &&& ~CS,  tCHDX_DTR_133L );
        $hold  ( posedge SCLK &&& OPI_IN_DTR_166L_EN_W, SIO[7:2] &&& ~CS,  tCHDX_DTR_166L );
        $hold  ( posedge SCLK &&& OPI_IN_DTR_166R_EN_W, SIO[7:2] &&& ~CS,  tCHDX_DTR_166R );
        $hold  ( negedge SCLK &&& OPI_IN_DTR_100L_EN_W, SIO[7:2] &&& ~CS,  tCLDX_DTR_100L );
        $hold  ( negedge SCLK &&& OPI_IN_DTR_133L_EN_W, SIO[7:2] &&& ~CS,  tCLDX_DTR_133L );
        $hold  ( negedge SCLK &&& OPI_IN_DTR_166L_EN_W, SIO[7:2] &&& ~CS,  tCLDX_DTR_166L );
        $hold  ( negedge SCLK &&& OPI_IN_DTR_166R_EN_W, SIO[7:2] &&& ~CS,  tCLDX_DTR_166R );

        $setup    ( negedge CS, posedge SCLK &&& ~CS, tSLCH );
        $hold     ( posedge SCLK &&& ~CS, posedge CS &&& ~DOPI, tCHSH );
        $hold     ( negedge SCLK &&& ~CS, posedge CS &&& DOPI, tCLSH );

        $setup    ( posedge CS &&& ~DOPI, posedge SCLK &&& CS, tSHCH_STR );
        $setup    ( posedge CS &&& DOPI, posedge SCLK &&& CS, tSHCH_DTR );
        $hold     ( posedge SCLK &&& CS, negedge CS, tCHSL );



        $width ( negedge  RESETB_INT, tRLRH   );      // RESET ~\__/~
        $setup ( posedge CS, negedge RESETB_INT ,  tRS );
        $hold  ( negedge RESETB_INT, posedge CS ,  tRH );
        $hold  ( posedge  RESETB_INT, negedge CS, tRHSL );

        $width ( posedge  CS  &&& tDP_Chk_W, tDP );       // CS _/~\_
        $width ( posedge  CS  &&& tRES1_Chk_W, tRES1 );   // CS _/~\_

     endspecify

    integer AC_Check_File;
    // timing check module 
    initial 
    begin 
        AC_Check_File= $fopen ("ac_check.err" );    
    end

    realtime  T_CS_P , T_CS_N;
    realtime  T_SCLK_P , T_SCLK_N;
    realtime  T_RESET_P , T_RESET_N;
    realtime  T_SI;
    realtime  T_SO;
    realtime  T_SIO7_2;                    
    realtime  T_SI_H;
    realtime  T_SI_L;
    realtime  T_SO_H;
    realtime  T_SO_L;
    realtime  T_SIO7_2_H;                    
    realtime  T_SIO7_2_L;                    

    initial 
    begin
        T_CS_P = 0; 
        T_CS_N = 0;
        T_SCLK_P = 0;  
        T_SCLK_N = 0;
        T_RESET_P = 0;
        T_RESET_N = 0;
        T_SI = 0;
        T_SO = 0;
        T_SIO7_2 = 0;                    
    end

    always @ ( posedge SCLK ) begin
        //tSCLK
        if ( $realtime - T_SCLK_P < tSCLK && !OPI_EN && !FAST_BOOT_Chk && $realtime > 0 && ~CS ) 
            $fwrite (AC_Check_File, "Clock Frequence for except READ instruction fSCLK =%f Mhz, fSCLK timing violation at %f \n", fSCLK, $realtime );
        //fRSCLK
        if ( $realtime - T_SCLK_P < tRSCLK && Read_1XIO_Chk && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for READ instruction fRSCLK =%f Mhz, fRSCLK timing violation at %f \n", fRSCLK, $realtime );
        //tOSCLK
        if ( $realtime - T_SCLK_P < tOSCLK && OPI_EN && $realtime > 0 && ~CS ) 
            $fwrite (AC_Check_File, "Clock Frequence for 8XIO except READ instruction fOSCLK =%f Mhz, fOSCLK timing violation at %f \n", fOSCLK, $realtime );

        //fOSTRSCLK1
        if ( $realtime - T_SCLK_P < tOSTRSCLK1 && Read_8XIO_Chk && DMCYC[2:0]==0 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fOSTRSCLK1 =%f Mhz, fOSTRSCLK1 timing violation at %f \n", fOSTRSCLK1, $realtime );
        //fOSTRSCLK2
        if ( $realtime - T_SCLK_P < tOSTRSCLK2 && Read_8XIO_Chk && DMCYC[2:0]==1 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fOSTRSCLK2 =%f Mhz, fOSTRSCLK2 timing violation at %f \n", fOSTRSCLK2, $realtime );
        //fOSTRSCLK3
        if ( $realtime - T_SCLK_P < tOSTRSCLK3 && Read_8XIO_Chk && DMCYC[2:0]==2 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fOSTRSCLK3 =%f Mhz, fOSTRSCLK3 timing violation at %f \n", fOSTRSCLK3, $realtime );
        //fOSTRSCLK4
        if ( $realtime - T_SCLK_P < tOSTRSCLK4 && Read_8XIO_Chk && DMCYC[2:0]==3 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fOSTRSCLK4 =%f Mhz, fOSTRSCLK4 timing violation at %f \n", fOSTRSCLK4, $realtime );
        //fOSTRSCLK5
        if ( $realtime - T_SCLK_P < tOSTRSCLK5 && Read_8XIO_Chk && DMCYC[2:0]==4 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fOSTRSCLK5 =%f Mhz, fOSTRSCLK5 timing violation at %f \n", fOSTRSCLK5, $realtime );
        //fOSTRSCLK6
        if ( $realtime - T_SCLK_P < tOSTRSCLK6 && Read_8XIO_Chk && DMCYC[2:0]==5 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fOSTRSCLK6 =%f Mhz, fOSTRSCLK6 timing violation at %f \n", fOSTRSCLK6, $realtime );
        //fOSTRSCLK7
        if ( $realtime - T_SCLK_P < tOSTRSCLK7 && Read_8XIO_Chk && DMCYC[2:0]==6 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fOSTRSCLK7 =%f Mhz, fOSTRSCLK7 timing violation at %f \n", fOSTRSCLK7, $realtime );
        //fOSTRSCLK8
        if ( $realtime - T_SCLK_P < tOSTRSCLK8 && Read_8XIO_Chk && DMCYC[2:0]==7 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fOSTRSCLK8 =%f Mhz, fOSTRSCLK8 timing violation at %f \n", fOSTRSCLK8, $realtime );

        //fODTRSCLK1
        if ( $realtime - T_SCLK_P < tODTRSCLK1 && DDRRead_8XIO_Chk && DMCYC[2:0]==0 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fODTRSCLK1 =%f Mhz, fODTRSCLK1 timing violation at %f \n", fODTRSCLK1, $realtime );
        //fODTRSCLK2
        if ( $realtime - T_SCLK_P < tODTRSCLK2 && DDRRead_8XIO_Chk && DMCYC[2:0]==1 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fODTRSCLK2 =%f Mhz, fODTRSCLK2 timing violation at %f \n", fODTRSCLK2, $realtime );
        //fODTRSCLK3
        if ( $realtime - T_SCLK_P < tODTRSCLK3 && DDRRead_8XIO_Chk && DMCYC[2:0]==2 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fODTRSCLK3 =%f Mhz, fODTRSCLK3 timing violation at %f \n", fODTRSCLK3, $realtime );
        //fODTRSCLK4
        if ( $realtime - T_SCLK_P < tODTRSCLK4 && DDRRead_8XIO_Chk && DMCYC[2:0]==3 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fODTRSCLK4 =%f Mhz, fODTRSCLK4 timing violation at %f \n", fODTRSCLK4, $realtime );
        //fODTRSCLK5
        if ( $realtime - T_SCLK_P < tODTRSCLK5 && DDRRead_8XIO_Chk && DMCYC[2:0]==4 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fODTRSCLK5 =%f Mhz, fODTRSCLK5 timing violation at %f \n", fODTRSCLK5, $realtime );
        //fODTRSCLK6
        if ( $realtime - T_SCLK_P < tODTRSCLK6 && DDRRead_8XIO_Chk && DMCYC[2:0]==5 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fODTRSCLK6 =%f Mhz, fODTRSCLK6 timing violation at %f \n", fODTRSCLK6, $realtime );
        //fODTRSCLK7
        if ( $realtime - T_SCLK_P < tODTRSCLK7 && DDRRead_8XIO_Chk && DMCYC[2:0]==6 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fODTRSCLK7 =%f Mhz, fODTRSCLK7 timing violation at %f \n", fODTRSCLK7, $realtime );
        //fODTRSCLK8
        if ( $realtime - T_SCLK_P < tODTRSCLK8 && DDRRead_8XIO_Chk && DMCYC[2:0]==7 && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for 8XI/O instruction fODTRSCLK8 =%f Mhz, fODTRSCLK8 timing violation at %f \n", fODTRSCLK8, $realtime );


        //fFBSCLK
        if ( $realtime - T_SCLK_P < tFBSCLK && FAST_BOOT_Chk && ( FB_Reg[2:1] == 2'b00 ) && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for fast boot instruction fFBSCLK =%f Mhz, fFBSCLK timing violation at %f \n", fFBSCLK, $realtime );
        //fFBSCLK2
        if ( $realtime - T_SCLK_P < tFBSCLK2 && FAST_BOOT_Chk && ( FB_Reg[2:1] == 2'b01 ) && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for fast boot instruction fFBSCLK =%f Mhz, fFBSCLK timing violation at %f \n", fFBSCLK2, $realtime );
        //fFBSCLK3
        if ( $realtime - T_SCLK_P < tFBSCLK3 && FAST_BOOT_Chk && ( FB_Reg[2:1] == 2'b10 ) && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for fast boot instruction fFBSCLK =%f Mhz, fFBSCLK timing violation at %f \n", fFBSCLK3, $realtime );
        //fFBSCLK4
        if ( $realtime - T_SCLK_P < tFBSCLK4 && FAST_BOOT_Chk && ( FB_Reg[2:1] == 2'b11 ) && $realtime > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for fast boot instruction fFBSCLK =%f Mhz, fFBSCLK timing violation at %f \n", fFBSCLK4, $realtime );


        T_SCLK_P = $realtime; 
        #0;  
        //tDVCH for SIO[0]
        if ( T_SCLK_P - T_SI < tDVCH_STR_133L && STR_133L_Chk && SI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] setup time tDVCH timing violation at %f \n", tDVCH_STR_133L, $realtime );
        if ( T_SCLK_P - T_SI < tDVCH_STR_133R && STR_133R_Chk && SI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] setup time tDVCH_STR_133R=%f ns, tDVCH timing violation at %f \n", tDVCH_STR_133R, $realtime );
        if ( T_SCLK_P - T_SI < tDVCH_DTR_100L && DTR_100L_Chk && SI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] setup time tDVCH_DTR_100L=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_100L, $realtime );
        if ( T_SCLK_P - T_SI < tDVCH_DTR_133L && DTR_133L_Chk && SI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] setup time tDVCH_DTR_133L=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_133L, $realtime );
        if ( T_SCLK_P - T_SI < tDVCH_DTR_166L && DTR_166L_Chk && SI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] setup time tDVCH_DTR_166L=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_166L, $realtime );
        if ( T_SCLK_P - T_SI < tDVCH_DTR_166R && DTR_166R_Chk && SI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] setup time tDVCH_DTR_166R=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_166R, $realtime );

        //tDVCH for SIO[1]
        if ( T_SCLK_P - T_SO < tDVCH_STR_133L && STR_133L_Chk && SO_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] setup time tDVCH_STR_133L=%f ns, tDVCH timing violation at %f \n", tDVCH_STR_133L, $realtime );
        if ( T_SCLK_P - T_SO < tDVCH_STR_133R && STR_133R_Chk && SO_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] setup time tDVCH_STR_133R=%f ns, tDVCH timing violation at %f \n", tDVCH_STR_133R, $realtime );
        if ( T_SCLK_P - T_SO < tDVCH_DTR_100L && DTR_100L_Chk && SO_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] setup time tDVCH_DTR_100L=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_100L, $realtime );
        if ( T_SCLK_P - T_SO < tDVCH_DTR_133L && DTR_133L_Chk && SO_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] setup time tDVCH_DTR_133L=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_133L, $realtime );
        if ( T_SCLK_P - T_SO < tDVCH_DTR_166L && DTR_166L_Chk && SO_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] setup time tDVCH_DTR_166L=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_166L, $realtime );
        if ( T_SCLK_P - T_SO < tDVCH_DTR_166R && DTR_166R_Chk && SO_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] setup time tDVCH_DTR_166R=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_166R, $realtime );

        //tDVCH for SIO[7:2]
        if ( T_SCLK_P - T_SIO7_2 < tDVCH_STR_133L && STR_133L_Chk && OPI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] setup time tDVCH_STR_133L=%f ns, tDVCH timing violation at %f \n", tDVCH_STR_133L, $realtime );
        if ( T_SCLK_P - T_SIO7_2 < tDVCH_STR_133R && STR_133R_Chk && OPI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] setup time tDVCH_STR_133R=%f ns, tDVCH timing violation at %f \n", tDVCH_STR_133R, $realtime );
        if ( T_SCLK_P - T_SIO7_2 < tDVCH_DTR_100L && DTR_100L_Chk && OPI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] setup time tDVCH_DTR_100L=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_100L, $realtime );
        if ( T_SCLK_P - T_SIO7_2 < tDVCH_DTR_133L && DTR_133L_Chk && OPI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] setup time tDVCH_DTR_133L=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_133L, $realtime );
        if ( T_SCLK_P - T_SIO7_2 < tDVCH_DTR_166L && DTR_166L_Chk && OPI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] setup time tDVCH_DTR_166L=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_166L, $realtime );
        if ( T_SCLK_P - T_SIO7_2 < tDVCH_DTR_166R && DTR_166R_Chk && OPI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] setup time tDVCH_DTR_166R=%f ns, tDVCH timing violation at %f \n", tDVCH_DTR_166R, $realtime );


        //tCL_SPI
        if ( T_SCLK_P - T_SCLK_N < tCL_SPI && SPI_Mode_Chk_W && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum SCLK Low time tCL_SPI=%f ns, tCL timing violation at %f \n", tCL_SPI, $realtime );
        //tCL_OPI
        if ( T_SCLK_P - T_SCLK_N < tCL_OPI && OPI_Mode_Chk_W && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum SCLK Low time tCL_OPI=%f ns, tCL timing violation at %f \n", tCL_OPI, $realtime );
        //tCL_R
        if ( T_SCLK_P - T_SCLK_N < tCL_R && Read_1XIO_Chk && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum SCLK Low time tCL=%f ns, tCL timing violation at %f \n", tCL_R, $realtime );

        #0;
        // tSLCH
        if ( T_SCLK_P - T_CS_N < tSLCH && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# active setup time tSLCH=%f ns, tSLCH timing violation at %f \n", tSLCH, $realtime );

        // tSHCH
        if ( T_SCLK_P - T_CS_P < tSHCH_STR && !DOPI && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# not active setup time tSHCH_STR=%f ns, tSHCH_STR timing violation at %f \n", tSHCH_STR, $realtime );
        if ( T_SCLK_P - T_CS_P < tSHCH_DTR && DOPI && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# not active setup time tSHCH_DTR=%f ns, tSHCH_DTR timing violation at %f \n", tSHCH_DTR, $realtime );

    end

    always @ ( negedge SCLK ) begin
        T_SCLK_N = $realtime;
        #0; 
        //tDVCL for SIO[0]
        if ( T_SCLK_N - T_SI < tDVCL_DTR_100L && DTR_100L_Chk && SI_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] setup time tDVCL_DTR_100L=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_100L, $realtime );
        if ( T_SCLK_N - T_SI < tDVCL_DTR_133L && DTR_133L_Chk && SI_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] setup time tDVCL_DTR_133L=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_133L, $realtime );
        if ( T_SCLK_N - T_SI < tDVCL_DTR_166L && DTR_166L_Chk && SI_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] setup time tDVCL_DTR_166L=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_166L, $realtime );
        if ( T_SCLK_N - T_SI < tDVCL_DTR_166R && DTR_166R_Chk && SI_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] setup time tDVCL_DTR_166R=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_166R, $realtime );

        //tDVCL for SIO[1]
        if ( T_SCLK_N - T_SO < tDVCL_DTR_100L && DTR_100L_Chk && SO_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] setup time tDVCL_DTR_100L=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_100L, $realtime );
        if ( T_SCLK_N - T_SO < tDVCL_DTR_133L && DTR_133L_Chk && SO_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] setup time tDVCL_DTR_133L=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_133L, $realtime );
        if ( T_SCLK_N - T_SO < tDVCL_DTR_166L && DTR_166L_Chk && SO_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] setup time tDVCL_DTR_166L=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_166L, $realtime );
        if ( T_SCLK_N - T_SO < tDVCL_DTR_166R && DTR_166R_Chk && SO_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] setup time tDVCL_DTR_166R=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_166R, $realtime );

        //tDVCL for SIO[7:2]
        if ( T_SCLK_N - T_SIO7_2 < tDVCL_DTR_100L && DTR_100L_Chk && OPI_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] setup time tDVCL_DTR_100L=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_100L, $realtime );
        if ( T_SCLK_N - T_SIO7_2 < tDVCL_DTR_133L && DTR_133L_Chk && OPI_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] setup time tDVCL_DTR_133L=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_133L, $realtime );
        if ( T_SCLK_N - T_SIO7_2 < tDVCL_DTR_166L && DTR_166L_Chk && OPI_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] setup time tDVCL_DTR_166L=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_166L, $realtime );
        if ( T_SCLK_N - T_SIO7_2 < tDVCL_DTR_166R && DTR_166R_Chk && OPI_IN_EN && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] setup time tDVCL_DTR_166R=%f ns, tDVCL timing violation at %f \n", tDVCL_DTR_166R, $realtime );



        //tCH_SPI
        if ( T_SCLK_N - T_SCLK_P < tCH_SPI && SPI_Mode_Chk_W && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum SCLK High time tCH_SPI=%f ns, tCH timing violation at %f \n", tCH_SPI, $realtime );
        //tCH_OPI
        if ( T_SCLK_N - T_SCLK_P < tCH_OPI && OPI_Mode_Chk_W && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum SCLK High time tCH_OPI=%f ns, tCH timing violation at %f \n", tCH_OPI, $realtime );
        //tCH_R
        if ( T_SCLK_N - T_SCLK_P < tCH_R && Read_1XIO_Chk && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum SCLK High time tCH=%f ns, tCH timing violation at %f \n", tCH_R, $realtime );


    end


    always @ ( SIO[0] ) begin
        T_SI = $realtime; 
        if ( SCLK == 1 )       T_SI_H = $realtime;
        else if ( SCLK == 0 )  T_SI_L = $realtime;
        #0;  
        //tCHDX
        if ( T_SI - T_SCLK_P < tCHDX_STR_133L && STR_133L_Chk && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] hold time tCHDX_STR_133L=%f ns, tCHDX timing violation at %f \n", tCHDX_STR_133L, $realtime );
        if ( T_SI - T_SCLK_P < tCHDX_STR_133R && STR_133R_Chk && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] hold time tCHDX_STR_133R=%f ns, tCHDX timing violation at %f \n", tCHDX_STR_133R, $realtime );
        if ( T_SI - T_SCLK_P < tCHDX_DTR_100L && DTR_100L_Chk && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] hold time tCHDX_DTR_100L=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_100L, $realtime );
        if ( T_SI - T_SCLK_P < tCHDX_DTR_133L && DTR_133L_Chk && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] hold time tCHDX_DTR_133L=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_133L, $realtime );
        if ( T_SI - T_SCLK_P < tCHDX_DTR_166L && DTR_166L_Chk && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] hold time tCHDX_DTR_166L=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_166L, $realtime );
        if ( T_SI - T_SCLK_P < tCHDX_DTR_166R && DTR_166R_Chk && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] hold time tCHDX_DTR_166R=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_166R, $realtime );

        //tCLDX
        if ( T_SI - T_SCLK_N < tCLDX_DTR_100L && DTR_100L_Chk && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] hold time tCLDX_DTR_100L=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_100L, $realtime );
        if ( T_SI - T_SCLK_N < tCLDX_DTR_133L && DTR_133L_Chk && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] hold time tCLDX_DTR_133L=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_133L, $realtime );
        if ( T_SI - T_SCLK_N < tCLDX_DTR_166L && DTR_166L_Chk && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] hold time tCLDX_DTR_166L=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_166L, $realtime );
        if ( T_SI - T_SCLK_N < tCLDX_DTR_166R && DTR_166R_Chk && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] hold time tCLDX_DTR_166R=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_166R, $realtime );
        //tDVCH + tCHDX
        if ( T_SI_H - T_SI_L < tDV && SCLK == 1 && DOPI && SI_IN_EN && T_SI_H > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] valid time tDVCH + tCHDX=%f ns, tDVCH + tCHDX timing violation at %f \n", tDV, $realtime );
        //tDVCL + tCLDX
        if ( T_SI_L - T_SI_H < tDV && SCLK == 0 && DOPI && SI_IN_EN && T_SI_L > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[0] valid time tDVCL + tCLDX=%f ns, tDVCL + tCLDX timing violation at %f \n", tDV, $realtime );
    end

    always @ ( SIO[1] ) begin
        T_SO = $realtime; 
        if ( SCLK == 1 )       T_SO_H = $realtime;
        else if ( SCLK == 0 )  T_SO_L = $realtime;
        #0;  
        //tCHDX
        if ( T_SO - T_SCLK_P < tCHDX_STR_133L && STR_133L_Chk && SO_IN_EN && T_SO > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] hold time tCHDX_STR_133L=%f ns, tCHDX timing violation at %f \n", tCHDX_STR_133L, $realtime );
        if ( T_SO - T_SCLK_P < tCHDX_STR_133R && STR_133R_Chk && SO_IN_EN && T_SO > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] hold time tCHDX_STR_133R=%f ns, tCHDX timing violation at %f \n", tCHDX_STR_133R, $realtime );
        if ( T_SO - T_SCLK_P < tCHDX_DTR_100L && DTR_100L_Chk && SO_IN_EN && T_SO > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] hold time tCHDX_DTR_100L=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_100L, $realtime );
        if ( T_SO - T_SCLK_P < tCHDX_DTR_133L && DTR_133L_Chk && SO_IN_EN && T_SO > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] hold time tCHDX_DTR_133L=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_133L, $realtime );
        if ( T_SO - T_SCLK_P < tCHDX_DTR_166L && DTR_166L_Chk && SO_IN_EN && T_SO > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] hold time tCHDX_DTR_166L=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_166L, $realtime );
        if ( T_SO - T_SCLK_P < tCHDX_DTR_166R && DTR_166R_Chk && SO_IN_EN && T_SO > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] hold time tCHDX_DTR_166R=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_166R, $realtime );
        //tCLDX
        if ( T_SO - T_SCLK_N < tCLDX_DTR_100L && DTR_100L_Chk && SO_IN_EN && T_SO > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] hold time tCLDX_DTR_100L=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_100L, $realtime );
        if ( T_SO - T_SCLK_N < tCLDX_DTR_133L && DTR_133L_Chk && SO_IN_EN && T_SO > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] hold time tCLDX_DTR_133L=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_133L, $realtime );
        if ( T_SO - T_SCLK_N < tCLDX_DTR_166L && DTR_166L_Chk && SO_IN_EN && T_SO > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] hold time tCLDX_DTR_166L=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_166L, $realtime );
        if ( T_SO - T_SCLK_N < tCLDX_DTR_166R && DTR_166R_Chk && SO_IN_EN && T_SO > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] hold time tCLDX_DTR_166R=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_166R, $realtime );

        //tDVCH + tCHDX
        if ( T_SO_H - T_SO_L < tDV && SCLK == 1 && DOPI && SO_IN_EN && T_SO_H > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] valid time tDVCH + tCHDX=%f ns, tDVCH + tCHDX timing violation at %f \n", tDV, $realtime );
        //tDVCL + tCLDX
        if ( T_SO_L - T_SO_H < tDV && SCLK == 0 && DOPI && SO_IN_EN && T_SO_L > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[1] valid time tDVCL + tCLDX=%f ns, tDVCL + tCLDX timing violation at %f \n", tDV, $realtime );
    end

    always @ ( SIO[7:2] ) begin
        T_SIO7_2 = $realtime; 
        if ( SCLK == 1 )       T_SIO7_2_H = $realtime;                    
        else if ( SCLK == 0 )  T_SIO7_2_L = $realtime;                    
        #0;  
        //tCHDX
        if ( T_SIO7_2 - T_SCLK_P < tCHDX_STR_133L && STR_133L_Chk && OPI_IN_EN && T_SIO7_2 > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] hold time tCHDX_STR_133L=%f ns, tCHDX timing violation at %f \n", tCHDX_STR_133L, $realtime );
        if ( T_SIO7_2 - T_SCLK_P < tCHDX_STR_133R && STR_133R_Chk && OPI_IN_EN && T_SIO7_2 > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] hold time tCHDX_STR_133R=%f ns, tCHDX timing violation at %f \n", tCHDX_STR_133R, $realtime );
        if ( T_SIO7_2 - T_SCLK_P < tCHDX_DTR_100L && DTR_100L_Chk && OPI_IN_EN && T_SIO7_2 > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] hold time tCHDX_DTR_100L=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_100L, $realtime );
        if ( T_SIO7_2 - T_SCLK_P < tCHDX_DTR_133L && DTR_133L_Chk && OPI_IN_EN && T_SIO7_2 > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] hold time tCHDX_DTR_133L=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_133L, $realtime );
        if ( T_SIO7_2 - T_SCLK_P < tCHDX_DTR_166L && DTR_166L_Chk && OPI_IN_EN && T_SIO7_2 > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] hold time tCHDX_DTR_166L=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_166L, $realtime );
        if ( T_SIO7_2 - T_SCLK_P < tCHDX_DTR_166R && DTR_166R_Chk && OPI_IN_EN && T_SIO7_2 > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] hold time tCHDX_DTR_166R=%f ns, tCHDX timing violation at %f \n", tCHDX_DTR_166R, $realtime );
        //tCLDX
        if ( T_SIO7_2 - T_SCLK_N < tCLDX_DTR_100L && DTR_100L_Chk && OPI_IN_EN && T_SIO7_2 > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] hold time tCLDX_DTR_100L=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_100L, $realtime );
        if ( T_SIO7_2 - T_SCLK_N < tCLDX_DTR_133L && DTR_133L_Chk && OPI_IN_EN && T_SIO7_2 > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] hold time tCLDX_DTR_133L=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_133L, $realtime );
        if ( T_SIO7_2 - T_SCLK_N < tCLDX_DTR_166L && DTR_166L_Chk && OPI_IN_EN && T_SIO7_2 > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] hold time tCLDX_DTR_166L=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_166L, $realtime );
        if ( T_SIO7_2 - T_SCLK_N < tCLDX_DTR_166R && DTR_166R_Chk && OPI_IN_EN && T_SIO7_2 > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] hold time tCLDX_DTR_166R=%f ns, tCLDX timing violation at %f \n", tCLDX_DTR_166R, $realtime );
        //tDVCH + tCHDX
        if ( T_SIO7_2_H - T_SIO7_2_L < tDV && SCLK == 1 && DOPI && OPI_IN_EN && T_SIO7_2_H > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] valid time tDVCH + tCHDX=%f ns, tDVCH + tCHDX timing violation at %f \n", tDV, $realtime );
        //tDVCL + tCLDX
        if ( T_SIO7_2_L - T_SIO7_2_H < tDV && SCLK == 0 && DOPI && OPI_IN_EN && T_SIO7_2_L > 0 )
            $fwrite (AC_Check_File, "minimum Data SIO[7:2] valid time tDVCL + tCLDX=%f ns, tDVCL + tCLDX timing violation at %f \n", tDV, $realtime );
    end

    always @ ( posedge CS ) begin
        T_CS_P = $realtime;
        #0;  
        // tCHSH 
        if ( T_CS_P - T_SCLK_P < tCHSH && !DOPI && T_CS_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# active hold time STR tCHSH=%f ns, tCHSH timing violation at %f \n", tCHSH, $realtime );
        // tCLSH 
        if ( T_CS_P - T_SCLK_N < tCLSH && DOPI && T_CS_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# active hold time DTR tCLSH=%f ns, tCLSH timing violation at %f \n", tCLSH, $realtime );
       // tRH
       if ( T_CS_P - T_RESET_N < tRH  && T_CS_P > 0 )
            $fwrite (AC_Check_File, "minimum hold time tRH=%f ns, tRH timing violation at %f \n", tRH, $realtime );
    end

    always @ ( negedge CS ) begin
        T_CS_N = $realtime;
        #0;
        //tCHSL
        if ( T_CS_N - T_SCLK_P < tCHSL  && T_CS_N > 0 )
            $fwrite (AC_Check_File, "minimum CS# not active hold time tCHSL=%f ns, tCHSL timing violation at %f \n", tCHSL, $realtime );
        //tSHSL
        if ( T_CS_N - T_CS_P < tSHSL_R && T_CS_N > 0 && Read_SHSL)
            $fwrite (AC_Check_File, "minimum CS# deselect  time tSHSL_R=%f ns, tSHSL timing violation at %f \n", tSHSL_R, $realtime );
        if ( T_CS_N - T_CS_P < tSHSL_W && T_CS_N > 0 && Write_SHSL)
            $fwrite (AC_Check_File, "minimum CS# deselect  time tSHSL_W=%f ns, tSHSL timing violation at %f \n", tSHSL_W, $realtime );

        //tDP
        if ( T_CS_N - T_CS_P < tDP && T_CS_N > 0 && tDP_Chk)
            $fwrite (AC_Check_File, "when transit from Standby Mode to Deep-Power Mode, CS# must remain high for at least tDP =%f ns, tDP timing violation at %f \n", tDP, $realtime );


        //tRES1/2
        if ( T_CS_N - T_CS_P < tRES1 && T_CS_N > 0 && tRES1_Chk)
            $fwrite (AC_Check_File, "when transit from Deep-Power Mode to Standby Mode, CS# must remain high for at least tRES1 =%f ns, tRES1 timing violation at %f \n", tRES1, $realtime );

        //tRHSL
        if ( T_CS_N - T_RESET_P < tRHSL && T_CS_N > 0 )
            $fwrite (AC_Check_File, "minimum Reset# high before CS# low time tRHSL=%f ns, tRHSL timing violation at %f \n", tRHSL, $realtime );
    end

    always @ ( negedge RESETB_INT ) begin
        T_RESET_N = $realtime;
        #0;
        //tRS
        if ( (T_RESET_N - T_CS_P < tRS) && T_RESET_N > 0 )
            $fwrite (AC_Check_File, "minimum setup time tRS=%f ns, tRS timing violation at %f \n", tRS, $realtime );
    end

    always @ ( posedge RESETB_INT ) begin
        T_RESET_P = $realtime;
        #0;
        //tRLRH
        if ( (T_RESET_P - T_RESET_N < tRLRH) && T_RESET_P > 0 )
            $fwrite (AC_Check_File, "minimum reset pulse width tRLRH=%f ns, tRLRH timing violation at %f \n", tRLRH, $realtime );
    end



endmodule






