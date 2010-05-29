
module ExtLib
  module Coms

    def ext_to_json(opts)
      _rtn = ""
      if opts.is_a?(Array)
        _rtn = opts.map{|v| trans_js_value(v,nil)}.join(', ')
        return "[#{_rtn}]"
      else
        _rtn = opts.map{|key, val| "#{key}: #{trans_js_value(val,key)}"}.join(",\n")
        return "{#{_rtn}}"
      end
    end

private
    def trans_js_value(value, hash_key=nil)
      if value.nil?
        return "null"
      elsif value.is_a?(Numeric) || value.to_s =~ /^-?[0-9][0-9]*[\.]?[0-9]*$/
        return value
      elsif value.is_a?(Array)
        return "[#{value.map{|v| trans_js_value(v, nil)}.join(', ')}]"
      elsif value.is_a?(Hash)
        _rtn= value.map{|key, val| "#{key}: #{trans_js_value(val, key)}"}.join(",\n")
        return "{#{_rtn}}"
      elsif value.is_a?(String) || value.is_a?(Symbol)
        if [:handler,:renderer,:listeners,:click].include?(hash_key)
          return "#{value.to_s}"
        elsif value.to_s.start_with?("=")
          return "#{value.to_s[1..-1]}"
        else
          return "\"#{value.to_s}\""
        end
      else
        return "#{value.to_s}"
      end
    end
  end
end