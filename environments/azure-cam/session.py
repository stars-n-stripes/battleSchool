import os
import cmd
import azure110
import ssh110
from pyfiglet import figlet_format

"""
session.py
Author: James Lynch
Purpose: This program will accomplish the following tasks:
    1. Listen and accept an SSH connection from a user
    2. Provision an Azure Vulnbox (Win7 with IceCast<=2.0)
    3. Launch an interactive program that steps a user through the cyber-attack lab
"""


def main():

    # Verify requisite environment variables are set
    ssh_server_listen()

    clone_container()

    try:

        build_vulnbox()

        cam_demo()

        destroy_vulnbox()

    except Exception:
        destroy_vulnbox()
        raise Exception


if __name__ == "__main__":
    main()