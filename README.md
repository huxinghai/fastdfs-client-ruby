# fastdfs-client-ruby

fastdfs client for ruby 

### Install

    gem install 'fastdfs-client'

### Using

```RUBY
  
  require 'fastdfs-client'

  # return the result format 
  #  {status: true, err_msg: "", result: ...}
  #


  tracker = Fastdfs::Client::Tracker.new("192.168.1.1", "22122")

  @storage = tracker.get_storage

  if @storage.is_a?(Fastdfs::Client::Storage)

    @storage.upload(@file)
    #result: {group_name: "group1", path: "m1/xfsd/fds.jpg"}

    @storage.delete(path, group_name)  

    # flag params [cover, merge]
    @storage.set_metadata(path, group_name, {author: "kaka", width: "300"}, flag)

    @storage.get_metadata(path, group_name) 
    #result: {author: "kaka", width: "300"}

    @storage.download(path, group_name) 
    #result: #<Tempfile:/var/folders/m7/bt2j0rk54x555t44dpn4b7bm0000gn/T/test.jpg20160416-43738-1560vq3>  
  end

```