# chef-email-reporter

This gem extends the Chef client, allowing notifications to be sent via email
to a pre-determined address when a chef-client run fails on a node.  This gives
administrators the confidence that errors on Chef nodes won't go unnoticed.

While it is possible to do this with a simple handler (see
http://docs.getchef.com/handlers.html), one typically only receives the text of
the exception with a handler.  `chef-email-reporter` provides information
identical to what one would receive when running chef-client at the terminal:
the exception, the resource declaration, and the compiled resource.  See below
for a sample email sent by `chef-email-reporter`.

![email screenshot](http://jeffshantz.github.io/chef-email-reporter/screenshots/screenshot-html.png)

Having this additional information can ease troubleshooting for administrators.

## Installation

Install the `chef-email-reporter` gem on the node:

```
/opt/chef/embedded/bin/gem install chef-email-reporter
```

Add something like the following to your `/etc/chef/client.rb` file (see the
**Usage** section below for more details):

```
gem     "chef-email-reporter"
require "chef-email-reporter"

Mail.defaults do
  delivery_method :smtp, address: 'smtp.example.com'
end

email_sender    "no.reply@example.com"
email_recipient "chef-notifications@example.com"
```

Profit.

## Usage

Assuming you have already installed `chef-email-reporter` on your node, you must
activate it by adding the following to your `/etc/chef/client.rb` file:

```
gem     "chef-email-reporter"
require "chef-email-reporter"
```

You should also specify the sender and recipient email addresses for
notifications sent by `chef-email-reporter`:

```
email_sender    "no.reply@example.com"
email_recipient "chef-notifications@example.com"
```

Finally, depending on how you want your mail delivered, you may need to specify
some settings for `Mail.defaults`.  See the examples below for an idea of what
is possible.

### Examples

`chef-email-reporter` uses the `mail` gem to deliver email, so any delivery
methods supported by `mail` are supported.  For full details, see the 
documentation at https://github.com/mikel/mail.  Since the documentation is
lacking slightly, you are advised to have a look in the comments in the files at
https://github.com/mikel/mail/tree/master/lib/mail/network/delivery_methods.

#### Sending email via SMTP

Add the following to `/etc/chef/client.rb`:

```ruby
gem     "chef-email-reporter"
require "chef-email-reporter"

Mail.defaults do
  delivery_method :smtp, {
    :address              => "smtp.example.com",
    :port                 => 25,
    :domain               => "example.com",
    :user_name            => "jeff",
    :password             => "secret",
    :authentication       => "plain",
    :enable_starttls_auto => true
  }
end

email_sender    "no.reply@example.com"
email_recipient "chef-notifications@example.com"
```

Examples for sending email via Gmail and Amazon SES are provided in the wiki
for the `mail` gem:

* Gmail: https://github.com/mikel/mail/wiki/Sending-email-via-Gmail-SMTP
* Amazon SES: https://github.com/mikel/mail/wiki/Sending-email-via-Amazon-SES

#### Sending email via `sendmail`

```ruby
gem     "chef-email-reporter"
require "chef-email-reporter"

Mail.defaults do
  delivery_method :sendmail
end

email_sender    "no.reply@example.com"
email_recipient "chef-notifications@example.com"
```

If your `sendmail` binary is not located at `/usr/sbin/sendmail`, you can
specify its location as an argument:

```ruby
Mail.defaults do
  delivery_method :sendmail, :location => '/absolute/path/to/your/sendmail'
end
```

#### Sending email via `exim`

```ruby
gem     "chef-email-reporter"
require "chef-email-reporter"

Mail.defaults do
  delivery_method :exim
end

email_sender 'no.reply@example.com'
email_recipient 'chef-notifications@example.com'
```

If your `exim` binary is not located at `/usr/sbin/exim`, you can specify its
location as an argument:

```ruby
Mail.defaults do
  delivery_method :exim, :location => '/absolute/path/to/your/exim'
end
```

## Integrating the gem into your workflow

One might wonder how to integrate into one's workflow.  While the method of
integration will vary from deployment to deployment, I will briefly discuss how
I've integrated it into mine.

In my organization, I've configured bare-metal deployment via Razor Server
(https://github.com/puppetlabs/razor-server).  After Razor deploys the operating
system, it runs a script on the node which:

* Installs Chef
* Installs the `chef-email-reporter` gem
* Writes a basic `/etc/chef/client.rb`
* Runs `chef-client` to register and configure the node

Of course, you don't need to be running Razor Server to use this gem.  Simply
have whichever bare-metal deployment solution you're running install the gem and
configure `/etc/chef/client.rb`.  If you're not running a bare-metal deployment
solution, then you'll simply have to perform these steps manually.

## Contributing

1. Fork it (https://github.com/jeffshantz/chef-email-reporter/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

```
Copyright 2014, Jeff Shantz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
