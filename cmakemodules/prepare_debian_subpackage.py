#!/usr/bin/python

# This module is preparing/building the debian package for a
# ChimeraTK sub-package.

from subprocess import call
import os
import sys

gitBaseUrl="https://github.com/ChimeraTK"

def prepare_debian_subpackage( package_name, git_repo_name, version ):
  package_directory=package_name+"_"+version
  call(["rm", "-rf", package_directory])
  gitUrl=gitBaseUrl + "/" + git_repo_name
  if call(["git","clone",gitUrl,package_directory]) :
    print( package_name+": could not clone from " + gitUrl )
    sys.exit(1)
  orginal_working_directory=os.getcwd()
  os.chdir(package_directory)
  if call(["git","checkout",version]) :
    print( package_name+": could not check out tag " + version + " of " + git_repo_name )
    os.chdir(orginal_working_directory)
    sys.exit(1)
  os.mkdir("build")
  os.chdir("build")
  if call(["cmake",".."]):
    print( package_name+": error running cmake" )
    os.chdir(orginal_working_directory)
    sys.exit(1)
  if call(["make","debian_package"]):
    print( package_name+": error creating debian package" )
    os.chdir(orginal_working_directory)
    sys.exit(1)
  os.chdir(orginal_working_directory)
