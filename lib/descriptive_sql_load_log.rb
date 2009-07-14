
module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      def log_info(sql, name, ms)
        if @logger && @logger.debug?
          c = caller.detect{|line| line !~ /(activerecord|active_support|__DELEGATION__|\/lib\/|\/vendor\/plugins|\/vendor\/gems)/i}
          c ||= caller.first
          c.gsub!("#{File.expand_path(File.dirname(RAILS_ROOT))}/", '') if defined?(RAILS_ROOT)
          name = '%s (%.1fms) %s' % [name || 'SQL', ms, c]
          @logger.debug(format_log_entry(name, sql.squeeze(' ')))
        end
      end
    end
  end
end