# fastdfs-client-ruby

fastdfs client for ruby 

### Install

    #Gemfile
    gem 'fastdfs-client', git: "git@github.com:huxinghai1988/fastdfs-client-ruby.git"

### Using

```RUBY
  tracker = new Fastdfs::Client::Tracker("192.168.1.1", "22122")

  @storage = tracker.get_storage

  @storage.upload(@file)

  @storage.delete(path, group_name)

  # flag params [cover, merge]
  @storage.set_metadata(path, group_name, {author: "kaka", width: "300"}, flag)

  @storage.get_metadata(path, group_name) 
  #result: {author: "kaka", width: "300"}

```