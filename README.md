# slotexec
Cluster slot exec mechanism and examples for JARVICE

# Usage example (JSON)

Assumes:
* `/usr/local/bin/jobscript.sh` is the script/command to run on every slot for a given job
* the `slotexec.sh` script has been copied into `/usr/local/bin` in the container

```json

...

"path": "/usr/local/bin/slotexec.sh",
"description": "Runs jobscript.sh on every execution slot for the job",
"name": "slotexec",
"parameters": {
    "global": {
        "name": "global",
        "type": "CONST",
        "value": "-g",
        "required": true,
        "positional": true
    },
    "jobscript": {
        "name": "jobscript",
        "type": "CONST",
        "value": "/usr/local/bin/jobscript.sh",
        "required": true,
        "positional": true
    }
},
"interactive": false

...
```

run `slotexec.sh` without arguments on any shell for full usage

# Additional Notes

* `${JARVICE_JOB_ARRAY_INDEX}` is set automatically to the index of the slot relative to the entire job; if array job submission is supported, it wil be relative to all jobs submitted in the array.
* See `Dockerfile` for a full application container example.
