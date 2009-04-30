desc "Site reports"
task :report do
  
  people = Person.all
  
  puts
  puts
  puts "*** HATCHET REPORT ***"
  puts "======================"
  puts
  puts "** Summary **"
  puts "People count: #{people.size}"
  puts "Page count: #{Page.all.size}"
  puts "Chip count: #{Chip.all.size}"
  puts "Unsent chip count: #{Chip.all(:sent_at => nil).size}"
  puts
  puts "** People **"
  people.each do |person|
    puts person.kindle_email
  end

  puts
  puts
  
end