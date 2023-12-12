CACHE = {}

def search(s, criteria, indent = 0)
  # puts "#{'  ' * indent}search(\"#{s}\", #{criteria})"

  cache_key = "\"#{s}\", #{criteria}"
  return CACHE[cache_key] if CACHE[cache_key]

  (cons, *cdr) = criteria

  text = s.gsub(/^\.+/, '').gsub(/\.+$/, '')

  count = 0

  if cdr.empty?

    count = (0..(text.size - cons)).filter do |i|
      /^(\?|\.){#{i}}(#|\?){#{cons}}(\?|\.)*$/.match(text)
    end.count

  else

    (0..(text.size - cons - cdr.sum - cdr.size)).filter do |i|
      /^(\?|\.){#{i}}(#|\?){#{cons}}(\?|\.)/.match(text)
    end.map do |offset|
      count += search(text[(offset + cons + 1)..], cdr, indent + 1)
    end

  end

  CACHE[cache_key] = count
  # puts "#{'  ' * indent}search(\"#{s}\", #{criteria}) --> #{count}"
  count
end
