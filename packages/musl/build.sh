TERMUX_PKG_HOMEPAGE=http://www.musl-libc.org/
TERMUX_PKG_DESCRIPTION="The musl c library (libc) implementation"
TERMUX_PKG_VERSION=1.1.19
TERMUX_PKG_SRCURL=http://www.musl-libc.org/releases/musl-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=db59a8578226b98373f5b27e61f0dd29ad2456f4aa9cec587ba8c24508e4c1d9
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure() {
    LDFLAGS+=" -Wl,-soname,libc.musl-${TERMUX_ARCH}.so.1"
    ./configure \
        --build="x86_64-cross-linux-musl" \
        --host="aarch64-unknown-linux-musl" \
        --prefix="${TERMUX_PREFIX}" \
        --sysconfdir="${TERMUX_PREFIX}/etc" \
        --syslibdir="${TERMUX_PREFIX}/lib" \
        --mandir="${TERMUX_PREFIX}/share/man" \
        --infodir="${TERMUX_PREFIX}/share/info" \
        --localstatedir="${TERMUX_PREFIX}/share/var"
}

termux_step_post_make_install() {
    local LDSO=$(make -f Makefile --eval "$(echo -e 'print-ldso:\n\t@echo $$(basename $(LDSO_PATHNAME))')" print-ldso)
    mv -f "${TERMUX_PREFIX}/lib/libc.so" "${TERMUX_PREFIX}/lib/${LDSO}"
    ln -sfr "${TERMUX_PREFIX}/lib/${LDSO}" "${TERMUX_PREFIX}/lib/libc.musl-${TERMUX_ARCH}.so.1"
    ln -sfr "${TERMUX_PREFIX}/lib/${LDSO}" "${TERMUX_PREFIX}/lib/libc.so"
    ln -sfr "${TERMUX_PREFIX}/lib/${LDSO}" "${TERMUX_PREFIX}/bin/ldd"

    ## Create basic /etc/resolv.conf
    {
        echo "nameserver 1.0.0.1"
        echo "nameserver 1.1.1.1"
    } > "${TERMUX_PREFIX}/etc/resolv.conf"

    ## Create basic /etc/hosts
    echo "127.0.0.1 localhost" > "${TERMUX_PREFIX}/etc/hosts"
}
