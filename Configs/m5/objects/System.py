
class System():
    #A full System

    def __init__(self):

        # Empty Clock Domain
        self.clk_domain = None

        # Empty memory containers
        self.memories = []
        self.mem_mode = None
        self.mem_ranges = []
        self.mem_ctrl = None
        self.system_port = None

        # Empty CPU containers
        self.cpu = None
        self.membus = None

        # Cache containers
        self.l2bus = None
        self.l2cache = None




