/* Copyright 2017 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *	http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#ifndef __PRD_FW_MSG_H
#define __PRD_FW_MSG_H

#include <types.h>

/* Messaging structure for the opaque channel between OPAL and HBRT. This
 * format is used for the firmware_request and firmware_notify interfaces
 */
enum {
	PRD_FW_MSG_TYPE_REQ_NOP = 0,
	PRD_FW_MSG_TYPE_RESP_NOP = 1,
};

struct prd_fw_msg {
	__be64		type;
};

#define PRD_FW_MSG_BASE_SIZE	sizeof(__be64)

#endif /* __PRD_FW_MSG_H */
