#
# Copyright 2018 Rika Lena Denia comNET GmbH <rika.denia@comnetgmbh.com>
#
# This file is part of check_cmkagent.
#
# check_cmkagent is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# check_cmkagent is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with check_cmkagent.  If not, see <http://www.gnu.org/licenses/>.
#

WORKDIR = $(PWD)/tree
#PREFIX ?= /usr/local
PREFIX ?= /omd/sites/$(SITE)
DESTDIR ?= /

PLUGINDIR ?= local/lib/nagios/plugins
SYSCONFDIR ?= etc

FILES = \
	check_cmkagent_active \
	check_cmkagent_active_commands.cfg

all: $(WORKDIR)

$(WORKDIR): $(FILES) Makefile
	# Create directories
	mkdir -p $(WORKDIR)
	mkdir -p $(WORKDIR)/$(PLUGINDIR)
	mkdir -p $(WORKDIR)/$(SYSCONFDIR)/nagios/conf.d
	
	# Copy files
	cp check_cmkagent_active              $(WORKDIR)/$(PLUGINDIR)/check_cmkagent_active
	cp check_cmkagent_active_commands.cfg $(WORKDIR)/$(SYSCONFDIR)/nagios/conf.d/check_cmkagent_active_commands.cfg
	
	# Set permissions
	chmod 755 $(WORKDIR)/$(PLUGINDIR)/check_cmkagent_active
	chmod 644 $(WORKDIR)/$(SYSCONFDIR)/nagios/conf.d/check_cmkagent_active_commands.cfg

#install: $(WORKDIR)
#	rsync -av $(WORKDIR)/ $(DESTDIR)/
#	chown root:root $(DESTDIR)/$(PLUGINDIR)/check_cmkagent_active
#	chown root:root $(DESTDIR)/$(SYSCONFDIR)/nagios/conf.d/check_cmkagent_active_commands.cfg

remote_install: $(WORKDIR)
	[ ! -z "$(HOST)" ] || (echo "Please provide a host to sync to via HOST"; exit 1)
	[ ! -z "$(SITE)" ] || (echo "Please provide a site to sync to via SITE"; exit 1)
	
	# Check
	for i in $$(find $(WORKDIR)/ -type f -printf '%P\n'); do \
		echo "Installing $$i..."; \
		mode="644"; \
		if [ $$(echo "$$i" | sed 's/nagios\/plugin//') != "$$i" ]; then \
			mode="755"; \
		fi; \
		ssh root@$$HOST "cat >/tmp/cmkagent_tmp && install -D -o root -g root -m $$mode /tmp/cmkagent_tmp $(PREFIX)/$$i" < $(WORKDIR)/$$i; \
	done

