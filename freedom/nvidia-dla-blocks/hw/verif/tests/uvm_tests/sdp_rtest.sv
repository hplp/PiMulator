`ifndef _SDP_RTEST_SV_
`define _SDP_RTEST_SV_

//-------------------------------------------------------------------------------------
// CLASS: sdp_rtest 
//-------------------------------------------------------------------------------------

class sdp_rtest_sdprdma_sdp_scenario extends nvdla_sdprdma_sdp_scenario ;
    function new(string name="sdp_rtest_sdprdma_sdp_scenario", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    constraint sec_sdprdma_sdp_sim_constraint_for_user_extend {
        this.sdp.flying_mode     == nvdla_sdp_resource::flying_mode_OFF;
        this.sdp.output_dst      == nvdla_sdp_resource::output_dst_MEM;
    }
    `uvm_component_utils(sdp_rtest_sdprdma_sdp_scenario)
endclass: sdp_rtest_sdprdma_sdp_scenario

class sdp_rtest extends nvdla_tg_base_test;

    function new(string name="sdp_rtest", uvm_component parent);
        super.new(name, parent);
        set_inst_name("sdp_rtest");
    endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_db#()::get(this,"", "layers", layers);
        `uvm_info(inst_name,$sformatf("Layers = %0d ",layers),UVM_HIGH); 

        set_type_override_by_type(nvdla_sdprdma_sdp_scenario::get_type(), sdp_rtest_sdprdma_sdp_scenario::get_type());
    endfunction: build_phase

    function override_scenario_pool();
         generator.delete_scenario_pool();
         generator.push_scenario_pool(SCE_SDPRDMA_SDP);
    endfunction: override_scenario_pool

    `uvm_component_utils(sdp_rtest)
endclass : sdp_rtest


`endif // _SDP_RTEST_SV_

