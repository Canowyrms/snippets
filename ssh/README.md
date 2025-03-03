# SSH Snippets

## SSH Config Snippets

### Alias a host

```sshconfig
Host convenient-name
	User username
	Hostname full-url.ssh.example.com
```


### Use a certain SSH key for a certain host

```sshconfig
Host ssh.example.com
	IdentityFile ~/.ssh/your_private_key
	IdentitiesOnly yes
```


### Use a certain SSH key for a certain git repo

Useful if you want/need to use different keys for different orgs.

```sshconfig
Host github-canowyrms
	HostName github.com
	IdentityFile ~/.ssh/github_canowyrms_rsa
	IdentitiesOnly yes
```

Then, set your upstream url to use your host alias. Instead of

`git@github.com:Canowyrms/repo.git`

use:

`git@github-canowyrms:Canowyrms/repo.git`
