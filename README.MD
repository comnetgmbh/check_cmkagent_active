# check_cmkagent_active

## About
This check basically connects to a host running Check_MK agent and dumps it's
output to /var/lib/check_cmkagent, ready to be picked up by thruk-check_cmkagent
and check_cmkagent_local.

## Installation
check_cmkagent_active comes with a Makefile. Just issue
```
# make install
```
to install the check to your system.

You can also remotely install to a system running omd by issuing
```
$ make remote_install HOST=hostname SITE=sitename
```

## Usage
```
check_cmkagent_active <hostname_or_ip>
```

## Author & Copyright
Copyright 2018 Sören Gugel, comNET GmbH <soeren.gugel@comnetgmbh.com>
Copyright 2018 Rika Lena Denia, comNET GmbH <rika.denia@comnetgmbh.com>
