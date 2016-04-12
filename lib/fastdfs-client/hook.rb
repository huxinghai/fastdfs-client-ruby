module Hook
  def before(*meth_names, &callback)
    meth_names.each{|meth_name| add_hook :before, meth_name, &callback }
  end
  
  def after(*meth_names, &callback)
    meth_names.each{|meth_name| add_hook :after, meth_name, &callback }
  end
  
  def hooks
    @hooks ||= Hash.new do |hash, method_name|
      hash[method_name] = { before: [], after: [], hijacked: false }
    end
  end
  
  def add_hook(where, meth_name, &callback)
    hooks[meth_name][where] << callback
    ensure_hijacked meth_name
  end
  
  def method_added(meth_name)
    ensure_hijacked meth_name if hooks.has_key? meth_name
  end
  
  def ensure_hijacked(meth_name)
    return if hooks[meth_name][:hijacked] || !instance_methods.include?(meth_name)
    meth = instance_method meth_name
    _hooks = hooks
    _hooks[meth_name][:hijacked] = true
    define_method meth_name do |*args, &block|
      _hooks[meth_name][:before].each do |callback|
        self.instance_exec(&callback)
      end
      begin
        return_value = meth.bind(self).call *args, &block  
      ensure
        _hooks[meth_name][:after].each do |callback|
          self.instance_exec(&callback)
        end
      end
      return_value
    end
  end
end