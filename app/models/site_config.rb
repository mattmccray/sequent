class SiteConfig < ActiveRecord::Base

  set_table_name "site_config"

  class << self
    
    def [](key)
      if pair = find_by_key(key.to_s)
        YAML::load(pair.value)
      end
    rescue
      nil
    end

    def []=(key, value)
      val = case value.class.to_s
      when 'String'
        YAML::load("--- #{value}\n").to_yaml
      else
        value.to_yaml
      end
      if pair = find_by_key(key.to_s)
        pair.update_attributes( :value=>val)
      else
        create( :key=>key.to_s, :value=>val )
      end
      val
    rescue
      nil
    end

    def to_hash
      Hash[ *find_all.map { |pair| [pair.key, YAML::load(pair.value)] }.flatten ]
    end
  end
  
end
