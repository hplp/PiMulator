//============================================================================
// @(#) $Id: loopback.h 1379 2015-02-17 00:13:20Z jstickle $
//============================================================================

   //_______________________
  // Mentor Graphics, Corp. \_________________________________________________
 //                                                                         //
//   (C) Copyright, Mentor Graphics, Corp. 2003-2014                        //
//   All Rights Reserved                                                    //
//                                                                          //
//    Licensed under the Apache License, Version 2.0 (the                   //
//    "License"); you may not use this file except in                       //
//    compliance with the License.  You may obtain a copy of                //
//    the License at                                                        //
//                                                                          //
//        http://www.apache.org/licenses/LICENSE-2.0                        //
//                                                                          //
//    Unless required by applicable law or agreed to in                     //
//    writing, software distributed under the License is                    //
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR                //
//    CONDITIONS OF ANY KIND, either express or implied.  See               //
//    the License for the specific language governing                      //
//    permissions and limitations under the License.                      //
//-----------------------------------------------------------------------//

#ifndef LOOPBACK_H
#define LOOPBACK_H

#include <string>
#include <iomanip>
//#include <stdlib>
using std::string;

#include <systemc.h>
#include <tlm.h>
using namespace sc_core;
using namespace tlm;

#include "simple_initiator_socket.h"
using tlm_utils::simple_initiator_socket;

#include "simple_target_socket.h"
using tlm_utils::simple_target_socket;

//________________
// class loopback \___________________________________________________________
//----------------------------------------------------------------------------

class loopback : public sc_module {
  public:
    simple_target_socket<loopback> in; // defaults to tlm_gp
    simple_target_socket<loopback> in_config;
    simple_initiator_socket<loopback> out;
    simple_initiator_socket<loopback> out_config;
  
    loopback(sc_module_name nm) :  in("in"), out("out") {
        in.register_b_transport(this, &loopback::b_transport);
        in_config.register_nb_transport_fw(this, &loopback::nb_transport_fw);
    }

    virtual void b_transport(tlm_generic_payload &gp, sc_time &t) {
        out->b_transport( gp, t );
    }

    virtual tlm::tlm_sync_enum nb_transport_fw(
        tlm::tlm_generic_payload &trans,
        tlm::tlm_phase &phase, sc_time &delay ) {
        return out_config->nb_transport_fw( trans, phase, delay );
    }
};

#endif
