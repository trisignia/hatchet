desc "Chips pages and sends them to where they're needed"
task :chip_and_send do
  
  puts "chipping pages"
  Chip.all(:attempted_sent_at => nil).each do |chip|
    
    puts "*** Chipping page:"
    puts "    chip.id: #{chip.id}"
    puts "    page.id: #{chip.page.id}"
    puts "    page.url: #{chip.page.url}"    
    puts "    person.id: #{chip.person.id}"
    puts "    person.kindle_email: #{chip.person.kindle_email}"
    
    chip.update_attributes(:attempted_sent_at => Time.now)

    begin
      chipper = Chipper.new(chip.page.url)

      if Notifier.deliver_kindle_email(chip.person.kindle_email, chip.page, chipper.khtml)
        chip.update_attributes(:sent_at => Time.now)
        puts "page sent!"
      end
    rescue Exception => e
      puts "*** Error chipping page: #{e}"
    end

  end
  
end