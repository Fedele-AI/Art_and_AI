# -*- coding: utf-8 -*-
"""
SFTP_sender.py: Python server for MuseLSL + OSC to send data to a client via SSH/SFTP.

This script provides functionality to send a file to a remote server using the SFTP protocol over an SSH connection. 
It reads SSH connection details from a JSON configuration file and handles the connection, file transfer, 
and connection closure.

Author: Alex Jenkins (https://alexj.io) for CEE4803/LMC4813
"""
import json
import paramiko

def send_file(file_path, remote_path):
    """
    Sends the specified file to the remote server via SFTP.

    This function establishes an SSH connection to a remote server, opens an SFTP channel, 
    transfers the specified file to the remote server, and then closes the SFTP channel and 
    the SSH connection. It loads the SSH connection parameters (hostname, port, username, password) 
    from a JSON configuration file named "ssh_config.json".

    Args:
        file_path (str): The local path to the file that should be sent.
        remote_path (str): The directory path on the remote server where the file will be placed.
                           Note: the filename will be appended to this path.

    Raises:
        FileNotFoundError: If the "ssh_config.json" file does not exist.
        json.JSONDecodeError: If the "ssh_config.json" file is not valid JSON.
        paramiko.ssh_exception.SSHException: If there is an error during the SSH connection process.
        Exception: For other general exceptions that might occur during the SFTP or SSH process.

    Example:
        To send a file named 'data.txt' to the '/data/uploads/' directory on the remote server:
        send_file('data.txt', '/data/uploads/')
    """
    # Load SSH parameters from JSON
    try:
        with open("ssh_config.json", "r") as config_file:
            config = json.load(config_file)
    except FileNotFoundError:
        print("Error: ssh_config.json not found.")
        raise
    except json.JSONDecodeError:
        print("Error: Invalid JSON format in ssh_config.json.")
        raise
    
    hostname = config["hostname"]
    port = config["port"]
    username = config["username"]
    password = config["password"]

    # Establish SSH connection
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        client.connect(hostname, port, username, password)
        print(f"Connected to {hostname}")

        # Use SFTP to transfer the file
        sftp = client.open_sftp()
        #appends the filename to the end of the remote path
        remote_path = f"{remote_path}{file_path}" 
        sftp.put(file_path, remote_path)
        sftp.close()

        # Close the connection
        client.close()
        print(f"File sent successfully to {remote_path} via SFTP.")

    except Exception as e:
        print(f"SFTP/SSH Connection to {remote_path} failed: {e}")

if __name__ == "__main__":
    send_file("test_send.txt", "/home/hice1/kjenkins60/scratch/")
