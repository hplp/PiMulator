class Root():
    def __init__(self, **kwargs):
        if 'full_system' in kwargs:
            self.full_system = kwargs['full_system']
        else:
            self.full_system = None
        
        if 'system' in kwargs:
            self.system = kwargs['system']