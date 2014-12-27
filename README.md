vagrant-smartos-zones
=====================

Manage SmartOS zones using Vagrant.

## Dependencies

This plugin depends on using a SmartOS global zone built to be vagrant
compatible.

```ruby
config.vm.box = "livinginthepast/smartos"
```

See [Vagrant Cloud](https://vagrantcloud.com/livinginthepast) for some boxes.

This plugin also depends on Vagrant recognizing the SmartOS guest. This
is available in Vagrant 1.5.3 or newer.

Any outstanding issues with SmartOS integration in the current released
version of Vagrant can be hacked into shape with the 
[vagrant-smartos/vagrant-smartos-guest](https://github.com/vagrant-smartos/vagrant-smartos-guest)
plugin. This tracks fixes that have been submitted as pull requests to
Vagrant but may have not been yet released.

## Quick Start Installation

```bash
vagrant plugin install vagrant-smartos-zones
mkdir <directory_name>
cd <directory_name>
curl -sO https://raw.githubusercontent.com/vagrant-smartos/vagrant-smartos-zones/master/examples/Vagrantfile
vagrant up
vagrant ssh
```


## Slow Start Installation

```bash
vagrant plugin install vagrant-smartos-zones
```

If you are using a development version of vagrant, or would like to use
an unreleased version of this plugin, add the following to your Gemfile.

```ruby
group :plugins do
  gem 'vagrant-smartos-zones', github: 'vagrant-smartos/vagrant-smartos-zones'
end
```

In a local checkout of this repository, the following will work:

```bash
gem install bundler
bundle
bundle exec vagrant up
bundle exec vagrant ssh
```

Please note that this will install vagrant into your local ruby
environment, which may overwrite or conflict with the normal vagrant
version installed in your system.


## Usage

```ruby
Vagrant.configure('2') do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 3072
  end

  config.ssh.insert_key = false

  # See https://vagrantcloud.com/livinginthepast for SmartOS boxes
  config.vm.box = "livinginthepast/smartos"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # This is required for the commands that talk to the global zone
  config.vm.communicator = 'smartos'

  # livinginthepast boxes include a default platform_image. Set
  # here to download/use a different image.
  # config.global_zone.platform_image = 'latest'
  # config.global_zone.platform_image = '20140312T071408Z'

  config.zone.name = 'base64'
  config.zone.brand = 'joyent'
  config.zone.image = 'c353c568-69ad-11e3-a248-db288786ea63'
  config.zone.memory = 2048
  config.zone.disk_size = 5

  config.zone.synced_folder ".", "/vagrant", type: 'rsync'
end
```

Download or interact with SmartOS platform images:

```bash
vagrant smartos latest
vagrant smartos list
vagrant smartos install [platform_image]
```

Interact with zones running in a box:

```bash
vagrant zones config
vagrant zones list
vagrant zones show [name]
vagrant zones start [name]
vagrant zones stop [name]
```

## Single zone usage

When a single zone is configured (currently the only configuration
possible), a `zonegate` service is enabled in the global zone. This
makes it so that inbound packets in the global zone are forwarded to the
zone.

#### vagrant ssh

When `zonegate` is disabled or when a zone is not running, then `vagrant
ssh` will access the global zone. When a zone is running while
`zonegate` is enabled, then `vagrant ssh` will access the zone.

```bash
vagrant ssh
```

#### vagrant global-zone ssh

A secondary port forward is installed in VirtualBox, which allows us to
access the global zone even when `zonegate` forwards normal ssh to the
zone.

```bash
vagrant global-zone ssh
```

#### vagrant zlogin [name]

This command accesses the zone, but through the global zone. It uses the
global zone ssh port to connect to the global zone, then runs `zlogin`
to access the zone.

This can by handy when, for instance, SSH becomes broken in the zone.

```bash
vagrant zlogin [name]
```

## Platform images

This plugin expects the Vagrant box to boot SmartOS from a mounted ISO
file, known as a platform image. To facilitate updates to the platform
image without having to continually create new boxes, the plugin
downloads platform image into a user's `.vagrant.d` directory, and then
swaps out the ISO mounted in the Vagrant box with the one configured in
the Vagrantfile.

To help with this, `vagrant-smartos-zones` provides the `vagrant
smartos` subcommand.

Show the name of the most up-to-date platform version hosted by Joyent:

```bash
vagrant smartos latest
```

List all locally-installed platform images:

```bash
vagrant smartos list
```

Download a new platform image:

```bash
vagrant smartos install [platform-image]
```

#### Using an arbitrary platform image url

An arbitrary URL can be used to download SmartOS platform images.
When doing so, no checksum validation is performed (so if the image
is interrupted when downloading, you may end up with a corrupt ISO
file).

When using an arbitrary URL for the platform image, make sure you set
both `platform_image` and `platform_image_url` and include the full
URL to the ISO file. In this case, `platform_image` will be used to name
(and find) the file in the local file system.

```ruby
config.global_zone.platform_image = 'omglol-2131234'
config.global_zone.platform_image_url = 'http://example.com/path/to/smartos-2131234.iso'
```

## Synced Folders

Vagrant allows synced folders into any SmartOS guest. When the guest is
a global zone, be aware that the root partition is a RAM disk of a
little more than 256M.

#### VirtualBox guest additions

Shared folders using VirtualBox guest additions currently do not work.

#### Rsync

In single-zone environments, synced folders of type `rsync` work as
normal. `zonegate` forwards all packets into the zone, and the built-in
synced folders code in Vagrant runs after the zone is configured.

```ruby
# Vagrantfile
config.vm.synced_folder ".", "/vagrant", type: "rsync"
```

#### NFS

Pending.

## User management

The vagrant box with the global zone requires a `vagrant` user and
group with which to connect. This user should have `Primary
Administrator` privileges. When creating a local zone, a `vagrant`
user and group are also created in the zone.

## Tests

There is a basic test suite that uses `test-kitchen` to converge
different brands of zones. Although it might not be comprehensive, it
should be ran after new features or after any significant refactoring to
ensure that nothing breaks the ability to stand up a zone.

```bash
bundle exec kitchen test
```

This may take a while...

## Plugin configuration

The plugin allows for local configuration through the `vagrant zones
config` command. This can be used for local overrides of zone
configuration.

```bash
vagrant zones config
vagrant zones config key value
vagrant zones config --delete key
```

### Pkgsrc mirror

```bash
vagrant zones config local.pkgsrc http://mirror.domain.com
```

This will replace the protocol and domain of the pkgsrc mirror used by
pkgin in a SmartOS zone.

## References / Alternatives

Any success of this project depends heavily on the work of others,
which I've either learned from or pulled in directly.

* https://github.com/joshado/vagrant-smartos - Vagrant plugin for
  managing zones on a global zone running on an arbitary IP.
* https://github.com/groundwater/vagrant-smartos - Scripts for 
  creating stand-alone boxes where GZ networking is twerked to pretend
  that the local zone is the only thing in the box.
* http://dlc-int.openindiana.org/aszeszo/vagrant - aszeszo's work,
  which led to the above repo.
* http://cuddletech.com/blog/?p=821 - [@benr](https://github.com/benr)'s
  writeup of the above work.
* http://vagrantup.com - Thank you so much to Michell Hashimoto for
  making Vagrant in the first place.

Please forgive any lapses of acknowledgment. I've read so many blog
posts and so much source code in the course of working on this, many
references have fallen by the wayside.

## Caveats

* Only one local zone per box. Working on it.
* Usage may change with each prerelease version until I get it
  right. Until a non .pre version is released, check commit logs.

## Contributing

1. Fork it ( https://github.com/vagrant-smartos/vagrant-smartos-zones/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

When creating a new Pull Request, `/cc @sax` in the notes to make sure
I get an email about it.
