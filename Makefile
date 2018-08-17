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

