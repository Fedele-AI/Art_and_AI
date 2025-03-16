# -*- coding: utf-8 -*-
"""
SFTP_listner.py: Python script to monitor a directory for new files.

This script continuously monitors a specified local directory for the addition of new files.
When a new file is detected, it prints a message indicating the new file(s) and 
it was intended to run another script (e.g., "demo.py") to process the new data, 
although that part of the functionality is currently a work in progress.

The script uses a polling mechanism, checking the directory at regular intervals 
(defined by 'poll_interval') for any changes in the file list.

Author: Alex Jenkins (https://alexj.io) for CEE4803/LMC4813
"""
import time
import subprocess
import os

def listen_for_files(local_path, poll_interval=2.5):
    """
    Monitors a local directory for new files and (optionally) executes a command.

    This function continuously polls a specified directory to detect the addition of new files.
    Upon detection of new files, it prints the names of the new files to the console.
    It is designed to allow further processing of the new files (e.g., running a separate script),
    but that functionality is currently commented out.

    Args:
        local_path (str): The path to the local directory to monitor.
        poll_interval (float, optional): The time in seconds between checks of the directory.
                                          Defaults to 2.5 seconds.

    Raises:
        FileNotFoundError: If the specified `local_path` does not exist.
        PermissionError: If the script does not have the necessary permissions to read the specified `local_path`

    Example:
        To monitor the '/data/incoming/' directory, with a 5-second poll interval:
        listen_for_files('/data/incoming/', poll_interval=5)
    """
    if not os.path.exists(local_path):
        raise FileNotFoundError(f"The directory '{local_path}' does not exist.")

    if not os.access(local_path, os.R_OK):
        raise PermissionError(f"The script does not have permission to read the directory '{local_path}'.")

    print(f"Listening for files in {local_path}...")

    existing_files = set(os.listdir(local_path))

    while True:
        current_files = set(os.listdir(local_path))
        new_files = current_files - existing_files

        if new_files:
            print(f"New file(s) detected: {new_files}. Running demo.py...")
            subprocess.run(["python", "demo.py"], check=True)  #This will run the demo script each time a new file is added.

        existing_files = current_files
        time.sleep(poll_interval)

if __name__ == "__main__":
    listen_for_files("/home/hice1/kjenkins60/scratch/")
