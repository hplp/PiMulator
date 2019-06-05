-- Generated and then parameterized with generics
-- IP VLNV: xilinx.com:ip:blk_mem_gen:8.2
-- IP Revision: 0

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY blk_mem_gen_v8_4_1;
USE blk_mem_gen_v8_4_1.blk_mem_gen_v8_4_1;

ENTITY axi_blk_mem IS
  GENERIC (

    C_FAMILY : STRING := "virtex7";
        -- Specify the target architecture type

    C_MEM_DEPTH : INTEGER := 4096;
        --Memory depth specified by the user

    C_MEM_ADDR_WIDTH : INTEGER := 12;
        -- Width of AXI address bus (in bits)

    C_AXI_ID_WIDTH : INTEGER := 4;
        --  AXI ID vector width

    C_AXI_ADDR_WIDTH : INTEGER := 32;
        -- Width of AXI address bus (in bits)

    C_AXI_DATA_WIDTH : INTEGER := 32
        -- Width of AXI data bus (in bits)

  );
  PORT (
    s_aclk : IN STD_LOGIC;
    s_aresetn : IN STD_LOGIC;
    s_axi_awid : IN STD_LOGIC_VECTOR(C_AXI_ID_WIDTH-1 DOWNTO 0);
    s_axi_awaddr : IN STD_LOGIC_VECTOR(C_AXI_ADDR_WIDTH-1 DOWNTO 0);
    s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_awready : OUT STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH-1 DOWNTO 0);
    s_axi_wstrb : IN STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH/8-1 DOWNTO 0);
    s_axi_wlast : IN STD_LOGIC;
    s_axi_wvalid : IN STD_LOGIC;
    s_axi_wready : OUT STD_LOGIC;
    s_axi_bid : OUT STD_LOGIC_VECTOR(C_AXI_ID_WIDTH-1 DOWNTO 0);
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_arid : IN STD_LOGIC_VECTOR(C_AXI_ID_WIDTH-1 DOWNTO 0);
    s_axi_araddr : IN STD_LOGIC_VECTOR(C_AXI_ADDR_WIDTH-1 DOWNTO 0);
    s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_arready : OUT STD_LOGIC;
    s_axi_rid : OUT STD_LOGIC_VECTOR(C_AXI_ID_WIDTH-1 DOWNTO 0);
    s_axi_rdata : OUT STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH-1 DOWNTO 0);
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rlast : OUT STD_LOGIC;
    s_axi_rvalid : OUT STD_LOGIC;
    s_axi_rready : IN STD_LOGIC
  );
END axi_blk_mem;

