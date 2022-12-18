"""
lidos - lido script
"""

import argparse
from zml2lido.lidoTool import LidoTool
from pathlib import Path

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Little LIDO toolchain")
    parser.add_argument(
        "-f", "--force", help="force mode", action="store_true", default=False
    )
    parser.add_argument(
        "-j",
        "--job",
        help="location of jobs.dsl",
        required=True,
    )
    parser.add_argument(
        "-v", "--validate", help="validate lido", action="store_true", default=False
    )
    args = parser.parse_args()

    ls = LidoScript(job_fn=args["job"])


class LidoScript:
    def __init__(self, job_fn):
        self.load_dsl(job_fn=job_fn)
        # load dsl file at default location "jobs.dsl"
        # then we r in project_dir we're not in zml2lido dir

    def load_dsl(self, job_fn):
        with open(job.fn, mode="r") as file:
            for line in file:
                uncomment = line.split("#", 1)[0].strip()
                if uncomment.isspace() or not uncomment:
                    continue
                parts: list[str] = uncomment.split()
                try:
                    parts[1]
                except:
                    chunks = False
                else:
                    if parts[1] == "chunk":
                        chunks = True
                    else:
                        chunks = False

                lidoTool(
                    Input=parts[0], force=force, validation=validation, chunks=chunks
                )
