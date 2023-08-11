# Subscriber Only

![Landing](https://0x1.pt/assets/subscriber-only/landing.png)

Subscriber Only is a Jekyll plugin that, with a Ruby gem and a couple lines of YAML, enables subscription management, payment processing and access controls on your site. It even works with Jekyll Feed, so your RSS feed will keep working as it is.

I launched the service in May 2023 and eventually closed it down due to lack of users. I'm still pretty happy with the way it turned out. I'm open-sourcing it just to show the work I did.

Here's some screenshots:

![PH1](https://0x1.pt/assets/subscriber-only/PH_1.png)

![PH2](https://0x1.pt/assets/subscriber-only/PH_2.png)

![PH3](https://0x1.pt/assets/subscriber-only/PH_3.png)

If you'd like to know more about the code base, I wrote a blog post with a couple of interesting things I did. Here's the link:

<https://0x1.pt/2023/08/08/subscriber-only-a-technical-post-mortem/>

## Deployment

1. Create the 'deploy' user. This is the user used by Capistrano. It will own
   all files.

``` sh
adduser deploy
usermod -aG sudo deploy systemd-journal
```

2. Copy copy SSH keys to the deploy user's `~/.ssh/authorized_keys` and set the
   permissions.

``` sh
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
```

3. Add a couple of options to SSH to make it more secure.

``` sh
# /etc/ssh/sshd_config
AllowUsers deploy
PermitRootLogin no
PasswordAuthentication no
```

And restart it

```sh
sudo systemctl try-reload-or-restart ssh
```

4. Install Postgres, Caddy, Ruby, Node and Yarn. Follow the instruction in each
   project's sites.

5. Allow deploy to restart Puma and GoodJob without a password by editing the
   sudo file

``` sh
sudo visudo -f /etc/sudoers.d/deploy
```

``` sh
# /etc/sudoers.d/deploy
deploy ALL=NOPASSWD: /usr/bin/systemctl restart puma
deploy ALL=NOPASSWD: /usr/bin/systemctl reload puma
deploy ALL=NOPASSWD: /usr/bin/systemctl restart good_job
deploy ALL=NOPASSWD: /usr/bin/systemctl reload good_job
```

6. Create Capistrano's deployment structure

``` sh
sudo mkdir -p /srv/www/subscriber_only/{releases,shared}
```

7. Make it so everything's owned by deploy but readable by the www-data group,
   which is the group both Caddy and Puma will run under

``` sh
sudo chown -R deploy:www-data /srv
sudo find /srv/www/subscriber_only -type d -exec chmod 2750 {} \;
sudo find /srv/www/subscriber_only -type f -exec chmod 640 {} \;

sudo chmod 740 /srv/www/subscriber_only/current/bin/puma
sudo chmod 740 /srv/www/subscriber_only/current/bin/good_job
```

8. Copy SystemD files and Caddyfile to the server and reload SystemD

``` sh
sudo systemctl daemon-reload
```

9. Setup the database

``` sh
sudo -u postgres psql
```

``` sql
create user subscriber_only with password 'MY_RANDOMLY_GENERATED_PASSWORD';
create database subscriber_only_production owner subscriber_only;
```

``` sh
# /etc/postgresql/15/main/pg_hba.conf
local subscriber_only_production subscriber_only scram-sha-256
```
