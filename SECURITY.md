# Security policy

Unicode comparison can affect identifiers, allowlists, search, and database
ordering. Report vulnerabilities privately through GitHub Security Advisories
rather than a public issue when disclosure could enable spoofing or access
control bypass.

The maintainers support the latest released version. Reports should include
the exact input scalars, collator configuration, backend, observed result, and
security impact. MoonCollate does not provide confusable detection, identifier
profiles, or authentication policy; callers must apply those controls
separately.
