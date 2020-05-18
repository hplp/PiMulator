# This is a wrapper class for the DRAMCtrl Class
# that provides a PIM interface

from enum import Enum

# Derived class from DRAMCtrl
# adds PIM functionality to class
class PIMDRAMCtrl(DRAMCtrl):

    # Define PIM interfaces for DRAMCtrl
    class Interface(Enum):
        ARRAY: 1
        BANK: 2
        RANK: 3

    # The Interface Level
    interface_level = None

    # The computational kernel assigned to this interface
    kernel = None

    # Address range assigned to kernel
    address_range = None