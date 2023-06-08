# Changelog

All notable changes to this project will be documented in this file.

## Release 1.0.0

**Features**

- Added support for older Puppet enterprise versions which still use 'master' instead of 'primary server'.

**Bugfixes**

- Added exception handling for reading existing csr_attributes.yaml. Corrupted yaml caused the plan to fail for that node. Csr_attributes data is now ignored if its invalid.

## Release 0.2.0

**Features**

- Minor documentation updates

**Bugfixes**

- No longer require a valid API token under the root user on the Puppet primary server.
https://github.com/benjamin-robertson/update_trusted_facts/issues/1

**Known Issues**

## Release 0.1.0

**Features**

- First release to forge.

**Bugfixes**

**Known Issues**
