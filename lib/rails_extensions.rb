module ActionView::Helpers::DateHelper
  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    case distance_in_minutes
    when 0..1
      return (distance_in_minutes==0) ? _('less than a minute') : _('%d minute', 1) unless include_seconds
      case distance_in_seconds
      when 0..5   then _('less than %d seconds', 5)
      when 6..10  then _('less than %d seconds', 10)
      when 11..20 then _('less than %d seconds', 20)
      when 21..40 then _('half a minute')
      when 41..59 then _('less than a minute')
      else             _('%d minute',1)
      end

    when 2..45      then _("%d minute", distance_in_minutes)
    when 46..90     then _('about %d hour', 1)
    when 90..1440   then _("about %d hour", (distance_in_minutes.to_f / 60.0).round)
    when 1441..2880 then _('%d day', 1)
    when 2880..43199     then _('%d days', (distance_in_minutes / 1440).round)
    when 43200..86399    then _('about 1 month')
    when 86400..525599   then _('%d month', (distance_in_minutes / 43200).round)
    when 525600..1051199 then _('about 1 year')
    else                      _("over %d years", (distance_in_minutes / 525600).round)
    end
  end
end

# Cache extension borrowed from http://blog.pluron.com/2008/07/hell-is-paved-w.html
# Author: Alexander Dymo
module ActionController
  module Caching
    module Fragments
      #NOTE: this method will fail if use not file store
      def expire_matched_fragment_in_dir(dir, regexp, options = nil)
        return unless cache_configured?
        self.class.benchmark("Expired fragments in dir matching: #{regexp.source}, #{cache_store}, #{}") do
          cache_store.delete_matched_in_dir(dir, regexp, options)
        end
      end
    end
  end
end

module ActiveSupport
  module Cache
    # A cache store implementation which stores everything on the filesystem.
    class FileStore
      def delete_matched_in_dir(dir, matcher, options = nil)
        log("delete matched_in_dir: #{dir}", matcher.inspect, options)
        path = File.join(@cache_path, dir)
        return unless File.exist?(path) #it's ok to not have the cache dir
        search_dir(path) do |f|
          if f =~ matcher
          begin
            File.delete(f)
          rescue SystemCallError => e
            # If there's no cache, then there's nothing to complain about
          end
          end
         end
       end
    end
  end
end
