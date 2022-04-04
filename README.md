# awx-hashi-vault

This repo holds my operational notes for doing [Ansible AWX](https://github.com/ansible/awx) with [HashiCorp Vault](https://vaultproject.io).
That is, using Vault as an external Credential source for AWX (i.e., not duplicating Credentials in AWX).
There are examples for doing the built-in Machine Credential as well as a Custom (user-defined) Credential.
In order to use anything here, you'll likely need administrative access to both AWX and Vault (or at least, access to those involved in maintaining them).

In order to talk to AWX, these roles and playbooks rely on the well-defined Tower environment variables; namely, `$TOWER_HOST`, `$TOWER_USERNAME`, and `$TOWER_PASSWORD`.

In order to talk to Vault, these roles and playbooks leverage the `vault` CLI (the current state of Ansible and HashiCorp Vault modules is in a rather strange place).

> Caveat Emptor: Nothing here should be used in Production without consulting the folks responsible for both AWX and Vault.

There's an Ansible [inventory](./ansible/inventory.yml) you should modify.
In it, you'll note two hosts, `localhost` and `honeycrisp`, and one group, `awx_managed`.
There are also environment variables which should be set for things like the AWX service account SSH keys, and so on.

Again, this repository is just my operational notes on this topic, it shouldn't be uses as-is in your work environment.

The host named `honeycrisp` is my laptop (my sandbox) which I used as the backdrop for this repository (we need a client to test the AWX Machine Credential against).

Note that the `ansible_user` is defined as `awx` for `honeycrisp`, the `prep-infra` role will create this user on `honeycrisp` (it'll act as the service account for AWX).

The `awx_managed` group is the `hosts` of the `prep-infra` playbook, which means that the role will only run against `honeycrisp` in this case.

You can get a nice visual representation of an inventory like this:

```bash
❯ ansible-inventory --inventory inventory.yml --graph
@all:
  |--@awx_managed:
  |  |--honeycrisp
  |--@ungrouped:
  |  |--localhost
```


> The operational bits of this repository live in the [ansible](ansible/) directory.

## Roles

- `prep-vault` - This role ensures that Vault is good-to-go and it dumps out Vault approle authentication.
- `prep-infra` - This role creates a user account and SSH keypair for testing purposes.
- `prep-awx` - This role creates the AWX assets for testing purposes (Organization, Project, Credentials, etc).

## Playbooks

- `prep-vault.yml` - This playbook simply calls the `prep-vault` role and runs against `localhost`.
- `prep-infra.yml` - This playbook simply calls the `prep-infra` role and runs against `awx_managed`.
- `prep-awx.yml` - This playbook simply calls the `prep-awx` role and runs against `localhost`.
