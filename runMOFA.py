import subprocess
import yaml
import argparse

parser = argparse.ArgumentParser(description="Run MOFA pipeline")
parser.add_argument(
    "--config", 
    type=str, 
    required=True, 
    help="Path to the YAML config file"
)
args = parser.parse_args()

with open(args.config, "r") as f:
    config = yaml.safe_load(f)

rscript_path = config["r_path"]
r_script = "runMOFA.R"

try:
    print("Start Running MOFA R script ....")
    subprocess.run([rscript_path, r_script], check=True)
    print("MOFA R script executed successfully.")
except subprocess.CalledProcessError as e:
    print("Error while running MOFA R script:", e)
