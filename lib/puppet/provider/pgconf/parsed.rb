require 'puppet/provider/parsedfile'

Puppet::Type.type(:pgconf).provide(
  :parsed,
  :parent => Puppet::Provider::ParsedFile,
  :default_target => '/etc/postgresql.conf',
  :filetype => :flat
) do
  desc "Set key/values in postgresql.conf."

  text_line :comment, :match => /^\s*#/
  text_line :blank, :match => /^\s*(include|$)/ # include keyword handled as a blank line

  record_line :parsed,
    :fields   => %w{name value crap comment},
    :optional => %w{crap comment},
    :match    => /^\s*(\w+)\s*=?\s*(.*?)(\s*#\s*(.*))?\s*$/,
    :to_line  => proc { |h|

      # simple string and numeric values don't need to be enclosed in quotes
      dontneedquote = h[:value].match(/^(\w+|[0-9.-]+)$/)

      str =  h[:name].downcase # normalize case
      str += ' = '
      str += "'" unless dontneedquote
      str += h[:value]
      str += "'" unless dontneedquote
      str += " # #{h[:comment]}" unless (h[:comment].nil? or h[:comment] != :absent)
      str
    },
    :post_parse => proc { |h|
      h[:name].downcase! # normalize case
      h[:value].gsub!(/(^'|'$)/, '') # strip out quotes
    }

end
