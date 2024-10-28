all:

deb-deps:
	sudo apt update -q && sudo apt install -y -q \
		debhelper

build-deb: deb-deps
	dpkg-buildpackage --build=binary --unsigned-changes

new-version: debian/changelog
	@gbp dch; \
	dch --release "Freeze"; \
	export __VERSION=$$(head -n1 $< | grep -E -o -e '\(.+\)' | cut -c 2- | rev | cut -c 2- | rev); \
	echo New version: $$__VERSION;

get-version: debian/changelog
	@echo v$$(head -n1 $< | grep -E -o -e '\(.+\)' | cut -c 2- | rev | cut -c 2- | rev);

release: debian/changelog
	export __VERSION=$$(head -n1 $< | grep -E -o -e '\(.+\)' | cut -c 2- | rev | cut -c 2- | rev); \
	git add --patch $^; \
	git commit --gpg-sign --message "Freeze to version $$__VERSION"; \
	git tag --force --sign v$$__VERSION -m "Release v$$__VERSION";

push-release:
	git push origin master
	git push --tags --force

clean:
	-rm -rf build
	-rm -f ../*gdd-system*