ARCHITECTURE axi_blk_mem_arch OF axi_blk_mem IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : string;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF axi_blk_mem_arch: ARCHITECTURE IS "yes";


  COMPONENT blk_mem_gen_v8_4_1 IS
    GENERIC (
      C_FAMILY : STRING;
      C_XDEVICEFAMILY : STRING;
      C_ELABORATION_DIR : STRING;
      C_INTERFACE_TYPE : INTEGER;
      C_AXI_TYPE : INTEGER;
      C_AXI_SLAVE_TYPE : INTEGER;
      C_USE_BRAM_BLOCK : INTEGER;
      C_ENABLE_32BIT_ADDRESS : INTEGER;
      C_CTRL_ECC_ALGO : STRING;
      C_HAS_AXI_ID : INTEGER;
      C_AXI_ID_WIDTH : INTEGER;
      C_MEM_TYPE : INTEGER;
      C_BYTE_SIZE : INTEGER;
      C_ALGORITHM : INTEGER;
      C_PRIM_TYPE : INTEGER;
      C_LOAD_INIT_FILE : INTEGER;
      C_INIT_FILE_NAME : STRING;
      C_INIT_FILE : STRING;
      C_USE_DEFAULT_DATA : INTEGER;
      C_DEFAULT_DATA : STRING;
      C_HAS_RSTA : INTEGER;
      C_RST_PRIORITY_A : STRING;
      C_RSTRAM_A : INTEGER;
      C_INITA_VAL : STRING;
      C_HAS_ENA : INTEGER;
      C_HAS_REGCEA : INTEGER;
      C_USE_BYTE_WEA : INTEGER;
      C_WEA_WIDTH : INTEGER;
      C_WRITE_MODE_A : STRING;
      C_WRITE_WIDTH_A : INTEGER;
      C_READ_WIDTH_A : INTEGER;
      C_WRITE_DEPTH_A : INTEGER;
      C_READ_DEPTH_A : INTEGER;
      C_ADDRA_WIDTH : INTEGER;
      C_HAS_RSTB : INTEGER;
      C_RST_PRIORITY_B : STRING;
      C_RSTRAM_B : INTEGER;
      C_INITB_VAL : STRING;
      C_HAS_ENB : INTEGER;
      C_HAS_REGCEB : INTEGER;
      C_USE_BYTE_WEB : INTEGER;
      C_WEB_WIDTH : INTEGER;
      C_WRITE_MODE_B : STRING;
      C_WRITE_WIDTH_B : INTEGER;
      C_READ_WIDTH_B : INTEGER;
      C_WRITE_DEPTH_B : INTEGER;
      C_READ_DEPTH_B : INTEGER;
      C_ADDRB_WIDTH : INTEGER;
      C_HAS_MEM_OUTPUT_REGS_A : INTEGER;
      C_HAS_MEM_OUTPUT_REGS_B : INTEGER;
      C_HAS_MUX_OUTPUT_REGS_A : INTEGER;
      C_HAS_MUX_OUTPUT_REGS_B : INTEGER;
      C_MUX_PIPELINE_STAGES : INTEGER;
      C_HAS_SOFTECC_INPUT_REGS_A : INTEGER;
      C_HAS_SOFTECC_OUTPUT_REGS_B : INTEGER;
      C_USE_SOFTECC : INTEGER;
      C_USE_ECC : INTEGER;
      C_EN_ECC_PIPE : INTEGER;
      C_HAS_INJECTERR : INTEGER;
      C_SIM_COLLISION_CHECK : STRING;
      C_COMMON_CLK : INTEGER;
      C_DISABLE_WARN_BHV_COLL : INTEGER;
      C_EN_SLEEP_PIN : INTEGER;
      C_USE_URAM : INTEGER; -- v8_3_2
      C_EN_RDADDRA_CHG : INTEGER; -- v8_3_2
      C_EN_RDADDRB_CHG : INTEGER; -- v8_3_2
      C_EN_DEEPSLEEP_PIN : INTEGER; -- v8_3_2
      C_EN_SHUTDOWN_PIN : INTEGER; -- v8_3_2
      C_EN_SAFETY_CKT : INTEGER; -- v8_3_2
      C_DISABLE_WARN_BHV_RANGE : INTEGER;
      C_COUNT_36K_BRAM : STRING;
      C_COUNT_18K_BRAM : STRING;
      C_EST_POWER_SUMMARY : STRING
    );
    PORT (
      clka : IN STD_LOGIC;
      rsta : IN STD_LOGIC;
      ena : IN STD_LOGIC;
      regcea : IN STD_LOGIC;
      wea : IN STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH/8-1 DOWNTO 0);
      addra : IN STD_LOGIC_VECTOR(C_MEM_ADDR_WIDTH-1 DOWNTO 0);
      dina : IN STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH-1 DOWNTO 0);
      douta : OUT STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH-1 DOWNTO 0);
      clkb : IN STD_LOGIC;
      rstb : IN STD_LOGIC;
      enb : IN STD_LOGIC;
      regceb : IN STD_LOGIC;
      web : IN STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH/8-1 DOWNTO 0);
      addrb : IN STD_LOGIC_VECTOR(C_MEM_ADDR_WIDTH-1 DOWNTO 0);
      dinb : IN STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH-1 DOWNTO 0);
      doutb : OUT STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH-1 DOWNTO 0);
      injectsbiterr : IN STD_LOGIC;
      injectdbiterr : IN STD_LOGIC;
      eccpipece : IN STD_LOGIC;
      sbiterr : OUT STD_LOGIC;
      dbiterr : OUT STD_LOGIC;
      rdaddrecc : OUT STD_LOGIC_VECTOR(C_MEM_ADDR_WIDTH-1 DOWNTO 0);
      sleep : IN STD_LOGIC;
      deepsleep : IN STD_LOGIC; -- v8_3_2
      shutdown : IN STD_LOGIC; -- v8_3_2
      rsta_busy : OUT STD_LOGIC; -- v8_3_2
      rstb_busy : OUT STD_LOGIC; -- v8_3_2
      s_aclk : IN STD_LOGIC;
      s_aresetn : IN STD_LOGIC;
      s_axi_awid : IN STD_LOGIC_VECTOR(C_AXI_ID_WIDTH-1 DOWNTO 0);
      s_axi_awaddr : IN STD_LOGIC_VECTOR(C_AXI_ADDR_WIDTH-1 DOWNTO 0);
      s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_awvalid : IN STD_LOGIC;
      s_axi_awready : OUT STD_LOGIC;
      s_axi_wdata : IN STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH-1 DOWNTO 0);
      s_axi_wstrb : IN STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH/8-1 DOWNTO 0);
      s_axi_wlast : IN STD_LOGIC;
      s_axi_wvalid : IN STD_LOGIC;
      s_axi_wready : OUT STD_LOGIC;
      s_axi_bid : OUT STD_LOGIC_VECTOR(C_AXI_ID_WIDTH-1 DOWNTO 0);
      s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_bvalid : OUT STD_LOGIC;
      s_axi_bready : IN STD_LOGIC;
      s_axi_arid : IN STD_LOGIC_VECTOR(C_AXI_ID_WIDTH-1 DOWNTO 0);
      s_axi_araddr : IN STD_LOGIC_VECTOR(C_AXI_ADDR_WIDTH-1 DOWNTO 0);
      s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_arvalid : IN STD_LOGIC;
      s_axi_arready : OUT STD_LOGIC;
      s_axi_rid : OUT STD_LOGIC_VECTOR(C_AXI_ID_WIDTH-1 DOWNTO 0);
      s_axi_rdata : OUT STD_LOGIC_VECTOR(C_AXI_DATA_WIDTH-1 DOWNTO 0);
      s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_rlast : OUT STD_LOGIC;
      s_axi_rvalid : OUT STD_LOGIC;
      s_axi_rready : IN STD_LOGIC;
      s_axi_injectsbiterr : IN STD_LOGIC;
      s_axi_injectdbiterr : IN STD_LOGIC;
      s_axi_sbiterr : OUT STD_LOGIC;
      s_axi_dbiterr : OUT STD_LOGIC;
      s_axi_rdaddrecc : OUT STD_LOGIC_VECTOR(C_MEM_ADDR_WIDTH-1 DOWNTO 0)
    );
  END COMPONENT blk_mem_gen_v8_4_1;
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF s_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 CLK.ACLK CLK";
  ATTRIBUTE X_INTERFACE_INFO OF s_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 RST.ARESETN RST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI AWID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI AWADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI AWLEN";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI AWSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI AWBURST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI WLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI BID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI ARID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI ARLEN";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI ARSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI ARBURST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI RID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI RLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI_SLAVE_S_AXI RREADY";
