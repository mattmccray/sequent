SVN = ENV['SVN'] || 'svk'

namespace :scm do
  
  desc "Looks for and adds new files to sv(k|n)"
  task :add do
    l = `#{SVN} stat`
    files = l.select{|e| /^\?/ =~ e}.collect{|e| e.sub(/^\?\s*/, '').chomp}
    puts
    if files.length == 0
      puts "No files to add"
    else
      print "  "
      puts files.join("\n  ")
      puts
      print "Add all of these? (y/n/i) : "
      if STDIN.gets =~ /^(y|i)/i
        case $1.downcase
          when 'y'
            sh %(#{SVN} add #{files.join(' ')})
          when 'i'
            puts
            puts "- Interactive Mode -"
            puts
            added = 0
            files.each do |file|
              print "Add '#{ file }'? (y/n) : "
              if /^y/i =~ STDIN.gets
                sh %(#{SVN} add #{file})
                added += 1
              else
                puts "Ignored"
              end
            end
            puts
            puts "Finished. #{added} files added to #{SVN}, #{files.length - added} ignored"
        end
      end
    end
    puts
  end

  desc "Looks for and removes missing files from sv(k|n)"
  task :remove do
    puts "TODO"
    return
  end
  
end