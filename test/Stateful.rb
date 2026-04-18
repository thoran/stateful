# test/Stateful.rb

test_dir = File.dirname(File.expand_path(__FILE__))

active_record_specs = Dir[File.join(test_dir, 'ActiveRecord', '**', '*.rb')]
active_record_specs.each{|spec| require spec}

poro_specs = Dir[File.join(test_dir, 'Poro', '**', '*.rb')]
poro_specs.each{|spec| require spec}

sequel_specs = Dir[File.join(test_dir, 'Sequel', '**', '*.rb')]
sequel_specs.each{|spec| require spec}
