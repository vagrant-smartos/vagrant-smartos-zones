vagrant-smartos-zones
=====================

Manage SmartOS zones using Vagrant.

## Dependencies

This plugin depends on using a SmartOS global zone built to be vagrant
compatible.

```ruby
config.vm.box = "livinginthepast/SmartOS-20140307T223339Z"
```

See [Vagrant Cloud](https://vagrantcloud.com/livinginthepast) for some boxes.

This plugin also depends on Vagrant recognizing the SmartOS guest. 
[This](https://github.com/mitchellh/vagrant/pull/3102) pull request adds
support, but if you are attempting to use this plugin before that is
included in an official release of Vagrant, you can install the
[sax/vagrant-smartos-guest](https://github.com/sax/vagrant-smartos-guest)
plugin to hack it in.

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

* Boxes are created without the platform image boot media included.
  Current plan is to add commands for downloading platform images into
  .vagrant.d, then somehow getting VirtualBox to switch out the device.
* Networking. Local zones can't route to the outside world.
* Only one local zone per box. Working on it.
* Usage may change with each prerelease version until I get it
  right. Until a non .pre version is released, check commit logs.
* Tests. This was a hack day project built as a proof of concept.
  Until this repo includes tests, use with caution.

## Usage

```ruby
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 3072
  end

  # See https://vagrantcloud.com/livinginthepast for SmartOS boxes
  config.vm.box = "livinginthepast/SmartOS-base64-13.3.1"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.zone.name = 'base64'
  config.zone.brand = 'joyent'
  config.zone.image = 'c353c568-69ad-11e3-a248-db288786ea63'
  config.zone.memory = 2048
  config.zone.disk_size = 5
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

## References / Alternatives

* https://github.com/joshado/vagrant-smartos - Vagrant plugin for
  managing zones on a global zone running on an arbitary IP

## Contributing

1. Fork it ( https://github.com/sax/vagrant-smartos-zones/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
