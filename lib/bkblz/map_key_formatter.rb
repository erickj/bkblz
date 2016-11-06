module Bkblz
  class MapKeyFormatter
    using Bkblz::CoreExt

    def self.underscore_keys(map)
      modified_map = {}
      map.each do |k,v|
        modified_map[k.to_s.underscore.to_sym] = v
      end
      modified_map
    end

    def self.camelcase_keys(map)
      modified_map = {}
      map.each do |k,v|
        modified_map[k.to_s.camelcase.to_sym] = v
      end
      modified_map
    end
  end
end
