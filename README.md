# WhiteSpace Couchbase Deployment

```
ansible-playbook -i inv --vault-id @prompt play-sandbox.yml
```

## Encrypting Key Value Pairs

Make sure you use the right passphrase !!!

To encrypt a string use;

```
ansible-vault encrypt_string 'some-really-awesome-password' --name 'mariadb_password'
```

To encrypt a multiline value use;

```
ansible-vault encrypt_string --stdin-name 'key_int'
```

Be careful when using the `stdin` option as it will do line breaks