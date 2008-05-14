module Sequent
  SEQUENT_CRONTAB_TEST = /script\/publisher\.sh/

  def self.has_crontab
    tabs = `crontab -l`.to_s
    if tabs =~ SEQUENT_CRONTAB_TEST
        true
      else
        false
    end
  end

  # Safely creates a cron job for publishing comic strips
  def self.create_crontab
    # absolute path to app root
    app_path = File.expand_path RAILS_ROOT
    
    # crontab file will be in the 'log' folder because it _should_ be writable
    crontab_file = File.join(app_path, 'log', 'crontab')
    
    # what hour will the job run, everyday?
    poll_hour = SiteConfig[:publish_time] || 0

    # add the sequent cron job at the top...
    lines = [%{0 #{poll_hour} * * * cd #{app_path} && bash script/publisher.sh}]
    
    # add other cron jobs too
    `crontab -l`.to_s.split("\n").each do |line|
      unless line =~ SEQUENT_CRONTAB_TEST # We'll skip a line if it's an older Sequent cron job
        lines << line
      end
    end

    # create local crontab file
    File.open(crontab_file, 'w') do |f|
      f.write lines.join("\n")
    end
    
    # make cron use our local crob job list
    `crontab #{crontab_file}`
  end

end
