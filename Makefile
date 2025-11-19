COMMENT =	lightweight coding agent that runs in your terminal

# Upstream tag for Rust sources:
GH_ACCOUNT =	openai
GH_PROJECT =	codex
GH_TAGNAME =	rust-v0.58.0
PKGNAME =	codex-${GH_TAGNAME:S/rust-v//}

CATEGORIES =	devel
HOMEPAGE =	https://github.com/openai/codex

PERMIT_PACKAGE =	Yes

MODULES =	devel/cargo

# Build from the Rust workspace
WRKSRC =	${WRKDIST}/codex-rs

WANTLIB +=	${MODCARGO_WANTLIB} m

CONFIGURE_STYLE =	cargo

MAKE_ENV +=	${MODCARGO_ENV}

NO_TEST =	Yes

post-extract:
	${INSTALL_DATA_DIR} ${WRKSRC}/vendor
	# Copy the ratatui 0.29.0 crate (already in WRKDIR thanks to MODCARGO_CRATES)
	cp -R ${WRKDIR}/ratatui-0.29.0 ${WRKSRC}/vendor/ratatui
	# Copy keyring 3.6.3 from WRKDIR (added via MODCARGO_CRATES)
	cp -R ${WRKDIR}/keyring-3.6.3 ${WRKSRC}/vendor/keyring

	${INSTALL_DATA_DIR} ${WRKSRC}/.cargo
	# Keep cargo offline and use vendored sources
	printf '%s\n' \
	  '[source.crates-io]' \
	  'replace-with = "vendored-sources"' \
	  '' \
	  '[source.vendored-sources]' \
	  'directory = "modcargo-crates"' \
	  '' \
	  '[patch.crates-io]' \
	  'keyring = { path = "vendor/keyring" }' \
	> ${WRKSRC}/.cargo/config.toml


do-install:
	${INSTALL_PROGRAM} ${WRKBUILD}/target/release/codex ${PREFIX}/bin/codex
	${INSTALL_DATA_DIR} ${PREFIX}/share/examples/codex
	printf '%s\n' \
	  '# ~/.codex/config.toml' \
	  'log_level = "info"' \
	> ${PREFIX}/share/examples/codex/config.toml

# Those aren"t updated with modcargo-gen-crates
MODCARGO_CRATES +=	convert_case 0.7.1  # MIT
MODCARGO_CRATES +=	crossterm 0.28.1  # MIT
MODCARGO_CRATES +=	ratatui	0.29.0	# MIT
MODCARGO_CRATES +=	rmcp	0.8.5	# MIT
MODCARGO_CRATES +=	rmcp-macros	0.8.5	# MIT

.include "crates.inc"
.include <bsd.port.mk>
