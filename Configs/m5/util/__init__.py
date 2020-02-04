import os
import sys

def addToPath(path):
    """Prepend directory to system module search path"""
    
    # if relative path
    if not os.path.isabs(path) and sys.path[0]:
        path = os.path.join(sys.path[0], path)
    path = os.path.realpath(path)

    sys.path.insert(1, path)