BEGIN
  U0 : blk_mem_gen_v8_4_1
    GENERIC MAP (
      C_FAMILY => C_FAMILY,
      C_XDEVICEFAMILY => C_FAMILY,
      C_ELABORATION_DIR => "NULL", -- "./",
      C_INTERFACE_TYPE => 1,
      C_AXI_TYPE => 1,
      C_AXI_SLAVE_TYPE => 0,
      C_USE_BRAM_BLOCK => 0,
      C_ENABLE_32BIT_ADDRESS => 0,
      C_CTRL_ECC_ALGO => "NONE",
      C_HAS_AXI_ID => 1,
      C_AXI_ID_WIDTH => 1,
      C_MEM_TYPE => 1,
      C_BYTE_SIZE => 8,
      C_ALGORITHM => 1,
      C_PRIM_TYPE => 1,
      C_LOAD_INIT_FILE => 0,
      C_INIT_FILE_NAME => "no_coe_file_loaded",
      C_INIT_FILE => "",
      C_USE_DEFAULT_DATA => 0,
      C_DEFAULT_DATA => "0",
      C_HAS_RSTA => 0,
      C_RST_PRIORITY_A => "CE",
      C_RSTRAM_A => 0,
      C_INITA_VAL => "0",
      C_HAS_ENA => 1,
      C_HAS_REGCEA => 0,
      C_USE_BYTE_WEA => 1,
      C_WEA_WIDTH => C_AXI_DATA_WIDTH/8,
      C_WRITE_MODE_A => "READ_FIRST",
      C_WRITE_WIDTH_A => C_AXI_DATA_WIDTH,
      C_READ_WIDTH_A => C_AXI_DATA_WIDTH,
      C_WRITE_DEPTH_A => C_MEM_DEPTH,
      C_READ_DEPTH_A => C_MEM_DEPTH,
      C_ADDRA_WIDTH => C_MEM_ADDR_WIDTH,
      C_HAS_RSTB => 1,
      C_RST_PRIORITY_B => "CE",
      C_RSTRAM_B => 0,
      C_INITB_VAL => "0",
      C_HAS_ENB => 1,
      C_HAS_REGCEB => 0,
      C_USE_BYTE_WEB => 1,
      C_WEB_WIDTH => C_AXI_DATA_WIDTH/8,
      C_WRITE_MODE_B => "READ_FIRST",
      C_WRITE_WIDTH_B => C_AXI_DATA_WIDTH,
      C_READ_WIDTH_B => C_AXI_DATA_WIDTH,
      C_WRITE_DEPTH_B => C_MEM_DEPTH,
      C_READ_DEPTH_B => C_MEM_DEPTH,
      C_ADDRB_WIDTH => C_MEM_ADDR_WIDTH,
      C_HAS_MEM_OUTPUT_REGS_A => 0,
      C_HAS_MEM_OUTPUT_REGS_B => 0,
      C_HAS_MUX_OUTPUT_REGS_A => 0,
      C_HAS_MUX_OUTPUT_REGS_B => 0,
      C_MUX_PIPELINE_STAGES => 0,
      C_HAS_SOFTECC_INPUT_REGS_A => 0,
      C_HAS_SOFTECC_OUTPUT_REGS_B => 0,
      C_USE_SOFTECC => 0,
      C_USE_ECC => 0,
      C_EN_ECC_PIPE => 0,
      C_HAS_INJECTERR => 0,
      C_SIM_COLLISION_CHECK => "NONE",
      C_COMMON_CLK => 1,
      C_DISABLE_WARN_BHV_COLL => 1,
      C_EN_SLEEP_PIN => 0,
      C_USE_URAM => 0, -- v8_3_2
      C_EN_RDADDRA_CHG => 0, -- v8_3_2
      C_EN_RDADDRB_CHG => 0, -- v8_3_2
      C_EN_DEEPSLEEP_PIN => 0, -- v8_3_2
      C_EN_SHUTDOWN_PIN => 0, -- v8_3_2
      C_EN_SAFETY_CKT => 0, -- v8_3_2
      C_DISABLE_WARN_BHV_RANGE => 1,
      C_COUNT_36K_BRAM => "",
      C_COUNT_18K_BRAM => "",
      C_EST_POWER_SUMMARY => ""
    )
    PORT MAP (
      clka => '0',
      rsta => '0',
      ena => '0',
      regcea => '0',
      wea => (others => '0'),
      addra => (others => '0'),
      dina => (others => '0'),
      clkb => '0',
      rstb => '0',
      enb => '0',
      regceb => '0',
      web => (others => '0'),
      addrb => (others => '0'),
      dinb => (others => '0'),
      injectsbiterr => '0',
      injectdbiterr => '0',
      eccpipece => '0',
      sleep => '0',
      deepsleep => '0', -- v8_3_2
      shutdown => '0', -- v8_3_2
      s_aclk => s_aclk,
      s_aresetn => s_aresetn,
      s_axi_awid => s_axi_awid,
      s_axi_awaddr => s_axi_awaddr,
      s_axi_awlen => s_axi_awlen,
      s_axi_awsize => s_axi_awsize,
      s_axi_awburst => s_axi_awburst,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,
      s_axi_wdata => s_axi_wdata,
      s_axi_wstrb => s_axi_wstrb,
      s_axi_wlast => s_axi_wlast,
      s_axi_wvalid => s_axi_wvalid,
      s_axi_wready => s_axi_wready,
      s_axi_bid => s_axi_bid,
      s_axi_bresp => s_axi_bresp,
      s_axi_bvalid => s_axi_bvalid,
      s_axi_bready => s_axi_bready,
      s_axi_arid => s_axi_arid,
      s_axi_araddr => s_axi_araddr,
      s_axi_arlen => s_axi_arlen,
      s_axi_arsize => s_axi_arsize,
      s_axi_arburst => s_axi_arburst,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arready => s_axi_arready,
      s_axi_rid => s_axi_rid,
      s_axi_rdata => s_axi_rdata,
      s_axi_rresp => s_axi_rresp,
      s_axi_rlast => s_axi_rlast,
      s_axi_rvalid => s_axi_rvalid,
      s_axi_rready => s_axi_rready,
      s_axi_injectsbiterr => '0',
      s_axi_injectdbiterr => '0'
    );
END axi_blk_mem_arch;
