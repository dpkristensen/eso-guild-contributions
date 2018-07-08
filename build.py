#!/usr/bin/env python
"""
    Addon build script

    Copyright 2018 okulo
"""

import os
import re
import unicodedata
import zipfile

TOP_DIR = os.getcwd()
ADDON_NAME = os.path.basename(TOP_DIR)
ADDON_DIR = os.path.join(TOP_DIR, "Addon")
ADDON_INF_FILE = os.path.join(ADDON_DIR, ADDON_NAME + ".txt")

# Generate the build header in the addon directory so the addon folder can be used directly as
# the addon folder via symbolic link.
BUILD_HEADER_FILE = os.path.join(ADDON_DIR, "build.lua")

GENERATED_FILES = [
    BUILD_HEADER_FILE
    ]

SUPPLEMENTARY_FILES = [
    "LICENSE"
    ]


def add_dir_files(root_dir, zip_fh):
    """
        Add files in a directory to a zip file

        @param root_dir The root directory to find all the files in
        @param zip_fh Open zipfile handle
    """
    cur_dir = os.getcwd()
    os.chdir(root_dir)
    log("")
    log("Adding files from " + root_dir + ":")
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            filename = os.path.join(root, file)
            filename = os.path.relpath(filename, root_dir)
            log( "    " + filename)
            zip_fh.write(filename)
    os.chdir(cur_dir)

def log( msg ):
    global logfile

    """
        Log data to stdout and the log file

        @param msg Message to log
    """
    if not ( "logfile" in globals()):
        logfile = open( file="build.log", mode="wt" )

    logfile.write( msg + "\n" )
    print( msg )


def get_addon_info(inf_file_name):
    """
        Get info about an addon

        @param inf_file_name The file name which contains the information about the addon)
        @return Dictionary of pairs describing the addon
        @returntype dict
    """
    info = dict()
    param_re = re.compile(u"## (.+): (.+)", re.UNICODE)
    any_re = re.compile(u"(.*)", re.UNICODE)
    with open(inf_file_name, "rt") as fh:
        for line in fh.readlines():
            utf8line = unicodedata.normalize("NFKC", line.strip()).encode('utf8')
            # must be decoded to pass to re, since it requires str type instead of bytes
            utf8string = utf8line.decode('utf8')
            s = param_re.search(utf8string)
            if s:
                key = s.group(1)
                value = s.group(2)
                info[key]=value
    return info


def main():
    """
        Run the build steps
    """
    global GENERATED_FILES

    log("Building addon: " + ADDON_NAME)
    info = get_addon_info(ADDON_INF_FILE)

    OUT_FILE = os.path.join(TOP_DIR, ADDON_NAME + "-" + info["Version"] + ".zip")
    GENERATED_FILES += [OUT_FILE]

    for filename in GENERATED_FILES:
        if os.access(filename, os.F_OK):
            log( "Removing " + filename )
            os.remove(filename)

    write_dict_lua_file(info, BUILD_HEADER_FILE, ADDON_NAME + "_BUILD")

    with zipfile.ZipFile(file=OUT_FILE, mode="w", compression=zipfile.ZIP_DEFLATED) as zip_fh:
        add_dir_files(ADDON_DIR, zip_fh)
        for filename in SUPPLEMENTARY_FILES:
            zip_fh.write(filename)


def write_dict_lua_file(obj, filename, table_name):
    """
        Write a dictionary to an LUA source file

        @param obj Dictionary object to write
        @paramtype obj dict
        @param filename Filename to generate
        @param table_name Name of the global table to put the dict in
        @paramtype str
    """
    log("")
    log("Generating LUA table for {:s} in {:s}:".format( table_name, filename ))

    # Write to a temp file and rename to make the file I/O atomic
    temp_file = filename + ".tmp"

    with open(file=temp_file, mode="wt", encoding="utf8") as fh:
        fh.write("-- THIS FILE IS GENERATED, DO NOT MODIFY\n")
        fh.write("\n")
        fh.write(table_name + " = {\n")
        for k,v in sorted(obj.items()):
            pair_text = "    " + k + " = \"" + v + "\""
            log(pair_text)
            fh.write(pair_text + ",\n")
        fh.write("}\n")
        fh.flush()
        os.fsync(fh.fileno())
    os.rename(temp_file, filename)

if __name__ == "__main__":
    main()