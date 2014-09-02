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
[sax/vagrant-smartos-guest](https://github.com/sax/vagrant-smartos-guest)
plugin. This tracks fixes that have been submitted as pull requests to
Vagrant but may have not been yet released.

## Installation

```bash
vagrant plugin install vagrant-smartos-zones
```

If you are using a development version of vagrant, or would like to use
an unreleased version of this plugin, add the following to your Gemfile.

```ruby
group :plugins do
  gem 'vagrant-smartos-zones', github: 'sax/vagrant-smartos-zones'
end
```

## Caveats

* Networking. Local zones can't route to the outside world.
* Only one local zone per box. Working on it.
* Usage may change with each prerelease version until I get it
  right. Until a non .pre version is released, check commit logs.
* Tests. This was a hack day project built as a proof of concept.
  Until this repo includes tests, use with caution.

## Usage

```ruby
Vagrant.configure('2') do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 3072
  end

  # See https://vagrantcloud.com/livinginthepast for SmartOS boxes
  config.vm.box = "livinginthepast/smartos"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # livinginthepast boxes include a default platform_image. Set
  # here to download/use a different image.
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
vagrant smartos list
vagrant smartos install [platform_image]
```

Interact with zones running in a box:

```bash
vagrant zones list
vagrant zones show [name]
vagrant zones start [name]
vagrant zones stop [name]
```

SSH into the box and zlogin into a zone:

```bash
vagrant zlogin [name]
```

## Synced Folders

Vagrant allows synced folders into any SmartOS guest. When the guest is
a global zone, be aware that the root partition is a RAM disk of a
little more than 256M.

### Rsync

This plugin allows for synced folders of type `rsync` into local zones. 
It works by rewriting the list of synced folders in the global zone to sync
folders into the zone's file structure as seen by the global zone. For
instance, `/vagrant` becomes `/zones/95fee2ea-ef89-423a-aed3-c2770fb5cadc/root/vagrant`.

Currently the `vagrant rsync` command does not work with zone synced
folders, though `vagrant rsync-auto` does work.

### NFS

Pending.

## User management

The vagrant box with the global zone requires a `vagrant` user and
group with which to connect. When creating a local zone, a `vagrant`
user and group are also created.

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

## Contributing

1. Fork it ( https://github.com/sax/vagrant-smartos-zones/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

When creating a new Pull Request, `/cc @sax` in the notes to make sure
I get an email about it.
