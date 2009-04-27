desc "Chips pages and sends them to where they're needed"
task :chip_and_send do
  
  puts "chipping pages"
  Chip.all(:attempted_sent_at => nil).each do |chip|
    
    puts chip.id
    
    chip.update_attributes(:attempted_sent_at => Time.now)
    
    puts chip.page.url
    unless chip.page.chipped?
      chipper = Chipper.new(chip.page.url)
      chip.page.update_attributes(:khtml => chipper.khtml)
    end

    if Notifier.deliver_kindle_email(chip.person.kindle_email, chip.page)
      chip.update_attributes(:sent_at => Time.now)
    end
        
  end
  
end