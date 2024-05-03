#
# Build variables
#
SRCNAME = asl-apt-repos
PKGNAME = $(SRCNAME)
RELVER = 1.3
DEBVER = 1
RELPLAT ?= deb$(shell lsb_release -rs 2> /dev/null)

ifdef ${DESTDIR}
DESTDIR=${DESTDIR}
endif


default:
	@echo This does nothing 

install: $(DESTDIR)/etc/apt/keyrings/allstarlink.gpg \
	$(DESTDIR)/etc/apt/sources.list.d/allstarlink.list

$(DESTDIR)/etc/apt/keyrings/%: %
	install -D -m 0644 $< $@

$(DESTDIR)/etc/apt/sources.list.d/%: %
	install -D -m 0644 $< $@
	perl -pi -e "s/__DREL__/$(DREL)/g" $@

deb:	debclean debprep
	debchange --distribution stable --package $(PKGNAME) \
        --newversion $(EPOCHVER)$(RELVER)-$(DEBVER).$(RELPLAT) \
        "Autobuild of $(EPOCHVER)$(RELVER)-$(DEBVER) for $(RELPLAT)"
	dpkg-buildpackage -b --no-sign
	git checkout debian/changelog

debchange:
	debchange -v $(RELVER)-$(DEBVER)
	debchange -r

debprep:	debclean
	(cd .. && \
		rm -f $(PKGNAME)-$(RELVER) && \
		rm -f $(PKGNAME)-$(RELVER).tar.gz && \
		rm -f $(PKGNAME)_$(RELVER).orig.tar.gz && \
		ln -s $(SRCNAME) $(PKGNAME)-$(RELVER) && \
		tar --exclude=".git" -h -zvcf $(PKGNAME)-$(RELVER).tar.gz $(PKGNAME)-$(RELVER) && \
		ln -s $(PKGNAME)-$(RELVER).tar.gz $(PKGNAME)_$(RELVER).orig.tar.gz )

debclean:
	rm -f ../$(PKGNAME)_$(RELVER)*
	rm -f ../$(PKGNAME)-$(RELVER)*
	rm -rf debian/$(PKGNAME)
	rm -f debian/files
	rm -rf debian/.debhelper/
	rm -f debian/debhelper-build-stamp
	rm -f debian/*.substvars
	rm -rf debian/allstarlink-repo/ debian/.debhelper/
	rm -f debian/debhelper-build-stamp debian/files debian/allstarlink-repo.substvars

	
