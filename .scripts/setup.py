#!/usr/bin/env python3
"""Port of the original `setup.sh` to Python.

This script keeps the same behavior: if there's no host_vars for the current
hostname, it copies the example, renames files, runs the YAML updater, appends
hostname, updates `inventories/inventory.yml`, sets the system hostname, sets
up vault key (by invoking the existing `setup-vault-key.sh`) and attempts to
kill unattended-upgrade processes.

It uses the local `yaml_updater.py` (added alongside this script).
"""
import os
import shutil
import subprocess
import sys


def run(cmd, check=True, **kwargs):
    return subprocess.run(cmd, check=check, **kwargs)


def main():
    hostname = subprocess.check_output(['hostname'], text=True).strip()
    inventories_file_path = './inventories/inventory.yml'
    inventory_path = f'./inventories/host_vars/{hostname}'
    example_path = './inventories/host_vars/.example'

    if not os.path.exists(inventory_path):
        print(f"No inventory found for hostname '{hostname}' in path {inventory_path}")
        newhostname = input('Please enter a new hostname: ').strip()

        if not os.path.isdir(example_path):
            print('Error: Example inventory folder not found. Exiting.')
            sys.exit(1)

        new_inventory_path = f'./inventories/host_vars/{newhostname}'
        shutil.copytree(example_path, new_inventory_path)

        src = os.path.join(new_inventory_path, 'host_vars', 'example.yml')
        dst = os.path.join(new_inventory_path, 'host_vars', f'{newhostname}.yml')
        if os.path.exists(src):
            os.rename(src, dst)

        host_vars_file = dst

        # Run the Python yaml updater on the new host vars file
        py_updater = os.path.join(os.path.dirname(__file__), 'yaml_updater.py')
        try:
            run([sys.executable, py_updater, host_vars_file])
        except subprocess.CalledProcessError as e:
            print(f"Error: yaml_updater.py failed for '{host_vars_file}' (exit {e.returncode}).")
            print("See above output from the updater for details.")
            sys.exit(e.returncode)

        print(f"New inventory created for hostname '{newhostname}' at '{new_inventory_path}'.")
        with open(host_vars_file, 'a', encoding='utf-8') as f:
            f.write('\n')
            f.write(f'hostname: {newhostname}\n')

        new_entry = f"        {newhostname}:"
        print(f"Adding '{new_entry}' to {inventories_file_path} to ensure the group vars are usable")
        # Ensure the inventories file contains the entry
        if os.path.exists(inventories_file_path):
            with open(inventories_file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            if new_entry not in content:
                with open(inventories_file_path, 'a', encoding='utf-8') as f:
                    f.write('\n' + new_entry + '\n')

        print('Setting up hostname')
        try:
            run(['sudo', 'hostname', newhostname])
        except subprocess.CalledProcessError:
            print('Warning: failed to set hostname (needs sudo privileges).')

        print(f"Now check again which role you want to enable in the file: {host_vars_file}")

    host_vars_file = f"./inventories/host_vars/{subprocess.check_output(['hostname'], text=True).strip()}/host_vars/{subprocess.check_output(['hostname'], text=True).strip()}.yml"
    print(f"Setting up vault key file based on host vars file: {host_vars_file}")
    print(f"Starting setup vault with user: {os.environ.get('USER','')}")

    # Call existing shell script for vault key setup (not converted here)
    vault_script = os.path.join(os.path.dirname(__file__), 'setup-vault-key.sh')
    if os.path.exists(vault_script):
        try:
            run([vault_script, os.environ.get('USER','')])
        except subprocess.CalledProcessError:
            print('Warning: setup-vault-key.sh failed or returned non-zero status.')
    else:
        print('Warning: setup-vault-key.sh not found; skipping vault setup.')

    # Try to find unattended-upgrade processes and kill them as the original did
    try:
        pgrep = subprocess.check_output(['pgrep', '-f', 'unattended-upgrade'], text=True).strip()
    except subprocess.CalledProcessError:
        pgrep = ''

    if pgrep:
        pids = [p for p in pgrep.split() if p.strip()]
        print('Unattended-upgrade processes found with PIDs:', ' '.join(pids))
        print('Attempting to kill each process...')
        for pid in pids:
            try:
                print(f'Killing process with PID: {pid}')
                run(['sudo', 'kill', '-9', pid])
                print(f'Process {pid} killed successfully.')
            except subprocess.CalledProcessError:
                print(f'Warning: failed to kill PID {pid}.')
    else:
        print('No unattended-upgrade process running.')


if __name__ == '__main__':
    main()
