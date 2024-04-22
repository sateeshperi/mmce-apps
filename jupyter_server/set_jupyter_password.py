from notebook.auth import passwd
import json
import os
import sys

if "JUPYTER_PASS" not in os.environ:
    exit(0)

password = passwd(os.environ["JUPYTER_PASS"])
config_dict = {
    "NotebookApp": {
        "password": password
    }
}
f = open(sys.argv[1], "w")
f.write(json.dumps(config_dict))
f.close()
